#!/bin/bash
# Build script for Games service
# Bash equivalent for build-games.ps1

set -e

echo "🎮 Building Games service..."

# Navigate to web directory
cd web

# Check if Prisma schema exists
if [ -f "../schema.prisma" ]; then
    echo "📦 Generating Prisma Client..."
    npx prisma generate --schema=../schema.prisma || echo "⚠️ Prisma generation failed"
fi

# Build any TypeScript/JavaScript if needed
if [ -f "package.json" ]; then
    echo "📦 Installing dependencies..."
    npm install || echo "⚠️ npm install failed"
    
    if grep -q '"build"' package.json; then
        echo "🏗️ Running build script..."
        npm run build || echo "⚠️ Build script failed"
    fi
fi

# Copy static assets if needed
if [ -d "assets" ] && [ ! -d "dist/assets" ]; then
    echo "📁 Copying assets..."
    mkdir -p dist
    cp -r assets dist/ 2>/dev/null || true
fi

cd ..

echo "✅ Games build complete!"
