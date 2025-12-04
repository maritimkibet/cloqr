#!/bin/bash

# Quick Firebase/Google Cloud Deployment Script
# This script automates the deployment process

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Cloqr Firebase Deployment Script${NC}"
echo "===================================="
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

# Get or set project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

# Check if we have permission on current project
if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "(unset)" ]; then
    echo -e "${YELLOW}Current project: $PROJECT_ID${NC}"
    echo "Testing permissions..."
    
    # Test if we can enable services
    if ! gcloud services list --project="$PROJECT_ID" &>/dev/null; then
        echo -e "${RED}You don't have permission on project: $PROJECT_ID${NC}"
        echo "Let's create a new project instead."
        PROJECT_ID=""
    fi
fi

if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" == "(unset)" ]; then
    echo -e "${YELLOW}Let's create a new project.${NC}"
    echo "Enter a unique project ID (lowercase, numbers, hyphens only):"
    echo "Example: cloqr-app-brian-$(date +%Y%m%d)"
    read -r INPUT_PROJECT_ID
    
    if [ -z "$INPUT_PROJECT_ID" ]; then
        # Create new project with timestamp
        TIMESTAMP=$(date +%s)
        PROJECT_ID="cloqr-app-$TIMESTAMP"
        echo -e "${BLUE}Using project ID: $PROJECT_ID${NC}"
    else
        PROJECT_ID="$INPUT_PROJECT_ID"
    fi
    
    echo -e "${BLUE}Creating project: $PROJECT_ID${NC}"
    if gcloud projects create "$PROJECT_ID" --name="Cloqr Dating App"; then
        echo -e "${GREEN}✓ Project created successfully${NC}"
    else
        echo -e "${RED}Failed to create project. It may already exist or the ID is invalid.${NC}"
        echo "Try a different project ID."
        exit 1
    fi
    
    gcloud config set project "$PROJECT_ID"
fi

echo -e "${GREEN}Using project: $PROJECT_ID${NC}"
echo ""

# Check if billing is enabled
echo -e "${YELLOW}Checking billing...${NC}"
if ! gcloud beta billing projects describe "$PROJECT_ID" &>/dev/null; then
    echo -e "${RED}⚠ Billing is not enabled for this project${NC}"
    echo ""
    echo "To enable billing:"
    echo "1. Go to: https://console.cloud.google.com/billing"
    echo "2. Select your project: $PROJECT_ID"
    echo "3. Link it to a billing account"
    echo ""
    echo "Press Enter after enabling billing to continue..."
    read -r
fi

# Enable required APIs
echo -e "${BLUE}📦 Enabling required APIs...${NC}"
gcloud services enable run.googleapis.com \
    cloudbuild.googleapis.com \
    sqladmin.googleapis.com \
    redis.googleapis.com \
    secretmanager.googleapis.com

echo -e "${GREEN}✓ APIs enabled${NC}"
echo ""

# Deploy backend
echo -e "${BLUE}🚀 Deploying backend to Cloud Run...${NC}"
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

# Ask if user wants to set up database
echo -e "${YELLOW}Do you want to set up Cloud SQL now? (y/n)${NC}"
read -r SETUP_DB

if [ "$SETUP_DB" == "y" ] || [ "$SETUP_DB" == "Y" ]; then
    echo -e "${BLUE}🗄️  Creating Cloud SQL instance...${NC}"
    echo "This will take 5-10 minutes. Please wait..."
    
    # Generate secure password
    DB_PASSWORD=$(openssl rand -base64 16)
    
    gcloud sql instances create cloqr-db \
        --database-version=POSTGRES_15 \
        --tier=db-f1-micro \
        --region=us-central1 \
        --root-password="$DB_PASSWORD" || echo "Instance may already exist"
    
    # Create database
    gcloud sql databases create cloqr --instance=cloqr-db || echo "Database may already exist"
    
    # Create user
    USER_PASSWORD=$(openssl rand -base64 16)
    gcloud sql users create cloqr_user \
        --instance=cloqr-db \
        --password="$USER_PASSWORD" || echo "User may already exist"
    
    # Get connection name
    CONNECTION_NAME=$(gcloud sql instances describe cloqr-db --format="value(connectionName)")
    
    echo -e "${GREEN}✓ Cloud SQL created${NC}"
    echo "Connection name: $CONNECTION_NAME"
    echo "Root password: $DB_PASSWORD"
    echo "User password: $USER_PASSWORD"
    echo ""
    
    # Save credentials
    cat > ../DB_CREDENTIALS.txt << EOF
Cloud SQL Connection Name: $CONNECTION_NAME
Root Password: $DB_PASSWORD
User: cloqr_user
User Password: $USER_PASSWORD
EOF
    
    echo -e "${GREEN}Credentials saved to DB_CREDENTIALS.txt${NC}"
fi

# Ask if user wants to set up Redis
echo -e "${YELLOW}Do you want to set up Redis now? (y/n)${NC}"
read -r SETUP_REDIS

