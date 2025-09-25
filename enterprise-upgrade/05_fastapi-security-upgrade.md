# FastAPI Security Upgrade

## Übersicht
Comprehensive Security-Hardening für die FastAPI-Layer mit JWT-Improvements, Container-Sicherheit und API-Monitoring.

## 1. JWT Security Hardening

### 1.1 JWT Token Configuration
```python
# auth/jwt_config.py
import os
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
import jwt
from cryptography.fernet import Fernet
from passlib.context import CryptContext
import secrets
import redis
import logging

class JWTManager:
    def __init__(self):
        # Erweiterte JWT-Konfiguration
        self.secret_key = os.getenv('JWT_SECRET_KEY')
        self.refresh_secret = os.getenv('JWT_REFRESH_SECRET', self._generate_secret())
        self.algorithm = "RS256"  # Upgrade zu RSA256
        self.access_token_expire = timedelta(minutes=15)  # Verkürzte Lebensdauer
        self.refresh_token_expire = timedelta(days=7)
        
        # Blacklist für revoked tokens
        self.redis_client = redis.Redis.from_url(os.getenv('REDIS_URL', 'redis://localhost:6379'))
        self.pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        
        # Rate limiting für Auth-Endpoints
        self.auth_rate_limit = 5  # Attempts per minute
        
        # RSA Keys für asymmetrische Signierung
        self._load_rsa_keys()
        
        # Logging
        self.logger = logging.getLogger(__name__)
    
    def _generate_secret(self) -> str:
        """Generate cryptographically secure secret"""
        return secrets.token_urlsafe(64)
    
    def _load_rsa_keys(self):
        """Load or generate RSA key pair"""
        private_key_path = os.getenv('JWT_PRIVATE_KEY_PATH', './keys/jwt_private.pem')
        public_key_path = os.getenv('JWT_PUBLIC_KEY_PATH', './keys/jwt_public.pem')
        
        try:
            with open(private_key_path, 'r') as f:
                self.private_key = f.read()
            with open(public_key_path, 'r') as f:
                self.public_key = f.read()
        except FileNotFoundError:
            self._generate_rsa_keys(private_key_path, public_key_path)
    
    def _generate_rsa_keys(self, private_path: str, public_path: str):
        """Generate new RSA key pair"""
        from cryptography.hazmat.primitives import serialization
        from cryptography.hazmat.primitives.asymmetric import rsa
        
        # Generate private key
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        
        # Serialize private key
        pem_private = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
        
        # Serialize public key
        public_key = private_key.public_key()
        pem_public = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        
        # Save keys
        os.makedirs(os.path.dirname(private_path), exist_ok=True)
        with open(private_path, 'wb') as f:
            f.write(pem_private)
        with open(public_path, 'wb') as f:
            f.write(pem_public)
        
        self.private_key = pem_private.decode()
        self.public_key = pem_public.decode()
    
    def create_access_token(self, data: Dict[Any, Any], user_id: int) -> str:
        """Create JWT access token with enhanced security"""
        to_encode = data.copy()
        expire = datetime.utcnow() + self.access_token_expire
        
        # Enhanced Claims
        to_encode.update({
            "exp": expire,
            "iat": datetime.utcnow(),
            "sub": str(user_id),
            "type": "access",
            "jti": secrets.token_urlsafe(32),  # JWT ID für blacklisting
            "aud": os.getenv('JWT_AUDIENCE', 'api.crm.example.com'),
            "iss": os.getenv('JWT_ISSUER', 'crm.example.com')
        })
        
        encoded_jwt = jwt.encode(to_encode, self.private_key, algorithm=self.algorithm)
        
        # Log token creation
        self.logger.info(f"Access token created for user {user_id}")
        
        return encoded_jwt
    
    def create_refresh_token(self, user_id: int) -> str:
        """Create refresh token"""
        expire = datetime.utcnow() + self.refresh_token_expire
        jti = secrets.token_urlsafe(32)
        
        to_encode = {
            "sub": str(user_id),
            "exp": expire,
            "iat": datetime.utcnow(),
            "type": "refresh",
            "jti": jti
        }
        
        token = jwt.encode(to_encode, self.refresh_secret, algorithm="HS256")
        
        # Store refresh token in Redis
        self.redis_client.set(
            f"refresh_token:{jti}",
            user_id,
            ex=int(self.refresh_token_expire.total_seconds())
        )
        
        return token
    
    def verify_token(self, token: str, token_type: str = "access") -> Optional[Dict]:
        """Verify JWT token with blacklist check"""
        try:
            # Decode token
            if token_type == "access":
                payload = jwt.decode(token, self.public_key, algorithms=[self.algorithm])
            else:
                payload = jwt.decode(token, self.refresh_secret, algorithms=["HS256"])
            
            # Check token type
            if payload.get("type") != token_type:
                raise jwt.InvalidTokenError("Invalid token type")
            
            # Check blacklist
            jti = payload.get("jti")
            if jti and self.redis_client.exists(f"blacklist:{jti}"):
                raise jwt.InvalidTokenError("Token has been revoked")
            
            return payload
            
        except jwt.ExpiredSignatureError:
            self.logger.warning("Token expired")
            return None
        except jwt.InvalidTokenError as e:
            self.logger.warning(f"Invalid token: {e}")
            return None
    
    def revoke_token(self, token: str) -> bool:
        """Add token to blacklist"""
        try:
            payload = jwt.decode(token, self.public_key, algorithms=[self.algorithm], verify=False)
            jti = payload.get("jti")
            
            if jti:
                exp = payload.get("exp")
                ttl = exp - datetime.utcnow().timestamp() if exp else 3600
                
                self.redis_client.set(f"blacklist:{jti}", "revoked", ex=int(ttl))
                self.logger.info(f"Token {jti} revoked")
                return True
                
        except Exception as e:
            self.logger.error(f"Error revoking token: {e}")
            
        return False

# Singleton instance
jwt_manager = JWTManager()
```

