# 🚀 Deploy Your App NOW - Step by Step

## What We're Doing

Deploying your app 100% FREE using:
1. **Google Cloud Run** - Backend (FREE)
2. **Supabase** - PostgreSQL Database (FREE)
3. **Upstash** - Redis Cache (FREE)

**Total Time**: 30 minutes
**Total Cost**: $0/month

---

## STEP 1: Deploy Backend to Cloud Run (10 minutes)

### 1.1 Open a New Terminal

Press `Ctrl+Alt+T` or open a new terminal window.

### 1.2 Login to Google Cloud

```bash
gcloud auth login
```

This will open your browser. Login with your Google account.

### 1.3 Create Project

```bash
# Create project
gcloud projects create cloqr-app --name="Cloqr Dating App"

# Set as active project
gcloud config set project cloqr-app
```

### 1.4 Enable Billing

**IMPORTANT**: You need to enable billing, but you won't be charged (free tier).

1. Go to: https://console.cloud.google.com/billing
2. Click "Link a billing account"
3. Add a payment method (won't charge unless you exceed 2M requests/month)
4. Link to your `cloqr-app` project

### 1.5 Enable Required APIs

```bash
# Enable Cloud Run
gcloud services enable run.googleapis.com

# Enable Cloud Build
gcloud services enable cloudbuild.googleapis.com
```

### 1.6 Deploy Backend

```bash
cd ~/Desktop/date/cloqr-backend

# Deploy to Cloud Run (takes 3-5 minutes)
gcloud run deploy cloqr-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10
```

**Wait for deployment to complete...**

You'll see:
```
Service [cloqr-backend] revision [cloqr-backend-00001] has been deployed.
Service URL: https://cloqr-backend-xxxxx-uc.a.run.app
```

**✅ SAVE THIS URL!** Write it down or copy it.

---

## STEP 2: Set Up FREE Database (Supabase) (5 minutes)

### 2.1 Create Supabase Account

1. Go to: https://supabase.com
2. Click "Start your project"
3. Sign up with Google or GitHub (FREE)

### 2.2 Create New Project

1. Click "New Project"
2. **Organization**: Create new or use existing
3. **Name**: `cloqr-database`
4. **Database Password**: Create a strong password (SAVE THIS!)
5. **Region**: Choose closest to you (e.g., `us-east-1`)
6. Click "Create new project"

**Wait 2-3 minutes for database to be created...**

### 2.3 Get Connection Details

1. In Supabase dashboard, go to **Settings** (gear icon)
2. Click **Database**
3. Scroll to **Connection string**
4. Copy the **URI** (looks like):
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432/postgres
   ```

**✅ SAVE THIS!** You'll need:
- **Host**: `db.xxxxx.supabase.co`
- **Password**: Your database password

### 2.4 Set Up Database Tables

1. In Supabase dashboard, click **SQL Editor**
2. Click "New query"
3. Open `~/Desktop/date/cloqr-backend/setup_database.sql` on your computer
4. Copy ALL the SQL content
5. Paste into Supabase SQL Editor
6. Click "Run" (bottom right)

**✅ Database tables created!**

---

## STEP 3: Set Up FREE Redis (Upstash) (5 minutes)

### 3.1 Create Upstash Account

1. Go to: https://console.upstash.com
2. Click "Sign Up"
3. Sign up with Google or GitHub (FREE)

### 3.2 Create Redis Database

1. Click "Create Database"
2. **Name**: `cloqr-redis`
3. **Type**: Select "Regional"
4. **Region**: Choose closest to you (e.g., `us-east-1`)
5. **TLS**: Keep enabled
6. Click "Create"

### 3.3 Get Connection Details

1. Click on your `cloqr-redis` database
2. Scroll to **REST API** section
3. Copy these values:
   - **Endpoint**: `redis-xxxxx.upstash.io`
   - **Port**: `6379`
   - **Password**: Click "Show" and copy

**✅ SAVE THESE!**

---

## STEP 4: Configure Environment Variables (5 minutes)

Now connect everything together!

### 4.1 Update Cloud Run Configuration

Replace the placeholders with YOUR actual values:

```bash
gcloud run services update cloqr-backend \
  --region us-central1 \
  --set-env-vars "NODE_ENV=production" \
  --set-env-vars "DB_HOST=db.xxxxx.supabase.co" \
  --set-env-vars "DB_PORT=5432" \
  --set-env-vars "DB_NAME=postgres" \
  --set-env-vars "DB_USER=postgres" \
  --set-env-vars "DB_PASSWORD=YOUR_SUPABASE_PASSWORD" \
  --set-env-vars "REDIS_HOST=redis-xxxxx.upstash.io" \
  --set-env-vars "REDIS_PORT=6379" \
  --set-env-vars "REDIS_PASSWORD=YOUR_UPSTASH_PASSWORD" \
  --set-env-vars "JWT_SECRET=$(openssl rand -base64 32)" \
  --set-env-vars "JWT_EXPIRES_IN=7d" \
  --set-env-vars "ADMIN_EMAIL=brianvocaldo@gmail.com" \
  --set-env-vars "ADMIN_PASSWORD=kiss2121" \
  --set-env-vars "EMAIL_USER=brianvocaldo@gmail.com" \
  --set-env-vars "EMAIL_PASSWORD=ujac lgxh wegg bfxs" \
  --set-env-vars "ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.edu,university.edu"
```

**Replace**:
- `db.xxxxx.supabase.co` → Your Supabase host
- `YOUR_SUPABASE_PASSWORD` → Your Supabase password
- `redis-xxxxx.upstash.io` → Your Upstash endpoint
- `YOUR_UPSTASH_PASSWORD` → Your Upstash password

### 4.2 Test Your Backend

```bash
# Get your service URL
SERVICE_URL=$(gcloud run services describe cloqr-backend \
  --region us-central1 \
  --format="value(status.url)")

# Test health endpoint
curl $SERVICE_URL/health
```

Should return:
```json
{"status":"ok","timestamp":"2024-12-04T..."}
```

**✅ Backend is live!**

---

## STEP 5: Update Mobile App (3 minutes)

### 5.1 Update API URL

Edit `mobile/lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Replace with YOUR Cloud Run URL
  static const String baseUrl = 'https://cloqr-backend-xxxxx-uc.a.run.app';
  
  // Rest stays the same
  static const String register = '$baseUrl/api/auth/register';
  static const String login = '$baseUrl/api/auth/login';
  static const String sendOtp = '$baseUrl/api/auth/send-otp';
  static const String verifyOtp = '$baseUrl/api/auth/verify-otp';
  static const String profile = '$baseUrl/api/profile';
  static const String users = '$baseUrl/api/users';
  static const String matches = '$baseUrl/api/matches';
  static const String chats = '$baseUrl/api/chats';
  static const String rooms = '$baseUrl/api/rooms';
  static const String setupPin = '$baseUrl/api/auth/setup-pin';
  static const String verifyPin = '$baseUrl/api/auth/verify-pin';
}
```

---

## STEP 6: Build Release APK (2 minutes)

```bash
cd ~/Desktop/date/mobile

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

