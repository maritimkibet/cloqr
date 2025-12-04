# Firebase Deployment Guide

## Overview

Firebase offers two ways to deploy your backend:

### Option 1: Cloud Functions (Recommended) ✅
- Serverless - no server management
- Auto-scales
- Pay only for usage
- **BUT**: Need to replace PostgreSQL with Firestore

### Option 2: Google Cloud Run (Easier) ✅✅
- Deploy your current backend as-is
- Keep PostgreSQL (Cloud SQL)
- Keep Redis (Memorystore)
- Minimal code changes

**I recommend Option 2 (Cloud Run) because you can keep your current code!**

---

## Option 2: Deploy to Google Cloud Run (Easiest)

This lets you use your existing Node.js + PostgreSQL + Redis backend with minimal changes.

### Step 1: Install Google Cloud CLI

```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Login
gcloud auth login

# Create project
gcloud projects create cloqr-app --name="Cloqr"
gcloud config set project cloqr-app
```

### Step 2: Enable Required APIs

```bash
gcloud services enable run.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable redis.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

### Step 3: Create Dockerfile

Create `cloqr-backend/Dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Expose port
EXPOSE 8080

# Start server
CMD ["node", "src/server.js"]
```

### Step 4: Update server.js for Cloud Run

Cloud Run uses port 8080. Update `cloqr-backend/src/server.js`:

```javascript
const PORT = process.env.PORT || 8080; // Changed from 3000
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Step 5: Create .dockerignore

Create `cloqr-backend/.dockerignore`:

```
node_modules
npm-debug.log
.env
.git
.gitignore
README.md
uploads/*
!uploads/.gitkeep
```

### Step 6: Deploy to Cloud Run

```bash
cd cloqr-backend

# Build and deploy
gcloud run deploy cloqr-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars NODE_ENV=production
```

This will give you a URL like:
```
https://cloqr-backend-xxxxx-uc.a.run.app
```

### Step 7: Set Up Cloud SQL (PostgreSQL)

```bash
# Create PostgreSQL instance
gcloud sql instances create cloqr-db \
  --database-version=POSTGRES_15 \
  --tier=db-f1-micro \
  --region=us-central1

# Create database
gcloud sql databases create cloqr --instance=cloqr-db

# Create user
gcloud sql users create cloqr_user \
  --instance=cloqr-db \
  --password=YOUR_SECURE_PASSWORD

# Get connection name
gcloud sql instances describe cloqr-db --format="value(connectionName)"
```

### Step 8: Set Up Memorystore (Redis)

```bash
# Create Redis instance
gcloud redis instances create cloqr-redis \
  --size=1 \
  --region=us-central1 \
  --redis-version=redis_7_0

# Get Redis host
gcloud redis instances describe cloqr-redis --region=us-central1 --format="value(host)"
```

### Step 9: Update Cloud Run with Database Connections

```bash
gcloud run services update cloqr-backend \
  --add-cloudsql-instances=YOUR_CONNECTION_NAME \
  --set-env-vars DB_HOST=/cloudsql/YOUR_CONNECTION_NAME \
  --set-env-vars DB_NAME=cloqr \
  --set-env-vars DB_USER=cloqr_user \
  --set-env-vars DB_PASSWORD=YOUR_SECURE_PASSWORD \
  --set-env-vars REDIS_HOST=YOUR_REDIS_HOST \
  --set-env-vars JWT_SECRET=your_jwt_secret \
  --set-env-vars ADMIN_EMAIL=brianvocaldo@gmail.com \
  --set-env-vars ADMIN_PASSWORD=kiss2121 \
  --set-env-vars EMAIL_USER=brianvocaldo@gmail.com \
  --set-env-vars EMAIL_PASSWORD="ujac lgxh wegg bfxs" \
  --set-env-vars ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.edu
```

### Step 10: Initialize Database

```bash
# Connect to Cloud SQL
gcloud sql connect cloqr-db --user=cloqr_user --database=cloqr

# Run your setup SQL
\i /path/to/setup_database.sql
```

---

## Option 1: Firebase Cloud Functions (More Work)

If you want pure Firebase, you'll need to rewrite your backend to use Firestore instead of PostgreSQL.

### What Needs to Change:

1. **Database**: PostgreSQL → Firestore
2. **Cache**: Redis → Firebase Realtime Database
3. **Server**: Express → Cloud Functions
4. **File Storage**: Local uploads → Firebase Storage

### Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### Step 2: Initialize Firebase

```bash
cd cloqr-backend
firebase init

# Select:
# - Functions (JavaScript/TypeScript)
# - Firestore
# - Storage
```

### Step 3: Rewrite Backend for Firestore

This is a major rewrite. Example:

**Before (PostgreSQL)**:
```javascript
const result = await pool.query(
  'SELECT * FROM users WHERE email_hash = $1',
  [emailHash]
);
const user = result.rows[0];
```

**After (Firestore)**:
```javascript
const userDoc = await admin.firestore()
  .collection('users')
  .where('emailHash', '==', emailHash)
  .limit(1)
  .get();
const user = userDoc.docs[0]?.data();
```

### Step 4: Convert Routes to Cloud Functions

**Before (Express)**:
```javascript
app.post('/api/auth/login', authController.login);
```

**After (Cloud Functions)**:
```javascript
exports.login = functions.https.onRequest(async (req, res) => {
  // Your login logic
});
```

### Step 5: Deploy

```bash
firebase deploy --only functions
```

---

## Comparison

| Feature | Cloud Run | Cloud Functions |
|---------|-----------|-----------------|
| Current Code | ✅ Works as-is | ❌ Major rewrite |
| PostgreSQL | ✅ Cloud SQL | ❌ Must use Firestore |
| Redis | ✅ Memorystore | ❌ Must use Realtime DB |
| Setup Time | 30 minutes | Several days |
| Cost | ~$10/month | ~$5/month |
| Scaling | Auto | Auto |

---

## My Recommendation: Use Cloud Run

**Why?**
1. Your backend works as-is (no rewrite)
2. Keep PostgreSQL and Redis
3. Still part of Google Cloud (same as Firebase)
4. Easy to set up
5. Auto-scales like Firebase

**Steps**:
1. Create Dockerfile (5 minutes)
2. Deploy to Cloud Run (10 minutes)
3. Set up Cloud SQL (10 minutes)
4. Set up Memorystore (5 minutes)
5. Update mobile app URL (2 minutes)
6. Done! ✅

---

## Quick Start: Deploy to Cloud Run Now

Want me to help you deploy to Cloud Run right now? It's the fastest path and you can keep all your current code!

Just need:
1. Google Cloud account (free $300 credit)
2. 30 minutes
3. Your current backend code

After deployment:
- Backend URL: `https://cloqr-backend-xxxxx.run.app`
- Update mobile app with this URL
- Build APK
- Distribute to users!

Let me know if you want to proceed with Cloud Run or if you really want to rewrite everything for pure Firebase Cloud Functions!
