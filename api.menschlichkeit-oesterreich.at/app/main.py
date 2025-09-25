from fastapi import FastAPI, HTTPException, Depends, Header, Body, Path
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
import httpx
import os
import jwt
from typing import Optional
import asyncio
import time

# Environment Configuration
CIVI_BASE_URL = os.getenv("CIVI_BASE_URL", "https://crm.menschlichkeit-oesterreich.at")
CIVI_SITE_KEY = os.getenv("CIVI_SITE_KEY")
CIVI_API_KEY = os.getenv("CIVI_API_KEY") 
JWT_SECRET = os.getenv("JWT_SECRET")

app = FastAPI(
    title="Menschlichkeit Österreich API",
    description="CRM Integration API with JWT Authentication",
    version="1.0.0"
)

# CORS (dev-friendly; tighten in production via proxy)
FRONTEND_ORIGINS = os.getenv("FRONTEND_ORIGINS")
if FRONTEND_ORIGINS:
    allow_origins = [o.strip() for o in FRONTEND_ORIGINS.split(",") if o.strip()]
else:
    allow_origins = [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:4180",
        "http://127.0.0.1:4180",
    ]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Data Models
class ContactCreate(BaseModel):
    email: EmailStr
    first_name: Optional[str] = None
    last_name: Optional[str] = None

class MembershipCreate(BaseModel):
    contact_id: int
    membership_type_id: int = 1
    start_date: Optional[str] = None
    end_date: Optional[str] = None

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class ApiResponse(BaseModel):
    success: bool
    data: Optional[dict] = None
    message: Optional[str] = None

class RegisterRequest(BaseModel):
    email: EmailStr
    password: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None

class RefreshRequest(BaseModel):
    refresh_token: str

class ContactUpdate(BaseModel):
    email: Optional[EmailStr] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None

class MembershipUpdate(BaseModel):
    membership_type_id: Optional[int] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None

class SepaMandateCreate(BaseModel):
    contact_id: int
    iban: str
    bic: Optional[str] = None
    account_holder: Optional[str] = None
    amount: Optional[float] = None
    frequency: Optional[str] = None  # e.g., 'YEARLY', 'MONTHLY'


def _extract_first_value(data: dict) -> Optional[dict]:
    """Best-effort extraction of first record from CiviCRM APIv4 response."""
    try:
        if isinstance(data, dict):
            # Common v4 pattern: { 'values': [ {...}, ... ], 'count': N }
            values = data.get("values")
            if isinstance(values, list) and values:
                return values[0]
            # Some responses may embed records directly
            if data:
                return data
    except Exception:
        pass
    return None

# JWT Authentication
def verify_jwt_token(authorization: str = Header(...)):
    """Verify JWT token from Authorization header"""
    try:
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise HTTPException(status_code=401, detail="Invalid authentication scheme")
        
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        return payload
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid token")


def _create_token(sub: str, ttl_seconds: int, token_type: str = "access") -> str:
    now = int(time.time())
    payload = {
        "sub": sub,
        "type": token_type,
        "exp": now + ttl_seconds,
        "iat": now,
    }
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")

# Health Check
@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    return {"status": "healthy", "service": "moe-api", "version": "1.0.0"}

# CiviCRM Integration Helper
async def civicrm_api_call(entity: str, action: str, params: dict):
    """Make authenticated call to CiviCRM APIv4"""
    payload = {
        "params": params,
        "_authx": {
            "api_key": CIVI_API_KEY,
            "key": CIVI_SITE_KEY
        }
    }
    
    url = f"{CIVI_BASE_URL}/civicrm/ajax/api4/{entity}/{action}"
    
    async with httpx.AsyncClient(timeout=30) as client:
        response = await client.post(url, json=payload)
        
    if response.status_code != 200:
        raise HTTPException(status_code=502, detail="CiviCRM API unavailable")
    
    try:
        data = response.json()
    except Exception:
        raise HTTPException(status_code=502, detail="Invalid response from CiviCRM")
    
    if isinstance(data, dict) and data.get("is_error"):
        raise HTTPException(status_code=400, detail=data.get("error_message", "CiviCRM error"))
    
    return data

