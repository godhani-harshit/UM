import jwt
import json
import httpx
from app.core.logging import logger
from app.core.config import get_settings
from fastapi import HTTPException, status


async def validate_azure_token(token: str) -> dict:
    try:
        logger.info("🔐 Validating Azure AD access token")

        if not token or len(token) < 100:
            logger.error("Token too short or empty")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token format"
            )

        # Decode unverified payload (just to inspect claims)
        header = jwt.get_unverified_header(token)
        payload_unverified = jwt.decode(token, options={"verify_signature": False})

        logger.debug(f"Unverified Azure token issuer: {payload_unverified.get('iss')}")
        logger.debug(f"Unverified Azure token audience: {payload_unverified.get('aud')}")

        settings = get_settings()
        tenant_id = settings["AZURE_AD_TENANT_ID"]
        expected_client_id = settings["AZURE_AD_CLIENT_ID"]

        aud_claim = payload_unverified.get("aud")

        if isinstance(aud_claim, list):
            aud_list = aud_claim
        else:
            aud_list = [aud_claim]

        valid_audiences = [
            expected_client_id,
            f"api://{expected_client_id}",
        ]

        logger.debug(f"Valid audiences: {valid_audiences}")
        logger.debug(f"Token audiences: {aud_list}")

        if not any(aud in valid_audiences for aud in aud_list):
            logger.warning(f"Invalid Azure audience. Expected: {valid_audiences}, Got: {aud_list}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Azure token has invalid audience"
            )

        openid_config_url = (
            f"https://login.microsoftonline.com/{tenant_id}/v2.0/.well-known/openid-configuration"
        )
        logger.debug(f"Fetching Azure OpenID config: {openid_config_url}")

        async with httpx.AsyncClient() as client:
            res = await client.get(openid_config_url)
            res.raise_for_status()
            openid_config = res.json()

            jwks_uri = openid_config.get("jwks_uri")
            logger.debug(f"Fetching JWKS from: {jwks_uri}")

            res_keys = await client.get(jwks_uri)
            res_keys.raise_for_status()
            jwks = res_keys.json()

        key_id = header.get("kid")

        if not key_id:
            logger.error("Azure token missing 'kid'")
            raise HTTPException(401, "Token missing key ID")

        matching_key = next((k for k in jwks["keys"] if k["kid"] == key_id), None)

        if not matching_key:
            logger.error(f"Matching key '{key_id}' not found in JWKS.")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token signed with unknown key"
            )

        logger.debug(f"Found matching signing key: {key_id}")

        public_key = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(matching_key))

        payload = jwt.decode(
            token,
            public_key,
            algorithms=["RS256"],
            audience=valid_audiences,
            issuer=f"https://login.microsoftonline.com/{tenant_id}/v2.0",
            options={
                "verify_aud": True,
                "verify_exp": True,
                "verify_iss": True
            }
        )

        email = payload.get("preferred_username") or payload.get("email")
        logger.info(f"✅ Azure token successfully validated for: {email}")

        return payload

    except jwt.ExpiredSignatureError:
        logger.warning("Azure token expired")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Azure token expired"
        )

    except jwt.InvalidAudienceError as e:
        logger.warning(f"Invalid aud claim: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Azure token has invalid audience"
        )

    except jwt.InvalidIssuerError as e:
        logger.warning(f"Invalid issuer: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Azure token has invalid issuer"
        )

    except jwt.InvalidTokenError as e:
        logger.warning(f"Invalid Azure token: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Azure token"
        )

    except Exception as e:
        logger.exception(f"Unexpected Azure token validation error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Token validation failed"
        )