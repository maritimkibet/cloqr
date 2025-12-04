# Complete Firebase Deployment Guide

## What We're Deploying

Your backend will run on **Google Cloud Run** (part of Firebase/Google Cloud Platform):
- ✅ Your current Node.js code works as-is
- ✅ Auto-scales automatically
- ✅ Pay only for what you use
- ✅ Free tier: 2 million requests/month

## Prerequisites

1. **Google Cloud Account**
   - Go to: https://console.cloud.google.com
   - Sign up (free $300 credit for new users)
   - Enable billing (required but won't charge unless you exceed free tier)

2. **Install Google Cloud CLI**
   ```bash
   # Linux/Mac
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   
   # Or download from: https://cloud.google.com/sdk/docs/install
   ```

3. **Verify Installation**
   ```bash
   gcloud --version
   ```

## Step-by-Step Deployment

### Step 1: Login to Google Cloud

```bash
gcloud auth login
```

This opens your browser - login with your Google account.

### Step 2: Create a New Project

```bash
# Create project
gcloud projects create cloqr-app --name="Cloqr Dating App"

# Set as active project
gcloud config set project cloqr-app

# Enable billing (required for Cloud Run)
# Go to: https://console.cloud.google.com/billing
# Link your project to a billing account
```

### Step 3: Enable Required APIs

```bash
# Enable Cloud Run
gcloud services enable run.googleapis.com

# Enable Cloud Build (for building Docker images)
gcloud services enable cloudbuild.googleapis.com

# Enable Cloud SQL (for PostgreSQL)
gcloud services enable sqladmin.googleapis.com

# Enable Secret Manager (for storing sensitive data)
gcloud services enable secretmanager.googleapis.com
```

### Step 4: Deploy Backend to Cloud Run

```bash
cd cloqr-backend

# Deploy (this builds and deploys in one command)
gcloud run deploy cloqr-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --min-instances 0 \
  --max-instances 10
```

**This will:**
1. Build a Docker image from your code
2. Upload it to Google Container Registry
3. Deploy to Cloud Run
4. Give you a public URL

**Expected output:**
```
Service [cloqr-backend] revision [cloqr-backend-00001] has been deployed.
Service URL: https://cloqr-backend-xxxxx-uc.a.run.app
```

**Save this URL!** You'll need it for your mobile app.

### Step 5: Set Up Cloud SQL (PostgreSQL)

```bash
# Create PostgreSQL instance (takes 5-10 minutes)
gcloud sql instances create cloqr-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --root-password=YOUR_SECURE_ROOT_PASSWORD

# Create database
gcloud sql databases create cloqr --instance=cloqr-db

# Create user
gcloud sql users create cloqr_user \
  --instance=cloqr-db \
  --password=YOUR_SECURE_USER_PASSWORD

# Get connection name (save this!)
gcloud sql instances describe cloqr-db --format="value(connectionName)"
# Output: cloqr-app:us-central1:cloqr-db
```

### Step 6: Set Up Redis (Memorystore)

```bash
# Create Redis instance (takes 5-10 minutes)
gcloud redis instances create cloqr-redis \
  --size=1 \
  --region=us-central1 \
  --redis-version=redis_7_0 \
  --tier=basic

# Get Redis host (save this!)
gcloud redis instances describe cloqr-redis \
  --region=us-central1 \
  --format="value(host)"
# Output: 10.x.x.x
```

### Step 7: Configure Environment Variables

```bash
# Set all environment variables
gcloud run services update cloqr-backend \
  --region us-central1 \
  --set-env-vars "NODE_ENV=production" \
  --set-env-vars "DB_HOST=/cloudsql/cloqr-app:us-central1:cloqr-db" \
  --set-env-vars "DB_PORT=5432" \
  --set-env-vars "DB_NAME=cloqr" \
  --set-env-vars "DB_USER=cloqr_user" \
  --set-env-vars "DB_PASSWORD=YOUR_SECURE_USER_PASSWORD" \
  --set-env-vars "REDIS_HOST=YOUR_REDIS_IP" \
  --set-env-vars "REDIS_PORT=6379" \
  --set-env-vars "JWT_SECRET=$(openssl rand -base64 32)" \
  --set-env-vars "JWT_EXPIRES_IN=7d" \
  --set-env-vars "ADMIN_EMAIL=brianvocaldo@gmail.com" \
  --set-env-vars "ADMIN_PASSWORD=kiss2121" \
  --set-env-vars "EMAIL_USER=brianvocaldo@gmail.com" \
  --set-env-vars "EMAIL_PASSWORD=ujac lgxh wegg bfxs" \
  --set-env-vars "ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.edu,university.edu" \
  --set-env-vars "FRONTEND_URL=https://cloqr-backend-xxxxx-uc.a.run.app" \
  --add-cloudsql-instances=cloqr-app:us-central1:cloqr-db
```

### Step 8: Initialize Database

```bash
# Connect to Cloud SQL
gcloud sql connect cloqr-db --user=cloqr_user --database=cloqr

# When connected, paste your SQL setup:
# (Copy contents of setup_database.sql and paste)

# Or upload and run:
gcloud sql import sql cloqr-db gs://your-bucket/setup_database.sql \
  --database=cloqr
```

### Step 9: Test Your Deployment

```bash
# Get your service URL
SERVICE_URL=$(gcloud run services describe cloqr-backend \
  --region us-central1 \
  --format="value(status.url)")

# Test health endpoint
curl $SERVICE_URL/health

# Should return: {"status":"ok","timestamp":"..."}
```

### Step 10: Update Mobile App

Update `mobile/lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Replace with your Cloud Run URL
  static const String baseUrl = 'https://cloqr-backend-xxxxx-uc.a.run.app';
  
  // Rest stays the same
  static const String register = '$baseUrl/api/auth/register';
  static const String login = '$baseUrl/api/auth/login';
  // ...
}
```

### Step 11: Build Release APK

```bash
cd mobile

# Build release APK
flutter build apk --release

# APK location:
# mobile/build/app/outputs/flutter-apk/app-release.apk
```

## Cost Estimate

### Free Tier (Generous!)
- **Cloud Run**: 2 million requests/month FREE
- **Cloud SQL**: $7/month (db-f1-micro)
- **Redis**: $30/month (basic tier)
- **Total**: ~$37/month

### Optimization Tips
- Cloud Run scales to zero (no cost when idle)
- First 2 million requests are free
- Can use Firestore instead of Cloud SQL (cheaper)

## Monitoring & Logs

### View Logs
```bash
# Cloud Run logs
gcloud run services logs read cloqr-backend --region us-central1

# Or use web console:
# https://console.cloud.google.com/run
```

### View Metrics
```bash
# Open Cloud Console
gcloud run services describe cloqr-backend --region us-central1
```

## Troubleshooting

### Issue: "Permission denied"
```bash
# Make sure you're logged in
gcloud auth login

# Set correct project
gcloud config set project cloqr-app
```

### Issue: "Billing not enabled"
- Go to: https://console.cloud.google.com/billing
- Enable billing for your project
- Link a payment method (won't charge unless you exceed free tier)

### Issue: "Database connection failed"
```bash
# Check Cloud SQL instance is running
gcloud sql instances list

# Check connection name is correct
gcloud sql instances describe cloqr-db --format="value(connectionName)"

# Make sure Cloud Run has Cloud SQL connection
gcloud run services describe cloqr-backend --region us-central1
```

### Issue: "Redis connection failed"
```bash
# Check Redis instance
gcloud redis instances list --region us-central1

# Get Redis IP
gcloud redis instances describe cloqr-redis --region us-central1
```

## Quick Commands Reference

```bash
# Deploy updates
cd cloqr-backend
gcloud run deploy cloqr-backend --source . --region us-central1

# View logs
gcloud run services logs read cloqr-backend --region us-central1 --limit 50

# Update environment variable
gcloud run services update cloqr-backend \
  --region us-central1 \
  --set-env-vars "NEW_VAR=value"

# Get service URL
gcloud run services describe cloqr-backend \
  --region us-central1 \
  --format="value(status.url)"

# Delete service (if needed)
gcloud run services delete cloqr-backend --region us-central1
```

## What Users Experience

After deployment:

1. **You**: Share APK file or publish to Play Store
2. **User**: Downloads and installs APK
3. **User**: Opens app
4. **App**: Automatically connects to your Cloud Run backend
5. **User**: Registers, gets OTP email, uses app
6. **Everything works!** No setup needed for users.

## Next Steps

1. ✅ Deploy backend to Cloud Run
2. ✅ Set up Cloud SQL database
3. ✅ Set up Redis cache
4. ✅ Configure environment variables
5. ✅ Update mobile app URL
6. ✅ Build release APK
7. 📱 Distribute to users!

## Support

If you encounter issues:
1. Check logs: `gcloud run services logs read cloqr-backend --region us-central1`
2. Verify environment variables are set correctly
3. Test health endpoint: `curl YOUR_URL/health`
4. Check Cloud SQL and Redis are running

Your backend is now production-ready and will auto-scale based on demand! 🚀
