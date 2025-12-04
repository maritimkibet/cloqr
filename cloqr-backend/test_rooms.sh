#!/bin/bash

# Test script for room endpoints
# Make sure the server is running before executing this

BASE_URL="http://localhost:3000/api"
TOKEN="your_jwt_token_here"

echo "🧪 Testing Room Endpoints..."
echo ""

# Test 1: Get all rooms
echo "1️⃣ Testing GET /rooms"
curl -X GET "$BASE_URL/rooms" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
echo -e "\n"

# Test 2: Create a room
echo "2️⃣ Testing POST /rooms/create"
curl -X POST "$BASE_URL/rooms/create" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Study Room",
    "roomType": "study",
    "duration": 24
  }'
echo -e "\n"

# Test 3: Join a room (replace QR_CODE with actual code from step 2)
echo "3️⃣ Testing POST /rooms/join"
echo "Note: Replace QR_CODE with actual code from room creation"
# curl -X POST "$BASE_URL/rooms/join" \
#   -H "Authorization: Bearer $TOKEN" \
#   -H "Content-Type: application/json" \
#   -d '{"qrCode": "QR_CODE"}'
echo -e "\n"

echo "✅ Room endpoint tests complete!"
echo ""
echo "🔧 Admin Endpoints Test..."
echo ""

# Test 4: Get statistics (admin only)
echo "4️⃣ Testing GET /admin/statistics"
curl -X GET "$BASE_URL/admin/statistics" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
echo -e "\n"

echo "✅ All tests complete!"
