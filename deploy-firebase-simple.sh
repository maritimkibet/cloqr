#!/bin/bash

echo "🚀 Cloqr Firebase Deployment Script"
echo "===================================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    npm install -g firebase-tools
fi

# Check if logged in to Firebase
echo "📝 Checking Firebase login..."
firebase projects:list &> /dev/null
if [ $? -ne 0 ]; then
    echo "🔐 Please login to Firebase..."
    firebase login
fi

# Check if .env exists
if [ ! -f "cloqr-backend/.env" ]; then
    echo "❌ .env file not found in cloqr-backend/"
    echo "Please create .env file with your configuration"
    exit 1
fi

echo ""
echo "📦 Step 1: Preparing backend for deployment..."
cd cloqr-backend

# Initialize Firebase if not already done
if [ ! -f "firebase.json" ]; then
    echo "🔧 Initializing Firebase..."
    echo "Please select:"
    echo "  - Functions"
    echo "  - Hosting"
    echo "Then follow the prompts..."
    firebase init
fi

echo ""
echo "📤 Step 2: Deploying to Firebase..."
firebase deploy --only functions

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Backend deployed successfully!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Copy your Firebase Functions URL"
    echo "2. Update mobile/lib/config/api_config.dart with the URL"
    echo "3. Run: cd mobile && flutter build apk --release"
    echo "4. Share the APK from: mobile/build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "🔗 View your functions at:"
    firebase functions:list
else
    echo ""
    echo "❌ Deployment failed. Check the errors above."
    echo "Run 'firebase functions:log' to see detailed logs"
fi
