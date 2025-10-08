"""
FastAPI Application für Menschlichkeit Österreich
Hauptanwendung mit CiviCRM Integration, JWT Authentication und Privacy API.
"""

import logging
import os
import time
import uuid
from typing import Optional, List, Dict, Any

import httpx
import jwt
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Depends, Path
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr

from app.routes.privacy import router as privacy_router
from app.shared import ApiResponse, verify_jwt_token

# Load environment variables from .env file
load_dotenv()

# Environment Configuration
logger = logging.getLogger("moe-api.config")