### 1.2 Enhanced Authentication Middleware
```python
# auth/middleware.py
from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional, Dict, Any
import redis
import json
from datetime import datetime, timedelta

security = HTTPBearer()
redis_client = redis.Redis.from_url(os.getenv('REDIS_URL', 'redis://localhost:6379'))

class AuthMiddleware:
    def __init__(self):
        self.rate_limit_window = 60  # 1 minute
        self.max_requests = 100      # per window per user
        self.failed_attempts_limit = 5
        self.lockout_duration = 300  # 5 minutes
    
    async def get_current_user(
        self, 
        credentials: HTTPAuthorizationCredentials = Depends(security)
    ) -> Dict[str, Any]:
        """Enhanced user authentication with rate limiting"""
        
        token = credentials.credentials
        
        # Verify token
        payload = jwt_manager.verify_token(token, "access")
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        user_id = payload.get("sub")
        
        # Rate limiting check
        if not self._check_rate_limit(user_id):
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Rate limit exceeded. Please try again later."
            )
        
        # Check user lockout
        if self._is_user_locked(user_id):
            raise HTTPException(
                status_code=status.HTTP_423_LOCKED,
                detail="Account temporarily locked due to suspicious activity"
            )
        
        return {
            "user_id": int(user_id),
            "permissions": payload.get("permissions", []),
            "roles": payload.get("roles", []),
            "session_id": payload.get("jti")
        }
    
    def _check_rate_limit(self, user_id: str) -> bool:
        """Check API rate limiting per user"""
        key = f"rate_limit:{user_id}"
        current = redis_client.get(key)
        
        if current is None:
            # First request in window
            redis_client.set(key, 1, ex=self.rate_limit_window)
            return True
        
        current_count = int(current)
        if current_count >= self.max_requests:
            return False
        
        redis_client.incr(key)
        return True
    
    def _is_user_locked(self, user_id: str) -> bool:
        """Check if user is locked due to failed attempts"""
        key = f"lockout:{user_id}"
        return redis_client.exists(key)
    
    def record_failed_attempt(self, identifier: str):
        """Record failed login attempt"""
        key = f"failed_attempts:{identifier}"
        current = redis_client.get(key)
        
        if current is None:
            redis_client.set(key, 1, ex=self.rate_limit_window)
        else:
            count = int(current) + 1
            redis_client.set(key, count, ex=self.rate_limit_window)
            
            if count >= self.failed_attempts_limit:
                # Lock user
                redis_client.set(f"lockout:{identifier}", "locked", ex=self.lockout_duration)
    
    def clear_failed_attempts(self, identifier: str):
        """Clear failed attempts on successful login"""
        redis_client.delete(f"failed_attempts:{identifier}")

auth_middleware = AuthMiddleware()

# FastAPI Dependencies
def get_current_user():
    return Depends(auth_middleware.get_current_user)

def require_permissions(*required_permissions):
    """Decorator für Permission-based Access Control"""
    def decorator(func):
        async def wrapper(current_user: dict = Depends(get_current_user), *args, **kwargs):
            user_permissions = set(current_user.get("permissions", []))
            required_perms = set(required_permissions)
            
            if not required_perms.issubset(user_permissions):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Insufficient permissions"
                )
            
            return await func(current_user=current_user, *args, **kwargs)
        return wrapper
    return decorator
```

