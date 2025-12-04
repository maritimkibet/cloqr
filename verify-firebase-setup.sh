#!/bin/bash

# Firebase/Google Cloud Setup Verification Script
# This script checks if everything is configured correctly for deployment

set -e

echo "🔍 Verifying Firebase/Google Cloud Setup..."
echo "=============================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $2"
        ((FAILED++))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

echo "📋 Phase 1: Prerequisites"
echo "-------------------------"

# Check gcloud CLI
if command -v gcloud &> /dev/null; then
    print_status 0 "gcloud CLI installed"
    GCLOUD_VERSION=$(gcloud --version | head -n 1)
    echo "  Version: $GCLOUD_VERSION"
else
    print_status 1 "gcloud CLI not installed"
    echo "  Install: curl https://sdk.cloud.google.com | bash"
fi

# Check if logged in
if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | head -n 1)
    if [ -n "$ACCOUNT" ]; then
        print_status 0 "Logged in to Google Cloud"
        echo "  Account: $ACCOUNT"
    else
        print_status 1 "Not logged in to Google Cloud"
        echo "  Run: gcloud auth login"
    fi
else
    print_status 1 "Not logged in to Google Cloud"
    echo "  Run: gcloud auth login"
fi

# Check active project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "(unset)" ]; then
    print_status 0 "Active project set"
    echo "  Project ID: $PROJECT_ID"
else
    print_status 1 "No active project set"
    echo "  Run: gcloud config set project YOUR_PROJECT_ID"
fi

# Check Flutter
if command -v flutter &> /dev/null; then
    print_status 0 "Flutter installed"
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo "  Version: $FLUTTER_VERSION"
else
    print_status 1 "Flutter not installed"
fi

# Check Node.js
if command -v node &> /dev/null; then
    print_status 0 "Node.js installed"
    NODE_VERSION=$(node --version)
    echo "  Version: $NODE_VERSION"
else
    print_status 1 "Node.js not installed"
fi

echo ""
echo "📋 Phase 2: Backend Configuration"
echo "----------------------------------"

# Check Dockerfile
if [ -f "cloqr-backend/Dockerfile" ]; then
    print_status 0 "Dockerfile exists"
    
    # Check if it uses correct port
    if grep -q "EXPOSE 8080" cloqr-backend/Dockerfile; then
        print_status 0 "Dockerfile exposes port 8080 (Cloud Run compatible)"
    else
        print_warning "Dockerfile should expose port 8080 for Cloud Run"
    fi
else
    print_status 1 "Dockerfile missing"
fi

# Check .dockerignore
if [ -f "cloqr-backend/.dockerignore" ]; then
    print_status 0 ".dockerignore exists"
else
    print_warning ".dockerignore missing (recommended)"
fi

# Check server.js
if [ -f "cloqr-backend/src/server.js" ]; then
    print_status 0 "server.js exists"
    
    # Check if it uses PORT env variable
    if grep -q "process.env.PORT" cloqr-backend/src/server.js; then
        print_status 0 "server.js uses PORT environment variable"
    else
        print_warning "server.js should use process.env.PORT for Cloud Run"
    fi
    
    # Check if it listens on 0.0.0.0
    if grep -q "0.0.0.0" cloqr-backend/src/server.js; then
        print_status 0 "server.js listens on 0.0.0.0"
    else
        print_warning "server.js should listen on 0.0.0.0"
    fi
else
    print_status 1 "server.js missing"
fi

# Check package.json
if [ -f "cloqr-backend/package.json" ]; then
    print_status 0 "package.json exists"
    
    # Check for required dependencies
    if grep -q "express" cloqr-backend/package.json; then
        print_status 0 "Express dependency found"
    fi
    
    if grep -q "pg" cloqr-backend/package.json; then
        print_status 0 "PostgreSQL dependency found"
    fi
    
    if grep -q "redis" cloqr-backend/package.json; then
        print_status 0 "Redis dependency found"
    fi
else
    print_status 1 "package.json missing"
fi

# Check database config
if [ -f "cloqr-backend/src/config/database.js" ]; then
    print_status 0 "Database config exists"
    
    # Check if it uses environment variables
    if grep -q "process.env.DB_HOST" cloqr-backend/src/config/database.js; then
        print_status 0 "Database config uses environment variables"
    fi
else
    print_status 1 "Database config missing"
fi