if [ "$SETUP_REDIS" == "y" ] || [ "$SETUP_REDIS" == "Y" ]; then
    echo -e "${BLUE}🔴 Creating Redis instance...${NC}"
    echo "This will take 5-10 minutes. Please wait..."
    
    gcloud redis instances create cloqr-redis \
        --size=1 \
        --region=us-central1 \
        --redis-version=redis_7_0 \
        --tier=basic || echo "Instance may already exist"
    
    # Get Redis host
    REDIS_HOST=$(gcloud redis instances describe cloqr-redis \
        --region=us-central1 \
        --format="value(host)")
    
    echo -e "${GREEN}✓ Redis created${NC}"
    echo "Redis host: $REDIS_HOST"
    echo ""
    
    # Save to file
    echo "Redis Host: $REDIS_HOST" > ../REDIS_HOST.txt
fi

# Update environment variables
echo -e "${YELLOW}Do you want to configure environment variables now? (y/n)${NC}"
read -r SETUP_ENV

if [ "$SETUP_ENV" == "y" ] || [ "$SETUP_ENV" == "Y" ]; then
    echo -e "${BLUE}⚙️  Configuring environment variables...${NC}"
    
    # Generate JWT secret
    JWT_SECRET=$(openssl rand -base64 32)
    
    # Get values from files or prompt
    if [ -f "../DB_CREDENTIALS.txt" ]; then
        CONNECTION_NAME=$(grep "Connection Name:" ../DB_CREDENTIALS.txt | cut -d: -f2- | xargs)
        USER_PASSWORD=$(grep "User Password:" ../DB_CREDENTIALS.txt | cut -d: -f2- | xargs)
    else
        echo "Enter Cloud SQL connection name:"
        read -r CONNECTION_NAME
        echo "Enter database user password:"
        read -r USER_PASSWORD
    fi
    
    if [ -f "../REDIS_HOST.txt" ]; then
        REDIS_HOST=$(grep "Redis Host:" ../REDIS_HOST.txt | cut -d: -f2- | xargs)
    else
        echo "Enter Redis host IP:"
        read -r REDIS_HOST
    fi
    
    # Update Cloud Run service
    gcloud run services update cloqr-backend \
        --region us-central1 \
        --set-env-vars "NODE_ENV=production" \
        --set-env-vars "DB_HOST=/cloudsql/$CONNECTION_NAME" \
        --set-env-vars "DB_PORT=5432" \
        --set-env-vars "DB_NAME=cloqr" \
        --set-env-vars "DB_USER=cloqr_user" \
        --set-env-vars "DB_PASSWORD=$USER_PASSWORD" \
        --set-env-vars "REDIS_HOST=$REDIS_HOST" \
        --set-env-vars "REDIS_PORT=6379" \
        --set-env-vars "JWT_SECRET=$JWT_SECRET" \
        --set-env-vars "JWT_EXPIRES_IN=7d" \
        --set-env-vars "ADMIN_EMAIL=brianvocaldo@gmail.com" \
        --set-env-vars "ADMIN_PASSWORD=kiss2121" \
        --set-env-vars "EMAIL_HOST=smtp.gmail.com" \
        --set-env-vars "EMAIL_PORT=587" \
        --set-env-vars "EMAIL_USER=brianvocaldo@gmail.com" \
        --set-env-vars "EMAIL_PASSWORD=ujac lgxh wegg bfxs" \
        --set-env-vars "ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.edu,university.edu" \
        --set-env-vars "MAX_FILE_SIZE=5242880" \
        --set-env-vars "FRONTEND_URL=$SERVICE_URL" \
        --add-cloudsql-instances="$CONNECTION_NAME"
    
    echo -e "${GREEN}✓ Environment variables configured${NC}"
fi

cd ..

# Test backend
echo ""
echo -e "${BLUE}🧪 Testing backend...${NC}"
HEALTH_CHECK=$(curl -s "$SERVICE_URL/health")
if echo "$HEALTH_CHECK" | grep -q "ok"; then
    echo -e "${GREEN}✓ Backend is healthy!${NC}"
    echo "Response: $HEALTH_CHECK"
else
    echo -e "${RED}✗ Backend health check failed${NC}"
    echo "Response: $HEALTH_CHECK"
fi

echo ""
echo "=============================================="
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo "=============================================="
echo ""
echo "Backend URL: $SERVICE_URL"
echo ""
echo "Next steps:"
echo "1. Initialize database:"
echo "   gcloud sql connect cloqr-db --user=cloqr_user --database=cloqr"
echo "   (Then paste your SQL schema)"
echo ""
echo "2. Update mobile app URL in mobile/lib/config/api_config.dart:"
echo "   static const String baseUrl = '$SERVICE_URL/api';"
echo ""
echo "3. Build mobile app:"
echo "   cd mobile && flutter build apk --release"
echo ""
echo "4. Test everything!"
echo ""
echo "View logs: gcloud run services logs read cloqr-backend --region us-central1"
echo "View console: https://console.cloud.google.com/run"
echo ""