# API Endpoints
@app.post("/auth/login", response_model=ApiResponse)
async def login(request: LoginRequest):
    """Authenticate user and return JWT token"""
    # Note: In production, integrate with actual authentication system
    # This is a placeholder for development
    
    # For now, create a simple token
    access_token = _create_token(request.email, 3600, token_type="access")
    refresh_token = _create_token(request.email, 3600 * 24 * 7, token_type="refresh")

    return ApiResponse(
        success=True,
        data={"token": access_token, "expires_in": 3600, "refresh_token": refresh_token},
        message="Login successful"
    )


@app.post("/auth/register", response_model=ApiResponse)
async def register(request: RegisterRequest):
    """Register user by creating a CiviCRM contact (public endpoint)."""
    params = {
        "contact_type": "Individual",
        "email": request.email,
    }
    if request.first_name:
        params["first_name"] = request.first_name
    if request.last_name:
        params["last_name"] = request.last_name

    try:
        result = await civicrm_api_call("Contact", "create", params)
        return ApiResponse(success=True, data=result, message="Registration successful")
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")


@app.post("/auth/refresh", response_model=ApiResponse)
async def refresh_token(req: RefreshRequest):
    """Issue new access/refresh token from a valid refresh token."""
    try:
        payload = jwt.decode(req.refresh_token, JWT_SECRET, algorithms=["HS256"])
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=400, detail="Invalid token type")
        subject = payload.get("sub")
        access_token = _create_token(subject, 3600, token_type="access")
        new_refresh = _create_token(subject, 3600 * 24 * 7, token_type="refresh")
        return ApiResponse(success=True, data={"token": access_token, "expires_in": 3600, "refresh_token": new_refresh})
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Refresh token expired")
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid refresh token")


@app.get("/user/profile", response_model=ApiResponse)
async def get_user_profile(payload: dict = Depends(verify_jwt_token)):
    email = payload.get("sub")
    if not email:
        raise HTTPException(status_code=401, detail="Invalid token subject")
    params = {"email": email, "limit": 1}
    try:
        data = await civicrm_api_call("Contact", "get", params)
        first = _extract_first_value(data)
        profile = {
            "email": email,
            "first_name": first.get("first_name") if first else None,
            "last_name": first.get("last_name") if first else None,
            "contact_id": first.get("id") if first else None,
        }
        return ApiResponse(success=True, data=profile, message="Profile fetched")
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")


@app.put("/user/profile", response_model=ApiResponse)
async def update_user_profile(update: ContactUpdate, payload: dict = Depends(verify_jwt_token)):
    email = payload.get("sub")
    if not email:
        raise HTTPException(status_code=401, detail="Invalid token subject")
    # find contact id by email
    try:
        found = await civicrm_api_call("Contact", "get", {"email": email, "limit": 1})
        first = _extract_first_value(found)
        if not first or not first.get("id"):
            raise HTTPException(status_code=404, detail="Contact not found")
        params = {"id": first.get("id")}
        if update.email:
            params["email"] = str(update.email)
        if update.first_name is not None:
            params["first_name"] = update.first_name
        if update.last_name is not None:
            params["last_name"] = update.last_name
        await civicrm_api_call("Contact", "create", params)
        # fetch normalized profile
        refreshed = await civicrm_api_call("Contact", "get", {"id": params["id"], "limit": 1})
        first = _extract_first_value(refreshed)
        profile = {
            "email": first.get("email") if first else email,
            "first_name": first.get("first_name") if first else update.first_name,
            "last_name": first.get("last_name") if first else update.last_name,
            "contact_id": first.get("id") if first else params["id"],
        }
        return ApiResponse(success=True, data=profile, message="Profile updated")
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")

@app.post("/contacts/create", response_model=ApiResponse)
async def create_contact(contact: ContactCreate, _: dict = Depends(verify_jwt_token)):
    """Create a new contact in CiviCRM"""
    
    params = {
        "contact_type": "Individual",
        "email": contact.email,
    }
    
    if contact.first_name:
        params["first_name"] = contact.first_name
    if contact.last_name:
        params["last_name"] = contact.last_name
    
    try:
        result = await civicrm_api_call("Contact", "create", params)
        return ApiResponse(
            success=True,
            data=result,
            message="Contact created successfully"
        )
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")


@app.get("/contacts/{contact_id}", response_model=ApiResponse)
async def get_contact(contact_id: int = Path(..., gt=0), _: dict = Depends(verify_jwt_token)):
    params = {"id": contact_id}
    try:
        result = await civicrm_api_call("Contact", "get", params)
        return ApiResponse(success=True, data=result, message="Contact fetched")
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")