# Check Redis config
if [ -f "cloqr-backend/src/config/redis.js" ]; then
    print_status 0 "Redis config exists"
    
    # Check if it uses environment variables
    if grep -q "process.env.REDIS_HOST" cloqr-backend/src/config/redis.js; then
        print_status 0 "Redis config uses environment variables"
    fi
else
    print_status 1 "Redis config missing"
fi

echo ""
echo "📋 Phase 3: Mobile App Configuration"
echo "-------------------------------------"

# Check pubspec.yaml
if [ -f "mobile/pubspec.yaml" ]; then
    print_status 0 "pubspec.yaml exists"
else
    print_status 1 "pubspec.yaml missing"
fi

# Check api_config.dart
if [ -f "mobile/lib/config/api_config.dart" ]; then
    print_status 0 "api_config.dart exists"
    
    # Check if it's still using local IP
    if grep -q "192.168" mobile/lib/config/api_config.dart; then
        print_warning "api_config.dart still uses local IP address"
        echo "  Update baseUrl to your Cloud Run URL after deployment"
    elif grep -q "localhost" mobile/lib/config/api_config.dart; then
        print_warning "api_config.dart uses localhost"
        echo "  Update baseUrl to your Cloud Run URL after deployment"
    elif grep -q "run.app" mobile/lib/config/api_config.dart; then
        print_status 0 "api_config.dart uses Cloud Run URL"
    else
        print_warning "api_config.dart URL format unclear"
    fi
else
    print_status 1 "api_config.dart missing"
fi

# Check Android configuration
if [ -f "mobile/android/app/build.gradle" ]; then
    print_status 0 "Android build.gradle exists"
else
    print_status 1 "Android build.gradle missing"
fi

if [ -f "mobile/android/app/src/main/AndroidManifest.xml" ]; then
    print_status 0 "AndroidManifest.xml exists"
    
    # Check for internet permission
    if grep -q "android.permission.INTERNET" mobile/android/app/src/main/AndroidManifest.xml; then
        print_status 0 "Internet permission declared"
    else
        print_status 1 "Internet permission missing"
    fi
else
    print_status 1 "AndroidManifest.xml missing"
fi

echo ""
echo "📋 Phase 4: Environment Variables"
echo "----------------------------------"

# Check .env file
if [ -f "cloqr-backend/.env" ]; then
    print_status 0 ".env file exists"
    
    # Check for required variables
    if grep -q "DB_HOST" cloqr-backend/.env; then
        print_status 0 "DB_HOST defined"
    fi
    
    if grep -q "REDIS_HOST" cloqr-backend/.env; then
        print_status 0 "REDIS_HOST defined"
    fi
    
    if grep -q "JWT_SECRET" cloqr-backend/.env; then
        print_status 0 "JWT_SECRET defined"
    fi
    
    if grep -q "EMAIL_USER" cloqr-backend/.env; then
        print_status 0 "EMAIL_USER defined"
    fi
    
    if grep -q "ADMIN_EMAIL" cloqr-backend/.env; then
        print_status 0 "ADMIN_EMAIL defined"
    fi
    
    print_warning ".env is for local development only"
    echo "  Set environment variables in Cloud Run after deployment"
else
    print_warning ".env file missing (optional for local development)"
fi

echo ""
echo "📋 Phase 5: Database Schema"
echo "---------------------------"

# Check for SQL schema files
if [ -f "cloqr-backend/setup_database.sql" ]; then
    print_status 0 "setup_database.sql exists"
elif [ -f "cloqr-backend/src/database/schema.sql" ]; then
    print_status 0 "schema.sql exists"
else
    print_warning "No database schema file found"
    echo "  You'll need this to initialize Cloud SQL"
fi

echo ""
echo "=============================================="
echo "📊 Summary"
echo "=============================================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Your setup looks good!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Deploy backend: cd cloqr-backend && gcloud run deploy cloqr-backend --source . --region us-central1"
    echo "2. Set up Cloud SQL: gcloud sql instances create cloqr-db ..."
    echo "3. Set up Redis: gcloud redis instances create cloqr-redis ..."
    echo "4. Update mobile app URL in api_config.dart"
    echo "5. Build APK: cd mobile && flutter build apk --release"
    echo ""
    echo "See FIREBASE_COMPLETE_SETUP.md for detailed instructions"
else
    echo -e "${RED}✗ Please fix the failed checks before deploying${NC}"
    echo ""
    echo "See FIREBASE_COMPLETE_SETUP.md for help"
fi

echo ""