## 2. Key Rotation System

### 2.1 Automated Key Rotation
```python
# auth/key_rotation.py
import os
import logging
from datetime import datetime, timedelta
from typing import Tuple
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
import asyncio

class KeyRotationManager:
    def __init__(self):
        self.rotation_interval = timedelta(days=30)  # Monthly rotation
        self.key_overlap_period = timedelta(days=1)  # Grace period
        self.logger = logging.getLogger(__name__)
        
        self.keys_dir = os.getenv('JWT_KEYS_DIR', './keys')
        os.makedirs(self.keys_dir, exist_ok=True)
    
    async def rotate_keys_if_needed(self):
        """Check and perform key rotation if needed"""
        try:
            current_key_age = self._get_current_key_age()
            
            if current_key_age > self.rotation_interval:
                self.logger.info("Starting JWT key rotation")
                await self._perform_rotation()
                self.logger.info("JWT key rotation completed")
                
        except Exception as e:
            self.logger.error(f"Key rotation failed: {e}")
    
    def _get_current_key_age(self) -> timedelta:
        """Get age of current private key"""
        private_key_path = os.path.join(self.keys_dir, 'jwt_private.pem')
        
        if not os.path.exists(private_key_path):
            return timedelta(days=999)  # Force rotation if no key exists
        
        creation_time = datetime.fromtimestamp(os.path.getctime(private_key_path))
        return datetime.now() - creation_time
    
    async def _perform_rotation(self):
        """Perform key rotation with overlap period"""
        # Generate new key pair
        new_private, new_public = self._generate_key_pair()
        
        # Move current keys to backup with timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        self._backup_current_keys(timestamp)
        
        # Install new keys
        self._install_new_keys(new_private, new_public)
        
        # Schedule cleanup of old keys after overlap period
        asyncio.create_task(self._cleanup_old_keys_later(timestamp))
        
        # Notify application to reload keys
        await self._notify_key_rotation()
    
    def _generate_key_pair(self) -> Tuple[bytes, bytes]:
        """Generate new RSA key pair"""
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        
        # Serialize private key
        pem_private = private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
        
        # Serialize public key
        public_key = private_key.public_key()
        pem_public = public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        
        return pem_private, pem_public
    
    def _backup_current_keys(self, timestamp: str):
        """Backup current keys"""
        current_private = os.path.join(self.keys_dir, 'jwt_private.pem')
        current_public = os.path.join(self.keys_dir, 'jwt_public.pem')
        
        if os.path.exists(current_private):
            backup_private = os.path.join(self.keys_dir, f'jwt_private_{timestamp}.pem')
            os.rename(current_private, backup_private)
        
        if os.path.exists(current_public):
            backup_public = os.path.join(self.keys_dir, f'jwt_public_{timestamp}.pem')
            os.rename(current_public, backup_public)
    
    def _install_new_keys(self, private_key: bytes, public_key: bytes):
        """Install new keys"""
        private_path = os.path.join(self.keys_dir, 'jwt_private.pem')
        public_path = os.path.join(self.keys_dir, 'jwt_public.pem')
        
        with open(private_path, 'wb') as f:
            f.write(private_key)
        
        with open(public_path, 'wb') as f:
            f.write(public_key)
        
        # Set secure permissions
        os.chmod(private_path, 0o600)  # Only owner can read
        os.chmod(public_path, 0o644)   # Public readable
    
    async def _cleanup_old_keys_later(self, timestamp: str):
        """Clean up old keys after overlap period"""
        await asyncio.sleep(self.key_overlap_period.total_seconds())
        
        old_private = os.path.join(self.keys_dir, f'jwt_private_{timestamp}.pem')
        old_public = os.path.join(self.keys_dir, f'jwt_public_{timestamp}.pem')
        
        for key_file in [old_private, old_public]:
            if os.path.exists(key_file):
                os.remove(key_file)
                self.logger.info(f"Cleaned up old key: {key_file}")
    
    async def _notify_key_rotation(self):
        """Notify application components of key rotation"""
        # Reload JWT manager keys
        from .jwt_config import jwt_manager
        jwt_manager._load_rsa_keys()
        
        # Clear any JWT verification caches
        if hasattr(jwt_manager, 'verification_cache'):
            jwt_manager.verification_cache.clear()

# Background task für automatische Rotation
key_rotation_manager = KeyRotationManager()

async def start_key_rotation_scheduler():
    """Start background key rotation scheduler"""
    while True:
        await key_rotation_manager.rotate_keys_if_needed()
        await asyncio.sleep(3600)  # Check hourly
```