@app.put("/contacts/{contact_id}", response_model=ApiResponse)
async def update_contact(contact_id: int, update: ContactUpdate, _: dict = Depends(verify_jwt_token)):
    params = {"id": contact_id}
    if update.email:
        params["email"] = str(update.email)
    if update.first_name is not None:
        params["first_name"] = update.first_name
    if update.last_name is not None:
        params["last_name"] = update.last_name
    try:
        result = await civicrm_api_call("Contact", "create", params)
        return ApiResponse(success=True, data=result, message="Contact updated")
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")

@app.post("/memberships/create", response_model=ApiResponse)
async def create_membership(membership: MembershipCreate, _: dict = Depends(verify_jwt_token)):
    """Create a new membership in CiviCRM"""
    
    import datetime
    
    params = {
        "contact_id": membership.contact_id,
        "membership_type_id": membership.membership_type_id,
        "join_date": membership.start_date or datetime.date.today().isoformat(),
        "start_date": membership.start_date or datetime.date.today().isoformat(),
    }
    
    if membership.end_date:
        params["end_date"] = membership.end_date
    
    try:
        result = await civicrm_api_call("Membership", "create", params)
        return ApiResponse(
            success=True,
            data=result,
            message="Membership created successfully"
        )
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/contacts/search")
async def search_contacts(email: Optional[str] = None, _: dict = Depends(verify_jwt_token)):
    """Search for contacts in CiviCRM"""
    
    params = {"limit": 25}
    if email:
        params["email"] = email
    
    try:
        result = await civicrm_api_call("Contact", "get", params)
        return ApiResponse(
            success=True,
            data=result,
            message="Search completed"
        )
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")


@app.get("/memberships/contact/{contact_id}", response_model=ApiResponse)
async def get_memberships_for_contact(contact_id: int, _: dict = Depends(verify_jwt_token)):
    params = {"contact_id": contact_id}
    try:
        result = await civicrm_api_call("Membership", "get", params)
        return ApiResponse(success=True, data=result, message="Memberships fetched")
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")


@app.put("/memberships/{membership_id}", response_model=ApiResponse)
async def update_membership(membership_id: int, update: MembershipUpdate, _: dict = Depends(verify_jwt_token)):
    params = {"id": membership_id}
    if update.membership_type_id is not None:
        params["membership_type_id"] = update.membership_type_id
    if update.start_date is not None:
        params["start_date"] = update.start_date
    if update.end_date is not None:
        params["end_date"] = update.end_date
    try:
        result = await civicrm_api_call("Membership", "create", params)
        return ApiResponse(success=True, data=result, message="Membership updated")
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")


@app.post("/sepa/mandate", response_model=ApiResponse)
async def create_sepa_mandate(mandate: SepaMandateCreate, _: dict = Depends(verify_jwt_token)):
    """Create SEPA mandate via CiviCRM SEPA extension (if available)."""
    params = {
        "contact_id": mandate.contact_id,
        "iban": mandate.iban,
    }
    if mandate.bic:
        params["bic"] = mandate.bic
    if mandate.account_holder:
        params["account_holder"] = mandate.account_holder
    if mandate.amount is not None:
        params["amount"] = mandate.amount
    if mandate.frequency:
        params["frequency"] = mandate.frequency
    try:
        result = await civicrm_api_call("SepaMandate", "create", params)
        return ApiResponse(success=True, data=result, message="SEPA mandate created")
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")


@app.get("/sepa/mandate/{contact_id}", response_model=ApiResponse)
async def get_sepa_mandate(contact_id: int, _: dict = Depends(verify_jwt_token)):
    params = {"contact_id": contact_id, "limit": 1}
    try:
        result = await civicrm_api_call("SepaMandate", "get", params)
        return ApiResponse(success=True, data=result, message="SEPA mandate fetched")
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")


# Fail-fast on missing critical environment variables
REQUIRED_ENV = {
    "JWT_SECRET": JWT_SECRET,
    "CIVI_API_KEY": CIVI_API_KEY,
    "CIVI_SITE_KEY": CIVI_SITE_KEY,
}
missing = [k for k, v in REQUIRED_ENV.items() if not v]
if missing:
    raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")

# CORS will be handled by Nginx in production
# For development, you may need to add CORS middleware

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
