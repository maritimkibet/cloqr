# Firebase Deployment Checklist

## Pre-Deployment Checklist

- [ ] Google Cloud account created
- [ ] Billing enabled (required but won't charge unless you exceed free tier)
- [ ] gcloud CLI installed and working
- [ ] Logged in: `gcloud auth login`

## Deployment Steps

### 1. Initial Setup (One-time)

```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash

# Login
gcloud auth login

# Create project
gcloud projects create cloqr-app --name="Cloqr"
gcloud config set project cloqr-app

# Enable billing at: https://console.cloud.google.com/billing
```

- [ ] gcloud CLI installed
- [ ] Logged in to Google Cloud
- [ ] Project created
- [ ] Billing enabled

### 2. Deploy Backend (5 minutes)

```bash
cd cloqr-backend
./quick-deploy.sh
```

**Or manually:**
```bash
gcloud run deploy cloqr-backend \
  --source . \
  --region us-central1 \
  --allow-unauthenticated
```

- [ ] Backend deployed to Cloud Run
- [ ] Service URL obtained: `https://cloqr-backend-xxxxx.run.app`

### 3. Set Up Database (10 minutes)

```bash
# Create PostgreSQL
gcloud sql instances create cloqr-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --root-password=YOUR_PASSWORD

# Create database
gcloud sql databases create cloqr --instance=cloqr-db

# Create user
gcloud sql users create cloqr_user \
  --instance=cloqr-db \
  --password=YOUR_PASSWORD
```

- [ ] Cloud SQL instance created
- [ ] Database created
- [ ] User created
- [ ] Connection name saved

### 4. Set Up Redis (10 minutes)

```bash
# Create Redis
gcloud redis instances create cloqr-redis \
  --size=1 \
  --region=us-central1 \
  --redis-version=redis_7_0

# Get Redis IP
gcloud redis instances describe cloqr-redis \
  --region=us-central1 \
  --format="value(host)"
```

- [ ] Redis instance created
- [ ] Redis IP address saved

### 5. Configure Environment Variables (5 minutes)

```bash
gcloud run services update cloqr-backend \
  --region us-central1 \
  --set-env-vars "NODE_ENV=production" \
  --set-env-vars "DB_HOST=/cloudsql/PROJECT:REGION:INSTANCE" \
  --set-env-vars "DB_NAME=cloqr" \
  --set-env-vars "DB_USER=cloqr_user" \
  --set-env-vars "DB_PASSWORD=YOUR_PASSWORD" \
  --set-env-vars "REDIS_HOST=YOUR_REDIS_IP" \
  --set-env-vars "JWT_SECRET=$(openssl rand -base64 32)" \
  --set-env-vars "ADMIN_EMAIL=brianvocaldo@gmail.com" \
  --set-env-vars "ADMIN_PASSWORD=kiss2121" \
  --set-env-vars "EMAIL_USER=brianvocaldo@gmail.com" \
  --set-env-vars "EMAIL_PASSWORD=ujac lgxh wegg bfxs" \
  --set-env-vars "ALLOWED_EMAIL_DOMAINS=edu,ac.za" \
  --add-cloudsql-instances=PROJECT:REGION:INSTANCE
```

- [ ] All environment variables set
- [ ] Cloud SQL connection added

### 6. Initialize Database (5 minutes)

```bash
# Connect to database
gcloud sql connect cloqr-db --user=cloqr_user --database=cloqr

# Run setup SQL
\i /path/to/setup_database.sql
```

- [ ] Database schema created
- [ ] Tables initialized

### 7. Test Backend (2 minutes)

```bash
# Get URL
SERVICE_URL=$(gcloud run services describe cloqr-backend \
  --region us-central1 \
  --format="value(status.url)")

# Test health endpoint
curl $SERVICE_URL/health

# Should return: {"status":"ok","timestamp":"..."}
```

- [ ] Health endpoint working
- [ ] Backend responding correctly

### 8. Update Mobile App (5 minutes)

Edit `mobile/lib/config/api_config.dart`:

```dart
static const String baseUrl = 'https://cloqr-backend-xxxxx.run.app';
```

- [ ] API URL updated in mobile app
- [ ] App tested with production backend

### 9. Build Release APK (5 minutes)

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

APK location: `mobile/build/app/outputs/flutter-apk/app-release.apk`

- [ ] Release APK built
- [ ] APK tested on device

### 10. Final Testing (10 minutes)

Test all features:
- [ ] User registration (with OTP)
- [ ] Admin login (OTP bypass)
- [ ] Profile creation
- [ ] Swipe matching
- [ ] Chat messaging
- [ ] Room creation
- [ ] QR code scanning

## Post-Deployment

### Monitor Your App

```bash
# View logs
gcloud run services logs read cloqr-backend --region us-central1

# View metrics
# Go to: https://console.cloud.google.com/run
```

### Update Backend

```bash
cd cloqr-backend
# Make your changes
gcloud run deploy cloqr-backend --source . --region us-central1
```

### Distribute APK

**Option A: Google Play Store**
1. Create developer account ($25 one-time)
2. Upload APK
3. Fill in store listing
4. Submit for review

**Option B: Direct Distribution**
1. Upload APK to Google Drive/Dropbox
2. Share link with users
3. Users enable "Unknown Sources"
4. Install APK

## Cost Summary

### Monthly Costs
- Cloud Run: FREE (2M requests/month)
- Cloud SQL (db-f1-micro): ~$7/month
- Redis (basic, 1GB): ~$30/month
- **Total: ~$37/month**

### Free Tier Benefits
- First 2 million Cloud Run requests: FREE
- Cloud Run scales to zero: No cost when idle
- $300 free credit for new Google Cloud users

## Troubleshooting

### Backend not responding
```bash
# Check logs
gcloud run services logs read cloqr-backend --region us-central1 --limit 100

# Check service status
gcloud run services describe cloqr-backend --region us-central1
```

### Database connection issues
```bash
# Verify Cloud SQL is running
gcloud sql instances list

# Check connection name
gcloud sql instances describe cloqr-db --format="value(connectionName)"

# Test connection
gcloud sql connect cloqr-db --user=cloqr_user
```

### Redis connection issues
```bash
# Check Redis status
gcloud redis instances list --region us-central1

# Get Redis details
gcloud redis instances describe cloqr-redis --region us-central1
```

## Quick Commands

```bash
# Deploy updates
cd cloqr-backend && gcloud run deploy cloqr-backend --source . --region us-central1

# View logs
gcloud run services logs read cloqr-backend --region us-central1 --limit 50

# Get service URL
gcloud run services describe cloqr-backend --region us-central1 --format="value(status.url)"

# Update env var
gcloud run services update cloqr-backend --region us-central1 --set-env-vars "KEY=value"

# Restart service
gcloud run services update cloqr-backend --region us-central1 --clear-env-vars DUMMY
```

## Success Criteria

✅ Backend deployed and accessible
✅ Database connected and initialized
✅ Redis connected
✅ Environment variables configured
✅ Mobile app connects successfully
✅ User registration works (OTP sent)
✅ Admin login works (OTP bypassed)
✅ All features functional
✅ Release APK built and tested

## You're Done! 🎉

Your app is now production-ready and deployed to Firebase/Google Cloud!

Users can download your APK and start using the app immediately - no backend setup required on their end.