## 3. Status & Health Endpoints

### 3.1 Comprehensive Health Monitoring
```python
# api/health.py
from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import JSONResponse
from typing import Dict, Any, List
import time
import psutil
import redis
from datetime import datetime, timedelta
import asyncio
from sqlalchemy import text
from database import get_db
import requests

router = APIRouter(prefix="/status", tags=["health"])

class HealthChecker:
    def __init__(self):
        self.redis_client = redis.Redis.from_url(os.getenv('REDIS_URL', 'redis://localhost:6379'))
        self.startup_time = datetime.utcnow()
        self.version = os.getenv('API_VERSION', '1.0.0')
        
    async def check_database(self) -> Dict[str, Any]:
        """Check database connectivity and performance"""
        start_time = time.time()
        try:
            db = next(get_db())
            result = db.execute(text("SELECT 1 as health_check"))
            db_time = time.time() - start_time
            
            return {
                "status": "healthy",
                "response_time": f"{db_time:.3f}s",
                "connection": "active"
            }
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "response_time": f"{time.time() - start_time:.3f}s"
            }
    
    async def check_redis(self) -> Dict[str, Any]:
        """Check Redis connectivity and memory usage"""
        start_time = time.time()
        try:
            # Test connection
            self.redis_client.ping()
            
            # Get memory info
            info = self.redis_client.info('memory')
            memory_usage = info.get('used_memory_human', 'unknown')
            max_memory = info.get('maxmemory_human', 'unlimited')
            
            redis_time = time.time() - start_time
            
            return {
                "status": "healthy",
                "response_time": f"{redis_time:.3f}s",
                "memory_usage": memory_usage,
                "max_memory": max_memory,
                "connected_clients": info.get('connected_clients', 0)
            }
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "response_time": f"{time.time() - start_time:.3f}s"
            }
    
    async def check_external_services(self) -> Dict[str, Any]:
        """Check external service dependencies"""
        services = {}
        
        # Check CiviCRM API
        try:
            crm_url = os.getenv('CIVICRM_API_URL')
            if crm_url:
                start_time = time.time()
                response = requests.get(f"{crm_url}/ping", timeout=5)
                response_time = time.time() - start_time
                
                services['civicrm'] = {
                    "status": "healthy" if response.status_code == 200 else "unhealthy",
                    "response_time": f"{response_time:.3f}s",
                    "status_code": response.status_code
                }
        except Exception as e:
            services['civicrm'] = {
                "status": "unhealthy",
                "error": str(e)
            }
        
        # Check Stripe API
        try:
            stripe_key = os.getenv('STRIPE_PUBLISHABLE_KEY')
            if stripe_key:
                start_time = time.time()
                # Simple connectivity check
                response = requests.get("https://api.stripe.com/v1/account", timeout=5, headers={
                    "Authorization": f"Bearer {os.getenv('STRIPE_SECRET_KEY')}"
                })
                response_time = time.time() - start_time
                
                services['stripe'] = {
                    "status": "healthy" if response.status_code == 200 else "unhealthy",
                    "response_time": f"{response_time:.3f}s",
                    "status_code": response.status_code
                }
        except Exception as e:
            services['stripe'] = {
                "status": "unhealthy",
                "error": str(e)
            }
        
        return services
    
    def get_system_metrics(self) -> Dict[str, Any]:
        """Get system resource metrics"""
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # Memory usage
        memory = psutil.virtual_memory()
        
        # Disk usage
        disk = psutil.disk_usage('/')
        
        # Load average (Linux/Unix only)
        try:
            load_avg = os.getloadavg()
        except (OSError, AttributeError):
            load_avg = None
        
        uptime = datetime.utcnow() - self.startup_time
        
        return {
            "cpu_percent": cpu_percent,
            "memory": {
                "total": f"{memory.total / (1024**3):.2f}GB",
                "available": f"{memory.available / (1024**3):.2f}GB",
                "used_percent": memory.percent
            },
            "disk": {
                "total": f"{disk.total / (1024**3):.2f}GB",
                "free": f"{disk.free / (1024**3):.2f}GB",
                "used_percent": (disk.used / disk.total) * 100
            },
            "load_average": load_avg,
            "uptime": str(uptime).split('.')[0],  # Remove microseconds
            "startup_time": self.startup_time.isoformat()
        }

health_checker = HealthChecker()

@router.get("/health")
async def health_check():
    """Basic health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": health_checker.version,
        "uptime": str(datetime.utcnow() - health_checker.startup_time).split('.')[0]
    }

@router.get("/health/detailed")
async def detailed_health_check():
    """Detailed health check with all dependencies"""
    
    # Run all checks concurrently
    database_check = await health_checker.check_database()
    redis_check = await health_checker.check_redis()
    external_services = await health_checker.check_external_services()
    system_metrics = health_checker.get_system_metrics()
    
    # Determine overall status
    overall_status = "healthy"
    if (database_check["status"] == "unhealthy" or 
        redis_check["status"] == "unhealthy"):
        overall_status = "unhealthy"
    elif any(service["status"] == "unhealthy" for service in external_services.values()):
        overall_status = "degraded"
    
    response = {
        "status": overall_status,
        "timestamp": datetime.utcnow().isoformat(),
        "version": health_checker.version,
        "checks": {
            "database": database_check,
            "redis": redis_check,
            "external_services": external_services
        },
        "system": system_metrics
    }
    
    # Return appropriate HTTP status code
    status_code = 200
    if overall_status == "unhealthy":
        status_code = 503
    elif overall_status == "degraded":
        status_code = 200  # Still operational
    
    return JSONResponse(content=response, status_code=status_code)

@router.get("/health/readiness")
async def readiness_check():
    """Kubernetes-style readiness probe"""
    database_check = await health_checker.check_database()
    redis_check = await health_checker.check_redis()
    
    if (database_check["status"] == "healthy" and 
        redis_check["status"] == "healthy"):
        return {"status": "ready"}
    else:
        return JSONResponse(
            content={"status": "not ready", "checks": {
                "database": database_check,
                "redis": redis_check
            }},
            status_code=503
        )

@router.get("/health/liveness")
async def liveness_check():
    """Kubernetes-style liveness probe"""
    # Basic liveness - just return if the process is running
    return {
        "status": "alive",
        "timestamp": datetime.utcnow().isoformat(),
        "pid": os.getpid()
    }

@router.get("/metrics", dependencies=[Depends(get_current_user)])
async def metrics_endpoint():
    """Prometheus-compatible metrics endpoint (authenticated)"""
    metrics = health_checker.get_system_metrics()
    
    # Convert to Prometheus format
    prometheus_metrics = []
    
    # CPU metrics
    prometheus_metrics.append(f'api_cpu_usage_percent {metrics["cpu_percent"]}')
    
    # Memory metrics
    memory_used = float(metrics["memory"]["used_percent"])
    prometheus_metrics.append(f'api_memory_usage_percent {memory_used}')
    
    # Disk metrics
    disk_used = float(metrics["disk"]["used_percent"])
    prometheus_metrics.append(f'api_disk_usage_percent {disk_used}')
    
    # Uptime in seconds
    uptime_seconds = (datetime.utcnow() - health_checker.startup_time).total_seconds()
    prometheus_metrics.append(f'api_uptime_seconds {uptime_seconds}')
    
    return Response(
        content='\n'.join(prometheus_metrics),
        media_type='text/plain'
    )
```

