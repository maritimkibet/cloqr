# Complete Firebase/Google Cloud Setup & Verification Guide

## Current Status Analysis

✅ **What's Already Done:**
- Backend has Dockerfile for Cloud Run
- Server.js configured for Cloud Run (PORT env variable)
- Database config supports Cloud SQL
- Redis config supports Memorystore
- Mobile app ready for deployment

❌ **What's Missing:**
- No Firebase SDK in mobile app (not needed for your setup)
- API URL still points to local (192.168.100.198:3000)
- No google-services.json (not needed for backend-only Firebase)
- Backend not deployed to Cloud Run yet

## Your Architecture

```
Mobile App (Flutter)
    ↓ HTTP/WebSocket
Backend (Node.js on Cloud Run)
    ↓
PostgreSQL (Cloud SQL) + Redis (Memorystore)
```

**Note:** You're using Firebase/Google Cloud for **backend hosting only**, not Firebase SDK features. This is perfect for your setup!

---

## Complete Deployment Checklist

### Phase 1: Prerequisites (5 minutes)

```bash
# 1. Install Google Cloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# 2. Verify installation
gcloud --version

# 3. Login
gcloud auth login

# 4. Create project
gcloud projects create cloqr-app-$(date +%s) --name="Cloqr Dating App"

# 5. Set project (use the ID from above)
gcloud config set project YOUR_PROJECT_ID

# 6. Enable billing
# Go to: https://console.cloud.google.com/billing
# Link your project to billing account
```

**Checklist:**
- [ ] gcloud CLI installed
- [ ] Logged in successfully
- [ ] Project created
- [ ] Billing enabled

---

### Phase 2: Enable Required APIs (2 minutes)

```bash
# Enable all required services
gcloud services enable run.googleapis.com \
  cloudbuild.googleapis.com \
  sqladmin.googleapis.com \
  redis.googleapis.com \
  secretmanager.googleapis.com
```

**Checklist:**
- [ ] Cloud Run enabled
- [ ] Cloud Build enabled
- [ ] Cloud SQL enabled
- [ ] Redis enabled

---

### Phase 3: Deploy Backend (5 minutes)

```bash
cd cloqr-backend

# Deploy to Cloud Run
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

# Save the URL you get!
```

**Expected Output:**
```
Service [cloqr-backend] revision [cloqr-backend-00001] has been deployed.
Service URL: https://cloqr-backend-xxxxx-uc.a.run.app
```

**Checklist:**
- [ ] Backend deployed successfully
- [ ] Service URL saved: ___________________________

---

### Phase 4: Set Up Cloud SQL (10 minutes)

```bash
# Create PostgreSQL instance (takes 5-10 minutes)
gcloud sql instances create cloqr-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --root-password=CloqrSecure2024!

# Create database
gcloud sql databases create cloqr --instance=cloqr-db

# Create user
gcloud sql users create cloqr_user \
  --instance=cloqr-db \
  --password=CloqrUser2024!

# Get connection name (SAVE THIS!)
gcloud sql instances describe cloqr-db --format="value(connectionName)"
```

**Checklist:**
- [ ] Cloud SQL instance created
- [ ] Database 'cloqr' created
- [ ] User 'cloqr_user' created
- [ ] Connection name saved: ___________________________

---

### Phase 5: Set Up Redis (10 minutes)

```bash
# Create Redis instance (takes 5-10 minutes)
gcloud redis instances create cloqr-redis \
  --size=1 \
  --region=us-central1 \
  --redis-version=redis_7_0 \
  --tier=basic

# Get Redis host (SAVE THIS!)
gcloud redis instances describe cloqr-redis \
  --region=us-central1 \
  --format="value(host)"
```

**Checklist:**
- [ ] Redis instance created
- [ ] Redis host IP saved: ___________________________

---

### Phase 6: Configure Environment Variables (5 minutes)

```bash
# Get your connection name and Redis IP from above
CONNECTION_NAME="YOUR_CONNECTION_NAME"  # e.g., cloqr-app:us-central1:cloqr-db
REDIS_HOST="YOUR_REDIS_IP"              # e.g., 10.x.x.x

# Generate secure JWT secret
JWT_SECRET=$(openssl rand -base64 32)

# Update Cloud Run service with all environment variables
gcloud run services update cloqr-backend \
  --region us-central1 \
  --set-env-vars "NODE_ENV=production" \
  --set-env-vars "DB_HOST=/cloudsql/$CONNECTION_NAME" \
  --set-env-vars "DB_PORT=5432" \
  --set-env-vars "DB_NAME=cloqr" \
  --set-env-vars "DB_USER=cloqr_user" \
  --set-env-vars "DB_PASSWORD=CloqrUser2024!" \
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
  --add-cloudsql-instances=$CONNECTION_NAME
```

