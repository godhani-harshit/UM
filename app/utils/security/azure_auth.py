# app/utils/security/azure_auth.py
import httpx
import jwt
import json
from fastapi import HTTPException, status
from app.core.config import get_settings
from app.core.logging import logger

async def validate_azure_token(token: str) -> dict:
    """Validate Azure AD access token against Microsoft JWKS."""
    try:
        logger.info("Validating Azure AD token")
        
        # Basic token validation
        if not token or len(token) < 100:
            logger.error("Token too short or empty")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token format"
            )
        
        # Decode token without verification to inspect it first
        unverified_header = jwt.get_unverified_header(token)
        unverified_payload = jwt.decode(token, options={"verify_signature": False})
        
        logger.debug(f"Token audience: {unverified_payload.get('aud')}")
        logger.debug(f"Token issuer: {unverified_payload.get('iss')}")
        
        s = get_settings()
        # Determine expected audience based on token
        actual_audience = unverified_payload.get('aud')
        expected_client_id = s["AZURE_AD_CLIENT_ID"]
        
        # Accept both audience formats:
        # 1. Client ID only: b4317f13-3edb-4aca-9e8a-5ee812a7272d
        # 2. API URI format: api://b4317f13-3edb-4aca-9e8a-5ee812a7272d
        valid_audiences = [
            expected_client_id,  # Client ID format
            f"api://{expected_client_id}"  # API URI format
        ]
        
        logger.debug(f"Valid audiences: {valid_audiences}")
        logger.debug(f"Actual audience: {actual_audience}")
        
        if actual_audience not in valid_audiences:
            logger.warning(f" Invalid audience. Expected one of {valid_audiences}, Got: {actual_audience}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Azure token has invalid audience"
            )
        
        async with httpx.AsyncClient() as client:
            # Build OpenID configuration URL from Tenant ID if not provided
            tenant_id = s["AZURE_AD_TENANT_ID"]
            openid_config_url = f"https://login.microsoftonline.com/{tenant_id}/v2.0/.well-known/openid-configuration"
            logger.debug(f"Fetching OpenID config from: {openid_config_url}")
            
            openid_config_response = await client.get(openid_config_url)
            openid_config_response.raise_for_status()
            openid_config = openid_config_response.json()
            
            # Get JWKS (JSON Web Key Set)
            jwks_uri = openid_config["jwks_uri"]
            logger.debug(f"Fetching JWKS from: {jwks_uri}")
            
            jwks_response = await client.get(jwks_uri)
            jwks_response.raise_for_status()
            jwks = jwks_response.json()
            logger.debug(f"JWKS contains {len(jwks['keys'])} keys")
        
        # Get token header to find the key ID
        header = jwt.get_unverified_header(token)
        key_id = header.get("kid")
        logger.debug(f"Token key ID (kid): {key_id}")
        
        if not key_id:
            logger.error("Token missing key ID (kid)")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token missing key ID"
            )
        
        # Find the correct key in JWKS
        available_kids = [k["kid"] for k in jwks["keys"]]
        key = next((k for k in jwks["keys"] if k["kid"] == key_id), None)
        
        if not key:
            logger.error(f"Key {key_id} not found in JWKS. Available keys: {available_kids}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token signed with unknown key"
            )
        
        logger.debug(f"Found matching key: {key_id}")
        
        # Convert JWK to RSA public key
        public_key = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(key))
        
        # Validate and decode token - accept any of the valid audiences
        payload = jwt.decode(
            token,
            public_key,
            algorithms=["RS256"],
            audience=actual_audience,  # Use the actual audience from the token
            options={"verify_exp": True, "verify_aud": True}
        )
        
        email = payload.get("preferred_username") or payload.get("email")
        logger.info(f"✅ Azure token validated for: {email}")
        return payload
        
    except jwt.ExpiredSignatureError:
        logger.warning("Azure token expired")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Azure token expired"
        )
    except jwt.InvalidAudienceError as e:
        logger.warning(f"Azure token audience validation failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Azure token has invalid audience"
        )
    except jwt.InvalidTokenError as e:
        logger.warning(f"Invalid Azure token: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Azure token"
        )
    except Exception as e:
        logger.exception(f"Unexpected error during Azure token validation: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Token validation failed"
        )