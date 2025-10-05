#!/bin/bash
# API Start Script with Environment Variables

export DATABASE_URL='mysql://svc_api_stg:APISTG_SecurePass_2024_def456VWX!@localhost:3306/mo_api_stg'
export JWT_SECRET='IX1tw8iy0C7VBBJsU5++ZrzZikammAueFFmQ7rvtaEQ='
export JWT_ALGORITHM='HS256'
export ACCESS_TOKEN_EXPIRE_MINUTES='30'
export API_HOST='0.0.0.0'
export API_PORT='8000'
export API_RELOAD='true'
export CORS_ORIGINS='http://localhost:3000,https://menschlichkeit-oesterreich.at'
export ENVIRONMENT='development'
export DEBUG='true'
export LOG_LEVEL='INFO'
export CIVI_SITE_KEY='92f7579c2dfbf9f31ad92ea4c2f73ea05f6bdc7446db8bb8c7089f1de4a8d2b3'
export CIVI_API_KEY=$(openssl rand -hex 32)
export CIVI_DB_HOST='localhost'
export CIVI_DB_PORT='3306'
export CIVI_DB_NAME='mo_crm'
export CIVI_DB_USER='svc_crm'
export CIVI_DB_PASS='CRM_SecurePass_2024_xyz123ABC!'
export CIVI_BASE_URL='https://crm.menschlichkeit-oesterreich.at'

echo "🚀 Starting FastAPI Server..."
echo "📍 API will be available at: http://localhost:8000"
echo "📚 Swagger UI: http://localhost:8000/docs"
echo ""

uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
