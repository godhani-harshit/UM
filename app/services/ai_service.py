import httpx
import asyncio
from typing import Dict, Any, Optional
from datetime import datetime
from app.core.config import get_settings
from app.core.logging import logger


class AIServiceError(Exception):
    """Custom exception for AI service errors"""
    pass


class AIAnalysisService:
    """Service for AI-powered document analysis"""
    
    def __init__(self):
        self.settings = get_settings()
        self.enabled = self.settings.get("AI_SERVICE_ENABLED", False)
        self.endpoint = self.settings.get("AI_SERVICE_ENDPOINT")
        self.api_key = self.settings.get("AI_SERVICE_API_KEY")
        self.confidence_threshold = self.settings.get("AI_CONFIDENCE_THRESHOLD", 0.7)
        self.timeout = 120.0  # 2 minutes timeout for AI processing
        self.max_retries = 3
        
    async def analyze_document(
        self,
        blob_url: str,
        document_type: Optional[str] = None
    ) -> Dict[str, Any]:

        if not self.enabled:
            logger.warning("AI service is disabled, returning mock data")
            return self._get_mock_analysis_result()
        
        if not self.endpoint or not self.api_key:
            raise AIServiceError("AI service credentials not configured")
        
        logger.info(f"🤖 Starting AI analysis for document: {blob_url}")
        
        # Prepare request payload
        payload = {
            "document_url": blob_url,
            "document_type": document_type or "authorization_request",
            "extract_fields": [
                "member_info",
                "provider_info",
                "diagnosis_codes",
                "procedure_codes",
                "dates",
                "authorization_details"
            ],
            "confidence_threshold": self.confidence_threshold
        }
        
        # Retry logic with exponential backoff
        for attempt in range(1, self.max_retries + 1):
            try:
                async with httpx.AsyncClient(timeout=self.timeout) as client:
                    response = await client.post(
                        self.endpoint,
                        json=payload,
                        headers={
                            "Authorization": f"Bearer {self.api_key}",
                            "Content-Type": "application/json"
                        }
                    )
                    
                    if response.status_code == 200:
                        result = response.json()
                        logger.info(f"✅ AI analysis completed successfully (attempt {attempt})")
                        return self._validate_and_transform_response(result)
                    
                    elif response.status_code == 429:  # Rate limited
                        if attempt < self.max_retries:
                            wait_time = 2 ** attempt  # Exponential backoff
                            logger.warning(f"⏳ Rate limited, retrying in {wait_time}s (attempt {attempt}/{self.max_retries})")
                            await asyncio.sleep(wait_time)
                            continue
                        else:
                            raise AIServiceError(f"Rate limit exceeded after {self.max_retries} attempts")
                    
                    else:
                        error_detail = response.text
                        raise AIServiceError(f"AI service returned status {response.status_code}: {error_detail}")
                        
            except httpx.TimeoutException:
                if attempt < self.max_retries:
                    wait_time = 2 ** attempt
                    logger.warning(f"⏳ Request timeout, retrying in {wait_time}s (attempt {attempt}/{self.max_retries})")
                    await asyncio.sleep(wait_time)
                    continue
                else:
                    raise AIServiceError(f"AI service timeout after {self.max_retries} attempts")
                    
            except httpx.RequestError as e:
                if attempt < self.max_retries:
                    wait_time = 2 ** attempt
                    logger.warning(f"⏳ Request error: {str(e)}, retrying in {wait_time}s (attempt {attempt}/{self.max_retries})")
                    await asyncio.sleep(wait_time)
                    continue
                else:
                    raise AIServiceError(f"AI service request failed: {str(e)}")
        
        raise AIServiceError("AI analysis failed after all retry attempts")
    
    def _validate_and_transform_response(self, ai_response: Dict[str, Any]) -> Dict[str, Any]:
        try:
            # Validate required fields
            if "extractions" not in ai_response:
                raise AIServiceError("AI response missing 'extractions' field")
            
            extractions = ai_response["extractions"]
            confidence_score = ai_response.get("confidence_score", 0.0)
            
            # Check confidence threshold
            if confidence_score < self.confidence_threshold:
                logger.warning(f"⚠️ AI confidence score {confidence_score} below threshold {self.confidence_threshold}")
            
            # Transform to internal format
            transformed = {
                "member_info": self._extract_member_info(extractions.get("member_info", {})),
                "request_provider_info": self._extract_provider_info(extractions.get("requesting_provider", {})),
                "service_provider_info": self._extract_provider_info(extractions.get("servicing_provider", {})),
                "request_info": self._extract_request_info(extractions.get("request_details", {})),
                "requested_items": self._extract_requested_items(extractions.get("procedure_codes", [])),
                "diagnosis_codes": self._extract_diagnosis_codes(extractions.get("diagnosis_codes", [])),
                "confidence_score": confidence_score,
                "extraction_timestamp": datetime.utcnow().isoformat()
            }
            
            logger.info(f"✅ AI response validated and transformed (confidence: {confidence_score})")
            return transformed
            
        except Exception as e:
            logger.error(f"❌ AI response validation failed: {str(e)}")
            raise AIServiceError(f"Invalid AI response format: {str(e)}")
    
    def _extract_member_info(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract and format member information"""
        return {
            "member_name": data.get("name", ""),
            "dob": data.get("date_of_birth", ""),
            "health_plan_id": data.get("member_id", ""),
            "health_plan": data.get("health_plan", ""),
            "authorization_number": data.get("auth_number", "")
        }
    
    def _extract_provider_info(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract and format provider information"""
        return {
            "requesting_provider" if "requesting" in str(data) else "servicing_provider": data.get("name", ""),
            "requesting_provider_npi" if "requesting" in str(data) else "servicing_provider_npi": data.get("npi", ""),
            "requesting_phone" if "requesting" in str(data) else "servicing_phone": data.get("phone", ""),
            "requesting_fax" if "requesting" in str(data) else "servicing_fax": data.get("fax", ""),
            "requesting_email" if "requesting" in str(data) else "servicing_email": data.get("email", "")
        }
    
    def _extract_request_info(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Extract and format request information"""
        return {
            "template_type": data.get("template_type", "Undetermined"),
            "received_datetime": data.get("received_date", datetime.utcnow().isoformat()),
            "start_of_service": data.get("start_of_service"),
            "priority": data.get("priority", "standard")
        }
    
    def _extract_requested_items(self, items: list) -> list:
        """Extract and format requested items/procedures"""
        return [
            {
                "procedure_code": item.get("code", ""),
                "description": item.get("description", ""),
                "quantity": item.get("quantity", 1),
                "units": item.get("units", ""),
                "start_date": item.get("start_date"),
                "end_date": item.get("end_date")
            }
            for item in items
        ]
    
    def _extract_diagnosis_codes(self, codes: list) -> list:
        """Extract and format diagnosis codes"""
        return [
            {
                "code": code.get("code", ""),
                "description": code.get("description", ""),
                "is_primary": code.get("is_primary", False)
            }
            for code in codes
        ]
    
    def _get_mock_analysis_result(self) -> Dict[str, Any]:
        logger.info("🔧 Returning mock AI analysis result")
        return {
            "member_info": {
                "member_name": "Mock Patient",
                "dob": "1980-01-01",
                "health_plan_id": "MOCK123",
                "health_plan": "Mock Health Plan",
                "authorization_number": ""
            },
            "request_provider_info": {
                "requesting_provider": "",
                "requesting_provider_npi": "",
                "requesting_phone": "",
                "requesting_fax": "",
                "requesting_email": ""
            },
            "service_provider_info": {
                "servicing_provider": "",
                "servicing_provider_npi": "",
                "servicing_phone": "",
                "servicing_fax": "",
                "servicing_email": ""
            },
            "request_info": {
                "template_type": "Undetermined",
                "received_datetime": datetime.utcnow().isoformat(),
                "start_of_service": None,
                "priority": "standard"
            },
            "requested_items": [],
            "diagnosis_codes": [],
            "confidence_score": 0.0,
            "extraction_timestamp": datetime.utcnow().isoformat()
        }


# Singleton instance
_ai_service_instance = None


def get_ai_service() -> AIAnalysisService:
    """Get singleton AI service instance"""
    global _ai_service_instance
    if _ai_service_instance is None:
        _ai_service_instance = AIAnalysisService()
    return _ai_service_instance


# Convenience functions
async def analyze_document(blob_url: str, document_type: Optional[str] = None) -> Dict[str, Any]:
    service = get_ai_service()
    return await service.analyze_document(blob_url, document_type)


def validate_ai_response(response: Dict[str, Any]) -> bool:
    required_fields = ["member_info", "confidence_score", "extraction_timestamp"]
    return all(field in response for field in required_fields)
