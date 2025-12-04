#!/bin/bash

# Script to update mobile app API URL after Firebase deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📱 Update Mobile App URL${NC}"
echo "========================"
echo ""

# Check if BACKEND_URL.txt exists
if [ -f "BACKEND_URL.txt" ]; then
    BACKEND_URL=$(cat BACKEND_URL.txt)
    echo -e "${GREEN}Found backend URL: $BACKEND_URL${NC}"
else
    echo -e "${YELLOW}Backend URL not found in file.${NC}"
    echo "Enter your Cloud Run backend URL:"
    read -r BACKEND_URL
fi

# Remove trailing slash if present
BACKEND_URL=${BACKEND_URL%/}

# Backup original file
cp mobile/lib/config/api_config.dart mobile/lib/config/api_config.dart.backup
echo -e "${GREEN}✓ Backed up original api_config.dart${NC}"

# Create new api_config.dart
cat > mobile/lib/config/api_config.dart << EOF
class ApiConfig {
  // PRODUCTION: Cloud Run URL
  static const String baseUrl = '$BACKEND_URL/api';
  static const String socketUrl = '$BACKEND_URL';
  
  // Auth endpoints
  static const String sendOtp = '\$baseUrl/auth/send-otp';
  static const String verifyOtp = '\$baseUrl/auth/verify-otp';
  static const String register = '\$baseUrl/auth/register';
  static const String login = '\$baseUrl/auth/login';
  static const String setupPin = '\$baseUrl/auth/setup-pin';
  static const String verifyPin = '\$baseUrl/auth/verify-pin';
  
  // Profile endpoints
  static const String profile = '\$baseUrl/profile';
  static const String selectAvatar = '\$baseUrl/profile/avatar';
  static const String uploadPhoto = '\$baseUrl/profile/photo';
  static const String reportUser = '\$baseUrl/profile/report';
  static const String blockUser = '\$baseUrl/profile/block';
  
  // Match endpoints
  static const String matchQueue = '\$baseUrl/match/queue';
  static const String swipe = '\$baseUrl/match/swipe';
  static const String matches = '\$baseUrl/match/matches';
  static const String studyPartners = '\$baseUrl/match/study-partners';
  
  // Chat endpoints
  static const String chats = '\$baseUrl/chat';
  static const String createChat = '\$baseUrl/chat/create';
  
  // Room endpoints
  static const String rooms = '\$baseUrl/rooms';
  static const String createRoom = '\$baseUrl/rooms/create';
  static const String joinRoom = '\$baseUrl/rooms/join';
}
EOF

echo -e "${GREEN}✓ Updated api_config.dart with production URL${NC}"
echo ""
echo "Base URL: $BACKEND_URL/api"
echo "Socket URL: $BACKEND_URL"
echo ""

# Ask if user wants to build APK
echo -e "${YELLOW}Do you want to build the release APK now? (y/n)${NC}"
read -r BUILD_APK

if [ "$BUILD_APK" == "y" ] || [ "$BUILD_APK" == "Y" ]; then
    echo -e "${BLUE}🔨 Building release APK...${NC}"
    cd mobile
    
    flutter clean
    flutter pub get
    flutter build apk --release
    
    echo ""
    echo -e "${GREEN}✓ APK built successfully!${NC}"
    echo "Location: mobile/build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    
    # Get APK size
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    echo "APK size: $APK_SIZE"
    
    cd ..
fi

echo ""
echo -e "${GREEN}✓ Done!${NC}"
echo ""
echo "To restore original URL:"
echo "  mv mobile/lib/config/api_config.dart.backup mobile/lib/config/api_config.dart"
echo ""
