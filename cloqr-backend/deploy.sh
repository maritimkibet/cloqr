#!/bin/bash

# Firebase/Google Cloud Run Deployment Script
# This script deploys your backend to Google Cloud Run

echo "🚀 Deploying Cloqr Backend to Google Cloud Run..."

# Set your project ID (you'll need to change this)
PROJECT_ID="cloqr-app"
SERVICE_NAME="cloqr-backend"
REGION="us-central1"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found. Installing..."
    echo "Run: curl https://sdk.cloud.google.com | bash"
    exit 1
fi

# Login to Google Cloud (if not already logged in)
echo "🔐 Checking Google Cloud authentication..."
gcloud auth list

# Set project
echo "📦 Setting project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable sqladmin.googleapis.com

# Build and deploy to Cloud Run
echo "🏗️  Building and deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --source . \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --set-env-vars NODE_ENV=production

echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Set up Cloud SQL (PostgreSQL)"
echo "2. Set up Memorystore (Redis)"
echo "3. Configure environment variables"
echo "4. Run database migrations"
echo ""
echo "Your service URL:"
gcloud run services describe $SERVICE_NAME --region $REGION --format="value(status.url)"
