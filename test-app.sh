#!/bin/bash

# Cloqr App - Quick Test Script
# This script tests all critical endpoints and functionality

echo "🧪 Cloqr App - Running Tests..."
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Function to test endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local method=${3:-GET}
    local data=$4
    
    echo -n "Testing $name... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$url")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "${GREEN}✅ PASSED${NC} (HTTP $http_code)"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC} (HTTP $http_code)"
        echo "   Response: $body"
        ((FAILED++))
        return 1
    fi
}

# Test database connection
echo "📊 Testing Database..."
if psql -U brian -d cloqr -c "SELECT 1" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Database connected${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ Database connection failed${NC}"
    ((FAILED++))
fi

# Test Redis connection
echo ""
echo "🔴 Testing Redis..."
if redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Redis connected${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ Redis connection failed${NC}"
    ((FAILED++))
fi

# Test backend endpoints
echo ""
echo "🌐 Testing Backend Endpoints..."
BASE_URL="http://localhost:3000"

test_endpoint "Health Check" "$BASE_URL/health"
test_endpoint "Email Config" "$BASE_URL/api/test/email-config"

# Test campus QR codes exist
echo ""
echo "🎓 Testing Campus Data..."
echo -n "Checking campus QR codes... "
qr_count=$(psql -U brian -d cloqr -t -c "SELECT COUNT(*) FROM campus_qr_codes WHERE is_active = true" 2>/dev/null | xargs)
if [ "$qr_count" -gt 0 ]; then
    echo -e "${GREEN}✅ PASSED${NC} ($qr_count active QR codes)"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED${NC} (No active QR codes found)"
    ((FAILED++))
fi

# Test users table
echo -n "Checking users table... "
user_count=$(psql -U brian -d cloqr -t -c "SELECT COUNT(*) FROM users" 2>/dev/null | xargs)
if [ "$user_count" -ge 0 ]; then
    echo -e "${GREEN}✅ PASSED${NC} ($user_count users)"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED${NC}"
    ((FAILED++))
fi

# Test Flutter app
echo ""
echo "📱 Testing Flutter App..."
cd mobile > /dev/null 2>&1

echo -n "Running Flutter analyze... "
if flutter analyze 2>&1 | grep -q "No issues found"; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED${NC}"
    ((FAILED++))
fi

echo -n "Checking dependencies... "
if flutter pub get > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED${NC}"
    ((FAILED++))
fi

cd .. > /dev/null 2>&1

# Test backend dependencies
echo ""
echo "📦 Testing Backend Dependencies..."
cd cloqr-backend > /dev/null 2>&1

echo -n "Checking Node modules... "
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠️  WARNING${NC} (Run 'npm install')"
fi

echo -n "Checking syntax... "
if node -c src/server.js > /dev/null 2>&1; then
    echo -e "${GREEN}✅ PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAILED${NC}"
    ((FAILED++))
fi

cd .. > /dev/null 2>&1

# Summary
echo ""
echo "================================"
echo "📊 Test Summary"
echo "================================"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! Your app is ready to use.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Start backend: cd cloqr-backend && npm start"
    echo "2. Run mobile app: cd mobile && flutter run"
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed. Please check the errors above.${NC}"
    exit 1
fi
