@echo off
REM Web Stack MCP Server Installer and Manager
echo Installing Web Stack MCP Servers...

REM Navigate to web-stack directory
cd /d "d:\Arbeitsverzeichniss\mcp-servers\web-stack"

REM Install main dependencies
echo Installing main dependencies...
call npm install

REM Install workspace dependencies
echo Installing workspace dependencies...
call npm install --workspaces

REM Build all servers
echo Building all servers...
call npm run build

echo.
echo Web Stack MCP Servers installed successfully!
echo.
echo Available servers:
echo - Plesk OpenAPI Server (plesk-openapi)
echo - WordPress REST API Server (wordpress)  
echo - Laravel Integration Server (laravel)
echo.
echo To start all servers: npm run start:all
echo To start individual servers:
echo - npm run start:plesk
echo - npm run start:wordpress
echo - npm run start:laravel
echo.
pause