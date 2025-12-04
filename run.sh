#!/bin/bash

echo "🚀 CloQR Quick Start"
echo ""

# Check what to run
if [ "$1" == "backend" ]; then
    echo "Starting backend..."
    cd cloqr-backend
    node src/server.js
elif [ "$1" == "mobile" ]; then
    echo "Starting mobile app..."
    cd mobile
    flutter run
elif [ "$1" == "build" ]; then
    echo "Building mobile app..."
    cd mobile
    flutter build apk --release
    echo "✅ APK: mobile/build/app/outputs/flutter-apk/app-release.apk"
else
    echo "Usage:"
    echo "  ./run.sh backend  - Start backend server"
    echo "  ./run.sh mobile   - Run mobile app"
    echo "  ./run.sh build    - Build APK"
fi