**Checklist:**
- [ ] All environment variables set
- [ ] Cloud SQL connection added
- [ ] JWT secret generated and set

---

### Phase 7: Initialize Database (5 minutes)

```bash
# Connect to Cloud SQL
gcloud sql connect cloqr-db --user=cloqr_user --database=cloqr

# When prompted, enter password: CloqrUser2024!

# Then paste your SQL schema
# Copy contents from cloqr-backend/setup_database.sql or cloqr-backend/src/database/schema.sql
```

**Or use this command to import directly:**
```bash
# First, upload your SQL file to Cloud Storage
gsutil mb gs://cloqr-db-setup
gsutil cp cloqr-backend/setup_database.sql gs://cloqr-db-setup/

# Import
gcloud sql import sql cloqr-db gs://cloqr-db-setup/setup_database.sql \
  --database=cloqr \
  --user=cloqr_user
```

**Checklist:**
- [ ] Connected to Cloud SQL
- [ ] Database schema imported
- [ ] Tables created successfully

---

### Phase 8: Test Backend (3 minutes)

```bash
# Get your service URL
SERVICE_URL=$(gcloud run services describe cloqr-backend \
  --region us-central1 \
  --format="value(status.url)")

echo "Your backend URL: $SERVICE_URL"

# Test health endpoint
curl $SERVICE_URL/health

# Should return: {"status":"ok","timestamp":"..."}

# Test email config
curl $SERVICE_URL/api/test/email-config

# Test database connection (should return error if not authenticated, which is good)
curl $SERVICE_URL/api/auth/login -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}'
```

**Checklist:**
- [ ] Health endpoint returns OK
- [ ] Email config shows configured
- [ ] API endpoints responding

---

### Phase 9: Update Mobile App (5 minutes)

Edit `mobile/lib/config/api_config.dart`:

```dart
class ApiConfig {
  // PRODUCTION: Replace with your Cloud Run URL
  static const String baseUrl = 'https://cloqr-backend-xxxxx-uc.a.run.app/api';
  static const String socketUrl = 'https://cloqr-backend-xxxxx-uc.a.run.app';
  
  // Auth endpoints
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String setupPin = '$baseUrl/auth/setup-pin';
  static const String verifyPin = '$baseUrl/auth/verify-pin';
  
  // Profile endpoints
  static const String profile = '$baseUrl/profile';
  static const String selectAvatar = '$baseUrl/profile/avatar';
  static const String uploadPhoto = '$baseUrl/profile/photo';
  static const String reportUser = '$baseUrl/profile/report';
  static const String blockUser = '$baseUrl/profile/block';
  
  // Match endpoints
  static const String matchQueue = '$baseUrl/match/queue';
  static const String swipe = '$baseUrl/match/swipe';
  static const String matches = '$baseUrl/match/matches';
  static const String studyPartners = '$baseUrl/match/study-partners';
  
  // Chat endpoints
  static const String chats = '$baseUrl/chat';
  static const String createChat = '$baseUrl/chat/create';
  
  // Room endpoints
  static const String rooms = '$baseUrl/rooms';
  static const String createRoom = '$baseUrl/rooms/create';
  static const String joinRoom = '$baseUrl/rooms/join';
}
```

**Checklist:**
- [ ] API URL updated with Cloud Run URL
- [ ] Socket URL updated
- [ ] File saved

---

### Phase 10: Build Release APK (5 minutes)

```bash
cd mobile

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# APK location:
# mobile/build/app/outputs/flutter-apk/app-release.apk
```

**Checklist:**
- [ ] Build completed successfully
- [ ] APK file exists
- [ ] APK size reasonable (< 50MB)

---

### Phase 11: Test Everything (10 minutes)

1. **Install APK on your phone:**
   ```bash
   # Transfer APK to phone via USB or upload to Drive
   adb install mobile/build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Test user registration:**
   - [ ] Open app
   - [ ] Enter student email
   - [ ] Receive OTP email
   - [ ] Verify OTP
   - [ ] Complete profile setup

3. **Test admin login:**
   - [ ] Use admin email: brianvocaldo@gmail.com
   - [ ] Use admin password: kiss2121
   - [ ] Should skip OTP verification

4. **Test features:**
   - [ ] Profile creation
   - [ ] Avatar selection
   - [ ] Swipe matching
   - [ ] Chat messaging
   - [ ] Room creation
   - [ ] QR code scanning

---

## Monitoring & Maintenance

### View Logs
```bash
# Real-time logs
gcloud run services logs read cloqr-backend \
  --region us-central1 \
  --limit 50 \
  --follow

