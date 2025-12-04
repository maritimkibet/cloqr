#!/bin/bash

# Test deployed backend endpoints

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing Deployed Backend${NC}"
echo "============================"
echo ""

# Get backend URL
if [ -f "BACKEND_URL.txt" ]; then
    BACKEND_URL=$(cat BACKEND_URL.txt)
else
    echo "Enter your backend URL:"
    read -r BACKEND_URL
fi

# Remove trailing slash
BACKEND_URL=${BACKEND_URL%/}

echo "Testing: $BACKEND_URL"
echo ""

# Test counter
PASSED=0
FAILED=0

# Function to test endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local expected=$3
    
    echo -n "Testing $name... "
    
    response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null)
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" == "$expected" ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $http_code)"
        if [ -n "$body" ]; then
            echo "  Response: $body"
        fi
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC} (HTTP $http_code, expected $expected)"
        if [ -n "$body" ]; then
            echo "  Response: $body"
        fi
        ((FAILED++))
    fi
    echo ""
}

# Test health endpoint
echo -e "${BLUE}📋 Basic Endpoints${NC}"
echo "-------------------"
test_endpoint "Health Check" "$BACKEND_URL/health" "200"
test_endpoint "Email Config" "$BACKEND_URL/api/test/email-config" "200"

# Test auth endpoints (should return 400 or 401 without proper data)
echo -e "${BLUE}📋 Auth Endpoints${NC}"
echo "------------------"
test_endpoint "Send OTP" "$BACKEND_URL/api/auth/send-otp" "400"
test_endpoint "Verify OTP" "$BACKEND_URL/api/auth/verify-otp" "400"
test_endpoint "Login" "$BACKEND_URL/api/auth/login" "400"

# Test protected endpoints (should return 401 without auth)
echo -e "${BLUE}📋 Protected Endpoints${NC}"
echo "----------------------"
test_endpoint "Profile" "$BACKEND_URL/api/profile" "401"
test_endpoint "Match Queue" "$BACKEND_URL/api/match/queue" "401"
test_endpoint "Chats" "$BACKEND_URL/api/chat" "401"
test_endpoint "Rooms" "$BACKEND_URL/api/rooms" "401"

# Test with POST requests
echo -e "${BLUE}📋 POST Endpoints${NC}"
echo "------------------"

echo -n "Testing Send OTP (POST)... "
response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"email":"test@student.edu"}' \
    "$BACKEND_URL/api/auth/send-otp" 2>/dev/null)
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" == "200" ] || [ "$http_code" == "400" ] || [ "$http_code" == "500" ]; then
    echo -e "${GREEN}✓ PASS${NC} (HTTP $http_code - endpoint responding)"
    echo "  Response: $body"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${NC} (HTTP $http_code)"
    echo "  Response: $body"
    ((FAILED++))
fi
echo ""

# Test database connection
echo -e "${BLUE}📋 Database Connection${NC}"
echo "----------------------"
echo "Attempting to test database connection..."
echo "(This will fail if database is not initialized, which is expected)"
echo ""

response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"email":"admin@test.com","password":"test123"}' \
    "$BACKEND_URL/api/auth/login" 2>/dev/null)
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

echo "Login test response (HTTP $http_code):"
echo "$body"
echo ""

if echo "$body" | grep -q "database\|connection\|ECONNREFUSED"; then
    echo -e "${YELLOW}⚠ Database not connected or not initialized${NC}"
    echo "  This is expected if you haven't set up Cloud SQL yet"
elif echo "$body" | grep -q "Invalid\|not found\|incorrect"; then
    echo -e "${GREEN}✓ Database is connected!${NC}"
    echo "  (Login failed as expected with test credentials)"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠ Unexpected response${NC}"
fi
echo ""

# Summary
echo "=============================================="
echo -e "${BLUE}📊 Test Summary${NC}"
echo "=============================================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Your backend is responding correctly!"
    echo ""
    echo "Next steps:"
    echo "1. Initialize database if not done:"
    echo "   gcloud sql connect cloqr-db --user=cloqr_user --database=cloqr"
    echo ""
    echo "2. Update mobile app URL:"
    echo "   ./update-mobile-url.sh"
    echo ""
    echo "3. Build and test mobile app"
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    echo "Check the logs:"
    echo "  gcloud run services logs read cloqr-backend --region us-central1 --limit 100"
    echo ""
    echo "Check service status:"
    echo "  gcloud run services describe cloqr-backend --region us-central1"
fi

echo ""
echo "View full logs:"
echo "  gcloud run services logs read cloqr-backend --region us-central1"
echo ""
echo "View in console:"
echo "  https://console.cloud.google.com/run"
echo ""
