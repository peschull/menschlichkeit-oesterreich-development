#!/bin/bash
# Redis Caching Setup for Austrian NGO Platform

echo "Setting up Redis caching..."

# Install Redis (if not available)
if ! command -v redis-server &> /dev/null; then
    echo "Redis not found - would install in production"
fi

# Create cache configuration
mkdir -p config/cache

cat > config/cache/redis.conf << 'REDIS_EOF'
# Redis Configuration for Menschlichkeit Österreich
port 6379
bind 127.0.0.1
timeout 300
save 900 1
save 300 10
save 60 10000
maxmemory 256mb
maxmemory-policy allkeys-lru
REDIS_EOF

echo "✅ Redis cache configuration created"
