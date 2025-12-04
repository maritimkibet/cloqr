#!/bin/bash

# Quick Firebase/Cloud Run Deployment Script
# Run this after you've set up your Google Cloud project

set -e  # Exit on error

echo "🚀 Cloqr Backend - Quick Deploy to Google Cloud Run"
echo "=================================================="
echo ""

# Configuration
PROJECT_ID="cloqr-app"
SERVICE_NAME="cloqr-backend"
REGION="us-central1"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ gcloud CLI not found${NC}"
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

echo -e "${GREEN}✅ gcloud CLI found${NC}"

# Check if logged in
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo -e "${YELLOW}🔐 Not logged in. Logging in...${NC}"
    gcloud auth login
fi

echo -e "${GREEN}✅ Authenticated${NC}"

# Set project
echo -e "${YELLOW}📦 Setting project to $PROJECT_ID...${NC}"
gcloud config set project $PROJECT_ID

# Enable APIs
echo -e "${YELLOW}🔧 Enabling required APIs...${NC}"
gcloud services enable run.googleapis.com --quiet
gcloud services enable cloudbuild.googleapis.com --quiet
echo -e "${GREEN}✅ APIs enabled${NC}"

# Deploy
echo ""
echo -e "${YELLOW}🏗️  Deploying to Cloud Run...${NC}"
echo "This will take 2-5 minutes..."
echo ""

gcloud run deploy $SERVICE_NAME \
  --source . \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --min-instances 0 \
  --max-instances 10 \
  --quiet

# Get service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
  --region $REGION \
  --format="value(status.url)")

echo ""
echo -e "${GREEN}✅ Deployment successful!${NC}"
echo ""
echo "=================================================="
echo -e "${GREEN}Your backend is live at:${NC}"
echo -e "${YELLOW}$SERVICE_URL${NC}"
echo "=================================================="
echo ""
echo "📝 Next steps:"
echo "1. Set up Cloud SQL: gcloud sql instances create cloqr-db ..."
echo "2. Set up Redis: gcloud redis instances create cloqr-redis ..."
echo "3. Configure environment variables"
echo "4. Update mobile app with this URL: $SERVICE_URL"
echo ""
echo "See FIREBASE_SETUP_COMPLETE.md for detailed instructions"
