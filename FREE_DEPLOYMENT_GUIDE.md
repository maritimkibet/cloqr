# 100% FREE Deployment Guide

## Overview

Deploy your Cloqr app completely FREE using:
- **Google Cloud Run** - FREE (2M requests/month)
- **Supabase PostgreSQL** - FREE (500MB database)
- **Upstash Redis** - FREE (10K commands/day)

**Total Cost: $0/month** 🎉

---

## Step 1: Deploy Backend to Cloud Run (FREE)

### 1.1 Login and Create Project

```bash
# Login
gcloud auth login

# Create project
gcloud projects create cloqr-app --name="Cloqr"
gcloud config set project cloqr-app

# Enable billing (required but won't charge for free tier)
# Visit: https://console.cloud.google.com/billing
```

### 1.2 Deploy to Cloud Run

```bash
cd cloqr-backend

# Deploy (stays within FREE tier)
gcloud run deploy cloqr-backend \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10
```

**You'll get a URL like:**
```
https://cloqr-backend-xxxxx-uc.a.run.app
```

**Cost: $0** (within 2M requests/month free tier)

---

## Step 2: Set Up FREE PostgreSQL (Supabase)

### 2.1 Create Supabase Account

1. Go to: https://supabase.com
2. Sign up (FREE account)
3. Create new project
4. Choose region (closest to you)
5. Set database password

### 2.2 Get Connection Details

In Supabase dashboard:
1. Go to **Settings** → **Database**
2. Copy connection string:

```
postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432/postgres
```

### 2.3 Run Database Setup

```bash
# Install psql if needed
sudo apt-get install postgresql-client

# Connect to Supabase
psql "postgresql://postgres:[PASSWORD]@db.xxxxx.supabase.co:5432/postgres"

# Paste your setup_database.sql content
\i cloqr-backend/setup_database.sql
```

**Cost: $0** (FREE tier: 500MB database, 2GB bandwidth)

---

## Step 3: Set Up FREE Redis (Upstash)

### 3.1 Create Upstash Account

1. Go to: https://upstash.com
2. Sign up (FREE account)
3. Create Redis database
4. Choose region (closest to you)

### 3.2 Get Connection Details

In Upstash dashboard:
1. Copy **Endpoint** (e.g., `redis-xxxxx.upstash.io`)
2. Copy **Port** (usually `6379`)
3. Copy **Password**

**Cost: $0** (FREE tier: 10K commands/day)

---

## Step 4: Configure Environment Variables

```bash
# Update Cloud Run with FREE database connections
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
  --set-env-vars "ADMIN_EMAIL=brianvocaldo@gmail.com" \
  --set-env-vars "ADMIN_PASSWORD=kiss2121" \
  --set-env-vars "EMAIL_USER=brianvocaldo@gmail.com" \
  --set-env-vars "EMAIL_PASSWORD=ujac lgxh wegg bfxs" \
  --set-env-vars "ALLOWED_EMAIL_DOMAINS=edu,ac.za"
```

---

## Step 5: Update Backend for Upstash Redis

Upstash Redis requires TLS. Update `cloqr-backend/src/config/redis.js`:

```javascript
const redis = require('redis');

const client = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    tls: true, // Required for Upstash
  },
  password: process.env.REDIS_PASSWORD,
});

client.on('error', (err) => console.error('Redis error:', err));
client.connect();

module.exports = client;
```

Redeploy:
```bash
cd cloqr-backend
gcloud run deploy cloqr-backend --source . --region us-central1
```

---

## Step 6: Update Mobile App

Edit `mobile/lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://cloqr-backend-xxxxx-uc.a.run.app';
  
  static const String register = '$baseUrl/api/auth/register';
  static const String login = '$baseUrl/api/auth/login';
  // ... rest stays the same
}
```

---

## Step 7: Build Release APK

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

APK location: `mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## Cost Breakdown

### Monthly Costs: $0

| Service | Free Tier | Your Usage | Cost |
|---------|-----------|------------|------|
| Cloud Run | 2M requests/month | ~100K/month | $0 |
| Supabase PostgreSQL | 500MB database | ~50MB | $0 |
| Upstash Redis | 10K commands/day | ~5K/day | $0 |
| **Total** | | | **$0** |

---

## Free Tier Limits

### Cloud Run (Google)
- ✅ 2 million requests/month
- ✅ 360,000 GB-seconds memory
- ✅ 180,000 vCPU-seconds
- ✅ 1 GB network egress

### Supabase (PostgreSQL)
- ✅ 500 MB database storage
- ✅ 2 GB bandwidth
- ✅ 50 MB file storage
- ✅ Unlimited API requests

### Upstash (Redis)
- ✅ 10,000 commands per day
- ✅ 256 MB storage
- ✅ Global replication

---

## When You'll Need to Pay

### Cloud Run
- After 2 million requests/month
- **Cost**: ~$0.40 per million requests after free tier

### Supabase
- After 500MB database
- **Cost**: $25/month for Pro plan (8GB database)

### Upstash
- After 10K commands/day
- **Cost**: $0.20 per 100K commands

---

## Scaling Strategy

### Start FREE (0-1000 users)
- Cloud Run free tier
- Supabase free tier
- Upstash free tier
- **Cost: $0/month**

### Small Scale (1000-5000 users)
- Still within free tiers!
- **Cost: $0/month**

### Medium Scale (5000-10000 users)
- May exceed Supabase free tier
- Upgrade to Supabase Pro: $25/month
- **Cost: $25/month**

### Large Scale (10000+ users)
- Upgrade Supabase: $25/month
- May exceed Cloud Run free tier: ~$10/month
- May exceed Upstash: ~$10/month
- **Cost: ~$45/month**

---

## Alternative: 100% Firebase (Also FREE)

If you want pure Firebase, you can rewrite to use:
- **Firestore** (database) - FREE tier
- **Realtime Database** (cache) - FREE tier
- **Cloud Functions** (backend) - FREE tier
- **Firebase Storage** (files) - FREE tier

**Cost: $0/month**

But requires rewriting your backend code (2-3 days of work).

---

## Monitoring Your Usage

### Cloud Run
```bash
# View usage
gcloud run services describe cloqr-backend --region us-central1
```

Or visit: https://console.cloud.google.com/run

### Supabase
- Dashboard shows database size and bandwidth
- Visit: https://app.supabase.com

### Upstash
- Dashboard shows command count
- Visit: https://console.upstash.com

---

## Summary

✅ **Backend**: Cloud Run (FREE - 2M requests/month)
✅ **Database**: Supabase (FREE - 500MB)
✅ **Cache**: Upstash (FREE - 10K commands/day)
✅ **Total Cost**: $0/month

Your app can handle **thousands of users** completely FREE!

Only pay when you grow beyond free tiers (which is a good problem to have! 🎉)

---

## Quick Start Commands

```bash
# 1. Deploy backend
cd cloqr-backend
gcloud run deploy cloqr-backend --source . --region us-central1

# 2. Set up Supabase (web UI)
# Visit: https://supabase.com

# 3. Set up Upstash (web UI)
# Visit: https://upstash.com

# 4. Configure environment variables
gcloud run services update cloqr-backend --region us-central1 \
  --set-env-vars "DB_HOST=your-supabase-host" \
  --set-env-vars "REDIS_HOST=your-upstash-host"

# 5. Build APK
cd mobile
flutter build apk --release
```

**You're done! 100% FREE deployment!** 🚀