**Your APK is ready!**

Location: `mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## STEP 7: Test Everything (5 minutes)

### 7.1 Install APK on Your Phone

```bash
# If phone is connected via USB
adb install mobile/build/app/outputs/flutter-apk/app-release.apk
```

Or copy the APK to your phone and install manually.

### 7.2 Test Features

1. **Open app**
2. **Register** with a student email
3. **Check email** for OTP code
4. **Enter OTP** and complete profile
5. **Test admin login** (brianvocaldo@gmail.com / kiss2121)
6. **Test all features**

**✅ Everything works!**

---

## Summary

### What You Just Did:

✅ Deployed backend to Google Cloud Run (FREE)
✅ Set up PostgreSQL database on Supabase (FREE)
✅ Set up Redis cache on Upstash (FREE)
✅ Connected everything together
✅ Built release APK
✅ Tested the app

### Your Live URLs:

- **Backend**: `https://cloqr-backend-xxxxx-uc.a.run.app`
- **Database**: Supabase (500MB free)
- **Redis**: Upstash (10K commands/day free)

### Monthly Cost: $0

You can now share your APK with users!

---

## Next Steps

### Distribute Your App:

**Option A: Google Play Store**
1. Create developer account ($25 one-time)
2. Upload APK
3. Users download from Play Store

**Option B: Direct Distribution**
1. Upload APK to Google Drive
2. Share link with users
3. Users install directly

### Monitor Your App:

```bash
# View logs
gcloud run services logs read cloqr-backend --region us-central1

# View metrics
# Visit: https://console.cloud.google.com/run
```

### Update Your App:

```bash
# Make changes to backend
cd cloqr-backend

# Redeploy
gcloud run deploy cloqr-backend --source . --region us-central1
```

---

## Troubleshooting

### Backend not responding
```bash
# Check logs
gcloud run services logs read cloqr-backend --region us-central1 --limit 50
```

### Database connection failed
- Verify Supabase host and password
- Check if database tables were created

### Redis connection failed
- Verify Upstash endpoint and password
- Make sure TLS is enabled

---

## You're Done! 🎉

Your dating app is now live and running 100% FREE on Google Cloud!

Users can download your APK and start using it immediately.

**Congratulations!** 🚀