## 4. Error Handling & Logging

### 4.1 Centralized Error Handling
```python
# api/error_handling.py
from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
import logging
import traceback
import uuid
from datetime import datetime
from typing import Dict, Any, Optional
import json

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

class ErrorLogger:
    def __init__(self):
        self.logger = logging.getLogger('api.errors')
        
        # Optional: Send to external logging service
        self.external_logging = os.getenv('EXTERNAL_LOGGING_URL')
    
    def log_error(
        self,
        error_id: str,
        error_type: str,
        message: str,
        request: Request,
        user_id: Optional[int] = None,
        extra_data: Optional[Dict] = None
    ):
        """Log error with structured data"""
        
        log_data = {
            "error_id": error_id,
            "error_type": error_type,
            "message": message,
            "timestamp": datetime.utcnow().isoformat(),
            "request": {
                "method": request.method,
                "url": str(request.url),
                "headers": dict(request.headers),
                "client_ip": request.client.host if request.client else None
            },
            "user_id": user_id
        }
        
        if extra_data:
            log_data["extra"] = extra_data
        
        # Remove sensitive headers
        sensitive_headers = ['authorization', 'cookie', 'x-api-key']
        for header in sensitive_headers:
            log_data["request"]["headers"].pop(header, None)
        
        self.logger.error(json.dumps(log_data))
        
        # Send to external service if configured
        if self.external_logging:
            self._send_to_external_service(log_data)
    
    def _send_to_external_service(self, log_data: Dict):
        """Send error data to external logging service"""
        try:
            import requests
            requests.post(
                self.external_logging,
                json=log_data,
                timeout=5,
                headers={'Content-Type': 'application/json'}
            )
        except Exception as e:
            self.logger.warning(f"Failed to send to external logging: {e}")

error_logger = ErrorLogger()

def create_error_response(
    error_id: str,
    message: str,
    status_code: int,
    error_code: Optional[str] = None,
    details: Optional[Dict] = None
) -> JSONResponse:
    """Create standardized error response"""
    
    response_data = {
        "error": {
            "id": error_id,
            "message": message,
            "code": error_code or f"HTTP_{status_code}",
            "timestamp": datetime.utcnow().isoformat()
        }
    }
    
    if details and os.getenv('DEBUG', 'false').lower() == 'true':
        response_data["error"]["details"] = details
    
    return JSONResponse(
        status_code=status_code,
        content=response_data
    )

# Global exception handlers
async def http_exception_handler(request: Request, exc: HTTPException):
    """Handle HTTP exceptions"""
    error_id = str(uuid.uuid4())
    
    error_logger.log_error(
        error_id=error_id,
        error_type="HTTPException",
        message=str(exc.detail),
        request=request,
        extra_data={"status_code": exc.status_code}
    )
    
    return create_error_response(
        error_id=error_id,
        message=str(exc.detail),
        status_code=exc.status_code,
        error_code=f"HTTP_{exc.status_code}"
    )

async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Handle request validation errors"""
    error_id = str(uuid.uuid4())
    
    error_logger.log_error(
        error_id=error_id,
        error_type="ValidationError",
        message="Request validation failed",
        request=request,
        extra_data={"validation_errors": exc.errors()}
    )
    
    return create_error_response(
        error_id=error_id,
        message="Request validation failed",
        status_code=422,
        error_code="VALIDATION_ERROR",
        details={"validation_errors": exc.errors()}
    )

async def general_exception_handler(request: Request, exc: Exception):
    """Handle all other exceptions"""
    error_id = str(uuid.uuid4())
    
    error_logger.log_error(
        error_id=error_id,
        error_type=type(exc).__name__,
        message=str(exc),
        request=request,
        extra_data={
            "traceback": traceback.format_exc() if os.getenv('DEBUG') == 'true' else None
        }
    )
    
    return create_error_response(
        error_id=error_id,
        message="Internal server error",
        status_code=500,
        error_code="INTERNAL_SERVER_ERROR"
    )

# Rate limiting exception
class RateLimitExceeded(HTTPException):
    def __init__(self, detail: str = "Rate limit exceeded"):
        super().__init__(status_code=429, detail=detail)

# Custom business logic exceptions
class BusinessLogicError(HTTPException):
    def __init__(self, message: str, error_code: str = "BUSINESS_ERROR"):
        super().__init__(status_code=400, detail=message)
        self.error_code = error_code

class AuthorizationError(HTTPException):
    def __init__(self, message: str = "Insufficient permissions"):
        super().__init__(status_code=403, detail=message)
```

