"""
Patient Portal Backend API

A comprehensive healthcare patient portal API built with FastAPI.
Provides endpoints for patient data, appointments, lab results, medications, and messaging.
"""

from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
import structlog
import time
from contextlib import asynccontextmanager

from app.core.config import settings
from app.core.database import engine, create_tables
from app.api.v1.api import api_router
from app.core.exceptions import PatientPortalException


# Configure structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events"""
    # Startup
    logger.info("Starting Patient Portal API")
    await create_tables()
    logger.info("Database tables created/verified")
    
    yield
    
    # Shutdown
    logger.info("Shutting down Patient Portal API")
    await engine.dispose()


# Create FastAPI application
app = FastAPI(
    title="Patient Portal API",
    description="Healthcare patient portal backend API providing secure access to patient data, appointments, lab results, medications, and provider communication.",
    version="1.0.0",
    docs_url="/docs" if settings.ENVIRONMENT != "production" else None,
    redoc_url="/redoc" if settings.ENVIRONMENT != "production" else None,
    lifespan=lifespan,
    openapi_tags=[
        {
            "name": "authentication",
            "description": "User authentication and authorization"
        },
        {
            "name": "patients",
            "description": "Patient profile and personal information"
        },
        {
            "name": "appointments",
            "description": "Medical appointments management"
        },
        {
            "name": "lab-results",
            "description": "Laboratory test results and analysis"
        },
        {
            "name": "medications",
            "description": "Prescription medications and dosage information"
        },
        {
            "name": "messages",
            "description": "Secure messaging with healthcare providers"
        },
        {
            "name": "dashboard",
            "description": "Patient dashboard and overview data"
        },
        {
            "name": "health",
            "description": "Application health and monitoring"
        }
    ]
)

# Security middleware
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=settings.ALLOWED_HOSTS
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["*"],
)


# Request logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Log all HTTP requests with timing and metadata"""
    start_time = time.time()
    
    # Extract request metadata
    request_id = request.headers.get("X-Request-ID", "unknown")
    user_agent = request.headers.get("User-Agent", "unknown")
    client_ip = request.client.host if request.client else "unknown"
    
    # Log request start
    logger.info(
        "Request started",
        method=request.method,
        url=str(request.url),
        request_id=request_id,
        client_ip=client_ip,
        user_agent=user_agent
    )
    
    # Process request
    response = await call_next(request)
    
    # Calculate processing time
    process_time = time.time() - start_time
    
    # Log request completion
    logger.info(
        "Request completed",
        method=request.method,
        url=str(request.url),
        status_code=response.status_code,
        process_time=round(process_time, 4),
        request_id=request_id
    )
    
    # Add timing header
    response.headers["X-Process-Time"] = str(process_time)
    response.headers["X-Request-ID"] = request_id
    
    return response


# Exception handlers
@app.exception_handler(PatientPortalException)
async def patient_portal_exception_handler(request: Request, exc: PatientPortalException):
    """Handle custom application exceptions"""
    logger.error(
        "Application exception",
        error_code=exc.error_code,
        message=exc.message,
        details=exc.details,
        url=str(request.url)
    )
    
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "code": exc.error_code,
                "message": exc.message,
                "details": exc.details
            },
            "meta": {
                "timestamp": time.time(),
                "request_id": request.headers.get("X-Request-ID", "unknown")
            }
        }
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Handle request validation errors"""
    logger.warning(
        "Validation error",
        errors=exc.errors(),
        url=str(request.url)
    )
    
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "success": False,
            "error": {
                "code": "VALIDATION_ERROR",
                "message": "Request validation failed",
                "details": exc.errors()
            },
            "meta": {
                "timestamp": time.time(),
                "request_id": request.headers.get("X-Request-ID", "unknown")
            }
        }
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Handle unexpected exceptions"""
    logger.error(
        "Unexpected error",
        error=str(exc),
        error_type=type(exc).__name__,
        url=str(request.url),
        exc_info=True
    )
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "error": {
                "code": "INTERNAL_SERVER_ERROR",
                "message": "An unexpected error occurred",
                "details": None
            },
            "meta": {
                "timestamp": time.time(),
                "request_id": request.headers.get("X-Request-ID", "unknown")
            }
        }
    )


# Health check endpoint
@app.get("/health", tags=["health"])
async def health_check():
    """Health check endpoint for load balancers and monitoring"""
    return {
        "success": True,
        "data": {
            "status": "healthy",
            "version": "1.0.0",
            "environment": settings.ENVIRONMENT
        },
        "meta": {
            "timestamp": time.time()
        }
    }


# Include API routes
app.include_router(api_router, prefix="/api/v1")


# Root endpoint
@app.get("/", tags=["health"])
async def root():
    """Root endpoint with API information"""
    return {
        "success": True,
        "data": {
            "name": "Patient Portal API",
            "version": "1.0.0",
            "description": "Healthcare patient portal backend API",
            "docs_url": "/docs" if settings.ENVIRONMENT != "production" else None,
            "health_url": "/health"
        },
        "meta": {
            "timestamp": time.time()
        }
    }


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.ENVIRONMENT == "development",
        log_config=None  # Use structlog instead
    )