# Recent errors
gcloud run services logs read cloqr-backend \
  --region us-central1 \
  --limit 100 | grep ERROR
```

### View Metrics
```bash
# Open Cloud Console
gcloud run services describe cloqr-backend --region us-central1

# Or visit: https://console.cloud.google.com/run
```

### Update Backend
```bash
cd cloqr-backend
# Make your changes
gcloud run deploy cloqr-backend --source . --region us-central1
```

### Update Environment Variable
```bash
gcloud run services update cloqr-backend \
  --region us-central1 \
  --set-env-vars "NEW_VAR=value"
```

---

## Cost Breakdown

### Monthly Costs
- **Cloud Run**: FREE (2M requests/month included)
- **Cloud SQL** (db-f1-micro): ~$7/month
- **Redis** (basic, 1GB): ~$30/month
- **Cloud Storage**: ~$0.02/GB/month
- **Bandwidth**: First 1GB free, then $0.12/GB

**Total: ~$37/month** (assuming moderate usage)

### Free Tier Benefits
- 2 million Cloud Run requests/month FREE
- Cloud Run scales to zero (no cost when idle)
- $300 free credit for new Google Cloud users (lasts 3 months)

---

## Troubleshooting

### Backend not responding
```bash
# Check service status
gcloud run services describe cloqr-backend --region us-central1

# Check logs
gcloud run services logs read cloqr-backend --region us-central1 --limit 100

# Check if service is running
curl https://YOUR_SERVICE_URL/health
```

### Database connection issues
```bash
# Check Cloud SQL status
gcloud sql instances list

# Check connection name
gcloud sql instances describe cloqr-db --format="value(connectionName)"

# Test connection
gcloud sql connect cloqr-db --user=cloqr_user --database=cloqr
```

### Redis connection issues
```bash
# Check Redis status
gcloud redis instances list --region us-central1

# Get Redis details
gcloud redis instances describe cloqr-redis --region us-central1
```

### Mobile app can't connect
1. Check API URL in `api_config.dart`
2. Ensure URL has `/api` at the end
3. Test backend URL in browser
4. Check phone has internet connection
5. Rebuild APK after URL change

---

## Quick Commands Reference

```bash
# Deploy backend
cd cloqr-backend && gcloud run deploy cloqr-backend --source . --region us-central1

# View logs
gcloud run services logs read cloqr-backend --region us-central1 --limit 50

# Get service URL
gcloud run services describe cloqr-backend --region us-central1 --format="value(status.url)"

# Update env var
gcloud run services update cloqr-backend --region us-central1 --set-env-vars "KEY=value"

# Build APK
cd mobile && flutter build apk --release

# Check Cloud SQL
gcloud sql instances list

# Check Redis
gcloud redis instances list --region us-central1
```

---

## Success Criteria

✅ **Backend:**
- [ ] Deployed to Cloud Run
- [ ] Health endpoint returns 200 OK
- [ ] Environment variables configured
- [ ] Cloud SQL connected
- [ ] Redis connected

✅ **Database:**
- [ ] Cloud SQL instance running
- [ ] Database schema imported
- [ ] Tables created

✅ **Mobile App:**
- [ ] API URL updated
- [ ] Release APK built
- [ ] APK tested on device

✅ **Features:**
- [ ] User registration works
- [ ] OTP emails sent
- [ ] Admin login works
- [ ] Profile creation works
- [ ] Matching works
- [ ] Chat works
- [ ] Rooms work
- [ ] QR codes work

---

## Next Steps After Deployment

1. **Distribute APK:**
   - Upload to Google Drive
   - Share link with users
   - Or publish to Google Play Store

2. **Monitor Usage:**
   - Check Cloud Console daily
   - Monitor costs
   - Review logs for errors

3. **Optimize:**
   - Add caching
   - Optimize database queries
   - Add CDN for images

4. **Scale:**
   - Increase Cloud Run instances if needed
   - Upgrade Cloud SQL tier if needed
   - Add load balancing

---

## You're Ready! 🚀

Follow this guide step by step, and your app will be live in about 45 minutes!

**Start with Phase 1** and work through each phase carefully.

Good luck! 🎉