## 5. Docker Security Hardening

### 5.1 Secure Dockerfile
```dockerfile
# Dockerfile.production
FROM python:3.11-slim-bullseye

# Security: Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Security: Update system packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Security: Set proper file permissions
COPY --chown=appuser:appuser requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=appuser:appuser . .

# Security: Create keys directory with proper permissions
RUN mkdir -p /app/keys && chown appuser:appuser /app/keys && chmod 700 /app/keys

# Security: Remove sensitive files that shouldn't be in container
RUN rm -rf .git .env* *.log

# Security: Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/status/health || exit 1

# Expose port
EXPOSE 8000

# Start application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

### 5.2 Secure Docker Compose Configuration
```yaml
# docker-compose.production.yml
version: '3.8'

services:
  fastapi:
    build:
      context: .
      dockerfile: Dockerfile.production
    container_name: crm-api
    restart: unless-stopped
    
    # Security: Read-only filesystem
    read_only: true
    
    # Security: Tmpfs for temporary files
    tmpfs:
      - /tmp:noexec,nosuid,size=100m
      - /app/logs:noexec,nosuid,size=50m
    
    # Security: Resource limits
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    
    # Security: Drop all capabilities, add only needed ones
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Only if binding to privileged ports
    
    # Security: No new privileges
    security_opt:
      - no-new-privileges:true
    
    # Security: User namespace remapping
    user: "1000:1000"
    
    environment:
      - ENVIRONMENT=production
      - DEBUG=false
      - JWT_KEYS_DIR=/app/keys
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=postgresql://user:pass@postgres:5432/crm_db
    
    # Security: Mount keys volume with proper permissions
    volumes:
      - jwt_keys:/app/keys:rw,noexec,nosuid,nodev
      - app_logs:/app/logs:rw,noexec,nosuid,nodev
    
    networks:
      - backend
      - frontend
    
    # Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/status/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    
    depends_on:
      - redis
      - postgres

  redis:
    image: redis:7-alpine
    container_name: crm-redis
    restart: unless-stopped
    
    # Security configurations
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - SETUID
      - SETGID
    
    # Redis security config
    command: >
      redis-server
      --requirepass ${REDIS_PASSWORD}
      --maxmemory 256mb
      --maxmemory-policy allkeys-lru
      --save 60 1000
      --appendonly yes
      --appendfsync everysec
    
    volumes:
      - redis_data:/data:rw,noexec,nosuid,nodev
      - /tmp:/tmp:rw,noexec,nosuid,size=50m
    
    networks:
      - backend
    
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    container_name: crm-nginx
    restart: unless-stopped
    
    # Security
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
      - CHOWN
      - SETUID
      - SETGID
    
    ports:
      - "443:443"
      - "80:80"
    
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - nginx_cache:/var/cache/nginx:rw,noexec,nosuid,nodev
      - nginx_logs:/var/log/nginx:rw,noexec,nosuid,nodev
      - /tmp:/tmp:rw,noexec,nosuid,size=50m
    
    networks:
      - frontend
    
    depends_on:
      - fastapi
    
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/status/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  jwt_keys:
    driver: local
    driver_opts:
      type: none
      device: /opt/crm/keys
      o: bind,uid=1000,gid=1000,mode=700
  
  redis_data:
    driver: local
    driver_opts:
      type: none
      device: /opt/crm/redis
      o: bind,uid=999,gid=999,mode=700
  
  nginx_cache:
    driver: local
  
  nginx_logs:
    driver: local
  
  app_logs:
    driver: local

