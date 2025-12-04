# 🚀 Deploy Your App to Firebase - START HERE

## What You're About to Do

Deploy your Cloqr dating app to Google Cloud (Firebase) so users can download and use it anywhere in the world!

**Time needed**: 45 minutes
**Cost**: ~$37/month (includes database and Redis)
**Free tier**: 2 million requests/month FREE

## Quick Overview

```
Current Setup:
[Your Computer] → Backend runs locally
[Users] → Can only use on your WiFi

After Deployment:
[Google Cloud] → Backend runs 24/7 in the cloud
[Users] → Download APK, use anywhere! No setup needed.
```

## Prerequisites

1. **Google Account** (Gmail)
2. **Credit Card** (for billing, but won't charge unless you exceed free tier)
3. **45 minutes of time**

## Step-by-Step Guide

### Step 1: Install Google Cloud CLI (5 minutes)

**Linux/Mac:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

**Windows:**
Download from: https://cloud.google.com/sdk/docs/install

**Verify:**
```bash
gcloud --version
```

### Step 2: Login and Create Project (5 minutes)

```bash
# Login
gcloud auth login

# Create project
gcloud projects create cloqr-app --name="Cloqr Dating App"

# Set as active
gcloud config set project cloqr-app
```

**Enable billing:**
1. Go to: https://console.cloud.google.com/billing
2. Link your project to billing account
3. (Won't charge unless you exceed free tier)

### Step 3: Deploy Backend (5 minutes)

```bash
cd cloqr-backend

# Quick deploy
./quick-deploy.sh
```

**Or manually:**
```bash
gcloud run deploy cloqr-backend \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```

**You'll get a URL like:**
```
https://cloqr-backend-xxxxx-uc.a.run.app
```

**Save this URL!** ⭐

### Step 4: Set Up Database (10 minutes)

```bash
# Create PostgreSQL (takes 5-10 minutes)
gcloud sql instances create cloqr-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --root-password=YourSecurePassword123

# Create database
gcloud sql databases create cloqr --instance=cloqr-db

# Create user
gcloud sql users create cloqr_user \
  --instance=cloqr-db \
  --password=YourSecurePassword123
```

### Step 5: Set Up Redis (10 minutes)

```bash
# Create Redis (takes 5-10 minutes)
gcloud redis instances create cloqr-redis \
  --size=1 \
  --region=us-central1 \
  --redis-version=redis_7_0
```

### Step 6: Configure Everything (5 minutes)

```bash
# Get connection details
CONNECTION_NAME=$(gcloud sql instances describe cloqr-db --format="value(connectionName)")
REDIS_HOST=$(gcloud redis instances describe cloqr-redis --region=us-central1 --format="value(host)")

# Set environment variables
gcloud run services update cloqr-backend \
  --region us-central1 \
  --set-env-vars "NODE_ENV=production" \
  --set-env-vars "DB_HOST=/cloudsql/$CONNECTION_NAME" \
  --set-env-vars "DB_NAME=cloqr" \
  --set-env-vars "DB_USER=cloqr_user" \
  --set-env-vars "DB_PASSWORD=YourSecurePassword123" \
  --set-env-vars "REDIS_HOST=$REDIS_HOST" \
  --set-env-vars "JWT_SECRET=$(openssl rand -base64 32)" \
  --set-env-vars "ADMIN_EMAIL=brianvocaldo@gmail.com" \
  --set-env-vars "ADMIN_PASSWORD=kiss2121" \
  --set-env-vars "EMAIL_USER=brianvocaldo@gmail.com" \
  --set-env-vars "EMAIL_PASSWORD=ujac lgxh wegg bfxs" \
  --set-env-vars "ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.edu" \
  --add-cloudsql-instances=$CONNECTION_NAME
```

### Step 7: Initialize Database (5 minutes)

```bash
# Connect to database
gcloud sql connect cloqr-db --user=cloqr_user --database=cloqr

# When connected, paste your SQL:
# (Copy contents from cloqr-backend/setup_database.sql)
```

### Step 8: Test Backend (2 minutes)

```bash
# Get your URL
SERVICE_URL=$(gcloud run services describe cloqr-backend \
  --region us-central1 \
  --format="value(status.url)")

# Test it
curl $SERVICE_URL/health

# Should return: {"status":"ok","timestamp":"..."}
```

✅ **Backend is live!**

### Step 9: Update Mobile App (3 minutes)

Edit `mobile/lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Replace with YOUR Cloud Run URL
  static const String baseUrl = 'https://cloqr-backend-xxxxx-uc.a.run.app';
  
  // Rest stays the same
  static const String register = '$baseUrl/api/auth/register';
  static const String login = '$baseUrl/api/auth/login';
  // ...
}
```

### Step 10: Build Release APK (5 minutes)

```bash
cd mobile

# Clean and build
flutter clean
flutter pub get
flutter build apk --release
```

**Your APK is ready!**
Location: `mobile/build/app/outputs/flutter-apk/app-release.apk`

### Step 11: Test Everything (5 minutes)

1. Install APK on your phone
2. Test registration (should receive OTP email)
3. Test admin login (should skip OTP)
4. Test all features

✅ **Everything works!**

### Step 12: Distribute to Users

**Option A: Google Play Store** (Recommended)
1. Create developer account ($25 one-time)
2. Upload APK
3. Users download from Play Store

**Option B: Direct Distribution**
1. Upload APK to Google Drive
2. Share link with users
3. Users install directly

## What Users Experience

1. User downloads your APK
2. User installs it (one tap)
3. User opens app
4. App connects to your cloud backend
5. User registers, gets OTP, uses app
6. **Everything just works!** No setup needed.

## Costs

### Free Tier
- Cloud Run: 2 million requests/month FREE
- First $300 credit for new users

### Paid (After free tier)
- Cloud Run: ~$0 (scales to zero when idle)
- Cloud SQL: ~$7/month
- Redis: ~$30/month
- **Total: ~$37/month**

## Monitoring

```bash
# View logs
gcloud run services logs read cloqr-backend --region us-central1

# View in browser
# https://console.cloud.google.com/run
```

## Updating Your App

### Update Backend
```bash
cd cloqr-backend
# Make changes
gcloud run deploy cloqr-backend --source . --region us-central1
```

### Update Mobile App
```bash
cd mobile
# Make changes
flutter build apk --release
# Distribute new APK
```

## Need Help?

See detailed guides:
- `FIREBASE_SETUP_COMPLETE.md` - Complete step-by-step guide
- `FIREBASE_DEPLOYMENT_CHECKLIST.md` - Checklist format
- `FIREBASE_DEPLOYMENT.md` - Technical details

## Quick Commands Reference

```bash
# Deploy backend
cd cloqr-backend && ./quick-deploy.sh

# View logs
gcloud run services logs read cloqr-backend --region us-central1

# Get service URL
gcloud run services describe cloqr-backend --region us-central1 --format="value(status.url)"

# Build APK
cd mobile && flutter build apk --release
```

## You're Ready! 🎉

Follow the steps above and your app will be live in 45 minutes!

**Start with Step 1** and work your way through. Each step is simple and clearly explained.

Good luck! 🚀
