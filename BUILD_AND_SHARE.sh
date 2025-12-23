#!/bin/bash

# Cloqr App - Build and Share Script
# This script builds the release APK and prepares it for sharing

echo "🚀 Building Cloqr App for Sharing..."
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -d "mobile" ]; then
    echo -e "${RED}❌ Error: mobile directory not found${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Step 1: Clean previous builds
echo -e "${BLUE}📦 Step 1: Cleaning previous builds...${NC}"
cd mobile
flutter clean
echo -e "${GREEN}✅ Clean complete${NC}"
echo ""

# Step 2: Get dependencies
echo -e "${BLUE}📦 Step 2: Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Step 3: Build release APK
echo -e "${BLUE}🔨 Step 3: Building release APK...${NC}"
echo "This may take 3-5 minutes..."
echo ""

flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ APK built successfully!${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Build failed. Check errors above.${NC}"
    exit 1
fi

# Step 4: Show APK location and size
echo -e "${BLUE}📱 Step 4: APK Information${NC}"
echo "=================================="

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    APK_FULL_PATH=$(realpath "$APK_PATH")
    
    echo -e "${GREEN}✅ APK Location:${NC}"
    echo "   $APK_FULL_PATH"
    echo ""
    echo -e "${GREEN}✅ APK Size:${NC} $APK_SIZE"
    echo ""
    
    # Step 5: Copy to easy location
    echo -e "${BLUE}📋 Step 5: Copying APK to easy location...${NC}"
    cp "$APK_PATH" "../cloqr-app.apk"
    
    if [ -f "../cloqr-app.apk" ]; then
        echo -e "${GREEN}✅ APK copied to: $(realpath ../cloqr-app.apk)${NC}"
        echo ""
    fi
else
    echo -e "${RED}❌ APK file not found${NC}"
    exit 1
fi

cd ..

# Step 6: Show sharing instructions
echo ""
echo "=================================="
echo -e "${GREEN}🎉 BUILD COMPLETE!${NC}"
echo "=================================="
echo ""
echo -e "${YELLOW}📱 APK Ready to Share:${NC}"
echo "   File: cloqr-app.apk"
echo "   Size: $APK_SIZE"
echo ""
echo -e "${YELLOW}📤 How to Share:${NC}"
echo ""
echo "Option 1: Google Drive"
echo "  1. Upload cloqr-app.apk to Google Drive"
echo "  2. Set sharing to 'Anyone with link'"
echo "  3. Share the link"
echo ""
echo "Option 2: WhatsApp/Telegram"
echo "  1. Send cloqr-app.apk as file"
echo "  2. Users download and install"
echo ""
echo "Option 3: USB Transfer"
echo "  1. Connect phone via USB"
echo "  2. Copy cloqr-app.apk to phone"
echo "  3. Open file and install"
echo ""
echo -e "${YELLOW}📋 Campus QR Codes to Share:${NC}"
echo "  • University of Nairobi: sample_uon_qr_code_12345"
echo "  • Kenyatta University: sample_ku_qr_code_67890"
echo "  • Strathmore University: sample_su_qr_code_abcde"
echo "  • Masinde Muliro: de79e47648eea42488bab3dedea4bf6a"
echo "  • MMUST: 19fb6d582d42a474d9333581ca9b756f"
echo ""
echo -e "${GREEN}✅ Production Ready:${NC}"
echo "  • Backend deployed at: https://cloqr-backend.onrender.com"
echo "  • Users can connect from anywhere with internet"
echo "  • No WiFi network restrictions"
echo ""
echo -e "${GREEN}✅ Your app is ready to share!${NC}"
echo ""
