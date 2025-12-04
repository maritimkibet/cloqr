#!/bin/bash

# Simplified Firebase/Google Cloud Deployment Script
# Handles billing and project setup better

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Cloqr Simplified Deployment${NC}"
echo "================================"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI not installed${NC}"
    echo "Install: curl https://sdk.cloud.google.com | bash"
    exit 1
fi

# Check if logged in
ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | head -n 1)
if [ -z "$ACCOUNT" ]; then
    echo -e "${YELLOW}Not logged in. Logging in...${NC}"
    gcloud auth login
fi

echo -e "${GREEN}Logged in as: $ACCOUNT${NC}"
echo ""

# Use existing project
PROJECT_ID="cloqr-dating-1764853042"
echo -e "${BLUE}Using project: $PROJECT_ID${NC}"
gcloud config set project "$PROJECT_ID"
echo ""

# Check billing
echo -e "${BLUE}Checking billing status...${NC}"
BILLING_ENABLED=$(gcloud billing projects describe "$PROJECT_ID" --format="value(billingEnabled)" 2>/dev/null || echo "false")

if [ "$BILLING_ENABLED" != "True" ]; then
    echo -e "${YELLOW}⚠️  Billing is not enabled for this project${NC}"
    echo ""
    echo "To continue, you need to enable billing:"
    echo "1. Open: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
    echo "2. Link a billing account (or create one)"
    echo "3. Come back and run this script again"
    echo ""
    echo -e "${BLUE}Why billing is required:${NC}"
    echo "  • Cloud Run requires billing (even though it's free for 2M requests/month)"
    echo "  • New users get \$300 credit (lasts ~8 months)"
    echo "  • You won't be charged unless you exceed free tier"
    echo ""
    echo -e "${GREEN}It's essentially FREE for your use case!${NC}"
    echo ""
    
    # Ask if they want to open the billing page
    echo -e "${YELLOW}Open billing page in browser? (y/n)${NC}"
    read -r OPEN_BROWSER
    
    if [ "$OPEN_BROWSER" == "y" ] || [ "$OPEN_BROWSER" == "Y" ]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open "https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
        elif command -v open &> /dev/null; then
            open "https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
        else
            echo "Please open this URL manually:"
            echo "https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
        fi
    fi
    
    exit 1
fi

echo -e "${GREEN}✓ Billing is enabled${NC}"
echo ""

# Enable required APIs
echo -e "${BLUE}📦 Enabling required APIs...${NC}"
echo "This may take 1-2 minutes..."
echo ""

gcloud services enable \
    run.googleapis.com \
    cloudbuild.googleapis.com \
    sqladmin.googleapis.com \
    redis.googleapis.com \
    secretmanager.googleapis.com

echo -e "${GREEN}✓ APIs enabled${NC}"
echo ""

# Deploy backend
echo -e "${BLUE}🚀 Deploying backend to Cloud Run...${NC}"
echo "This will take 3-5 minutes..."
echo ""

cd cloqr-backend

gcloud run deploy cloqr-backend \
    --source . \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --timeout 300 \
    --min-instances 0 \
    --max-instances 10 \
    --port 8080

# Get service URL
SERVICE_URL=$(gcloud run services describe cloqr-backend \
    --region us-central1 \
    --format="value(status.url)")

echo ""
echo -e "${GREEN}✓ Backend deployed successfully!${NC}"
echo -e "${GREEN}Service URL: $SERVICE_URL${NC}"
echo ""

# Save URL to file
echo "$SERVICE_URL" > ../BACKEND_URL.txt

# Test backend
echo -e "${BLUE}🧪 Testing backend...${NC}"
HEALTH_CHECK=$(curl -s "$SERVICE_URL/health" || echo "failed")
if echo "$HEALTH_CHECK" | grep -q "ok"; then
    echo -e "${GREEN}✓ Backend is healthy!${NC}"
    echo "Response: $HEALTH_CHECK"
else
    echo -e "${YELLOW}⚠️  Backend health check returned unexpected response${NC}"
    echo "Response: $HEALTH_CHECK"
    echo ""
    echo "This might be normal if database is not set up yet."
fi

cd ..

echo ""
echo "=============================================="
echo -e "${GREEN}🎉 Backend Deployment Complete!${NC}"
echo "=============================================="
echo ""
echo "Backend URL: $SERVICE_URL"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. Update mobile app URL:"
echo "   ./update-mobile-url.sh"
echo ""
echo "2. (Optional) Set up Cloud SQL database:"
echo "   gcloud sql instances create cloqr-db \\"
echo "     --database-version=POSTGRES_15 \\"
echo "     --tier=db-f1-micro \\"
echo "     --region=us-central1"
echo ""
echo "3. (Optional) Set up Redis:"
echo "   gcloud redis instances create cloqr-redis \\"
echo "     --size=1 \\"
echo "     --region=us-central1 \\"
echo "     --redis-version=redis_7_0"
echo ""
echo "4. View logs:"
echo "   gcloud run services logs read cloqr-backend --region us-central1"
echo ""
echo "5. View in console:"
echo "   https://console.cloud.google.com/run?project=$PROJECT_ID"
echo ""