networks:
  frontend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
  
  backend:
    driver: bridge
    internal: true  # No external access
    ipam:
      config:
        - subnet: 172.21.0.0/16
```

## 6. Implementation Checklist

### 6.1 Phase 1: JWT Security (Woche 1-2)
- [ ] RSA256-Algorithmus implementieren
- [ ] JWT Blacklisting mit Redis
- [ ] Token-Lebensdauer verkürzen (15min)
- [ ] Enhanced Claims (jti, aud, iss)
- [ ] Rate Limiting für Auth-Endpoints
- [ ] Account Lockout bei fehlgeschlagenen Versuchen

### 6.2 Phase 2: Key Rotation (Woche 2-3)
- [ ] Key Rotation Manager implementieren
- [ ] Automatische monatliche Rotation
- [ ] Overlap Period für nahtlose Übergänge
- [ ] Key Backup System
- [ ] Monitoring für Key-Status

### 6.3 Phase 3: Monitoring & Health (Woche 3-4)
- [ ] Health Check Endpoints
- [ ] System Metrics Collection
- [ ] External Service Monitoring
- [ ] Prometheus-kompatible Metriken
- [ ] Kubernetes Readiness/Liveness Probes

### 6.4 Phase 4: Error Handling (Woche 4)
- [ ] Strukturiertes Error Logging
- [ ] Centralized Exception Handling
- [ ] External Logging Integration
- [ ] Error ID Tracking
- [ ] Debug Mode Controls

### 6.5 Phase 5: Container Security (Woche 5)
- [ ] Non-root User Container
- [ ] Read-only Filesystem
- [ ] Capability Dropping
- [ ] Resource Limits
- [ ] Security Options (no-new-privileges)

## 7. Security Testing

### 7.1 JWT Security Tests
```python
# tests/test_jwt_security.py
import pytest
import jwt
import time
from datetime import datetime, timedelta
from auth.jwt_config import jwt_manager

def test_jwt_rsa256_signing():
    """Test RSA256 signing and verification"""
    data = {"user_id": 1, "permissions": ["read"]}
    token = jwt_manager.create_access_token(data, user_id=1)
    
    payload = jwt_manager.verify_token(token, "access")
    assert payload is not None
    assert payload["sub"] == "1"
    assert payload["type"] == "access"

def test_jwt_blacklisting():
    """Test token blacklisting functionality"""
    data = {"user_id": 1}
    token = jwt_manager.create_access_token(data, user_id=1)
    
    # Token should be valid
    payload = jwt_manager.verify_token(token, "access")
    assert payload is not None
    
    # Revoke token
    jwt_manager.revoke_token(token)
    
    # Token should now be invalid
    payload = jwt_manager.verify_token(token, "access")
    assert payload is None

def test_token_expiration():
    """Test token expiration"""
    # Create token with very short expiration
    original_expire = jwt_manager.access_token_expire
    jwt_manager.access_token_expire = timedelta(seconds=1)
    
    data = {"user_id": 1}
    token = jwt_manager.create_access_token(data, user_id=1)
    
    # Token should be valid immediately
    payload = jwt_manager.verify_token(token, "access")
    assert payload is not None
    
    # Wait for expiration
    time.sleep(2)
    
    # Token should be expired
    payload = jwt_manager.verify_token(token, "access")
    assert payload is None
    
    # Restore original expiration
    jwt_manager.access_token_expire = original_expire

def test_rate_limiting():
    """Test API rate limiting"""
    # Would require actual Redis instance for full test
    pass

@pytest.mark.asyncio
async def test_key_rotation():
    """Test key rotation process"""
    from auth.key_rotation import key_rotation_manager
    
    # Simulate key rotation
    old_public_key = jwt_manager.public_key
    await key_rotation_manager._perform_rotation()
    
    # Keys should be different
    assert jwt_manager.public_key != old_public_key
```

## 8. Performance Optimizations

### 8.1 Redis Connection Pooling
```python
# database/redis_pool.py
import redis.asyncio as redis
from redis.connection import ConnectionPool
import os

class RedisManager:
    def __init__(self):
        self.pool = ConnectionPool.from_url(
            os.getenv('REDIS_URL', 'redis://localhost:6379'),
            max_connections=20,
            retry_on_timeout=True,
            socket_timeout=5,
            socket_connect_timeout=5,
            health_check_interval=30
        )
        self.redis = redis.Redis(connection_pool=self.pool)
    
    async def close(self):
        """Close Redis connections"""
        await self.pool.disconnect()

redis_manager = RedisManager()

# Use in startup/shutdown events
async def startup_event():
    # Initialize connections
    await redis_manager.redis.ping()

async def shutdown_event():
    await redis_manager.close()
```

## 9. Deployment Success Metrics

### 9.1 Security Metrics
- JWT token lifetime: ≤ 15 Minuten
- Failed login lockout: ≤ 5 Attempts
- Key rotation frequency: 30 Tage
- API rate limit: 100 req/min/user
- Container security score: > 8/10 (Docker Bench)

### 9.2 Performance Metrics
- Health check response: < 200ms
- JWT verification time: < 10ms
- Redis connection time: < 50ms
- Database health check: < 100ms
- Memory usage: < 512MB baseline

### 9.3 Availability Metrics
- Uptime target: 99.9%
- Health check success rate: > 99%
- Zero-downtime key rotation: ✅
- Container restart time: < 30s
- Service discovery time: < 10s

---

**Nächste Schritte:**
1. JWT Security Implementation starten
2. Redis Blacklisting konfigurieren  
3. Health Endpoints deployen
4. Container Security testen
5. Monitoring Dashboard einrichten

**Abhängigkeiten:**
- Redis Server (läuft bereits)
- Let's Encrypt Zertifikate
- Plesk Docker Support
- SSL/TLS Konfiguration

**Estimated Aufwand:** 5-7 Tage für vollständige Implementation