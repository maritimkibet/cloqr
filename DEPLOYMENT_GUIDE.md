# Production Deployment Guide

## Overview

When you deploy to production, users will:
1. Download your APK from Google Play Store or direct link
2. Install the app
3. App automatically connects to your cloud backend
4. Everything works - no setup needed!

## Current vs Production

### Development (Now)
```
[Your Computer]
  ├── Backend (Node.js) → http://10.10.8.33:3000
  ├── PostgreSQL Database
  └── Redis Cache

[User's Phone] → Connects to your computer (same network only)
```

### Production (After Deployment)
```
[Cloud Server - Always Online]
  ├── Backend (Node.js) → https://your-app.railway.app
  ├── PostgreSQL Database (Cloud)
  └── Redis Cache (Cloud)

[User's Phone] → Connects to cloud (works anywhere!)
```

## Recommended: Deploy to Railway

Railway is the easiest option - it's like Heroku but better.

### Step 1: Prepare Your Backend

1. **Add a Procfile** (tells Railway how to start your app):

```bash
cd cloqr-backend
```

Create `Procfile`:
```
web: node src/server.js
```

2. **Update package.json** to specify Node version:

```json
{
  "engines": {
    "node": "18.x"
  }
}
```

3. **Make sure your server listens on PORT from environment**:

Your `src/server.js` should have:
```javascript
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Step 2: Deploy to Railway

1. **Sign up**: Go to https://railway.app
2. **Create New Project**: Click "New Project"
3. **Deploy from GitHub**:
   - Connect your GitHub account
   - Select your repository
   - Railway auto-detects Node.js

4. **Add PostgreSQL**:
   - Click "New" → "Database" → "PostgreSQL"
   - Railway automatically sets DATABASE_URL

5. **Add Redis**:
   - Click "New" → "Database" → "Redis"
   - Railway automatically sets REDIS_URL

6. **Set Environment Variables**:
   Click on your service → Variables → Add:
   ```
   NODE_ENV=production
   JWT_SECRET=your_secure_random_string_here
   JWT_EXPIRES_IN=7d
   ADMIN_EMAIL=brianvocaldo@gmail.com
   ADMIN_PASSWORD=kiss2121
   EMAIL_USER=brianvocaldo@gmail.com
   EMAIL_PASSWORD=ujac lgxh wegg bfxs
   ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.edu,university.edu
   FRONTEND_URL=https://your-app.railway.app
   ```

7. **Deploy**: Railway automatically deploys!

8. **Get Your URL**: Railway gives you a URL like:
   ```
   https://cloqr-backend-production.up.railway.app
   ```

### Step 3: Update Mobile App

Update `mobile/lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Production URL from Railway
  static const String baseUrl = 'https://cloqr-backend-production.up.railway.app';
  
  // API endpoints
  static const String register = '$baseUrl/api/auth/register';
  static const String login = '$baseUrl/api/auth/login';
  // ... rest stays the same
}
```

### Step 4: Build Release APK

```bash
cd mobile
flutter build apk --release
```

Your APK will be at: `mobile/build/app/outputs/flutter-apk/app-release.apk`

### Step 5: Distribute to Users

**Option A: Google Play Store** (Recommended)
- Create Google Play Developer account ($25 one-time)
- Upload APK
- Users download from Play Store
- Automatic updates

**Option B: Direct Distribution**
- Upload APK to your website or Google Drive
- Share link with users
- Users enable "Install from Unknown Sources"
- Manual updates

## Alternative: Deploy to Render

Render is another great option (also free tier):

1. Go to https://render.com
2. Create "New Web Service"
3. Connect GitHub repo
4. Add PostgreSQL database
5. Add Redis instance
6. Set environment variables
7. Deploy!

## Alternative: Deploy to Heroku

Heroku is classic but no longer has free tier:

```bash
# Install Heroku CLI
curl https://cli-assets.heroku.com/install.sh | sh

# Login
heroku login

# Create app
cd cloqr-backend
heroku create your-app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Add Redis
heroku addons:create heroku-redis:mini

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your_secret
# ... set all other variables

# Deploy
git push heroku main
```

## Cost Comparison

### Railway (Recommended)
- **Free Tier**: $5 credit/month (enough for small apps)
- **Paid**: $5/month for hobby projects
- **Includes**: PostgreSQL + Redis + Hosting

### Render
- **Free Tier**: Available (with limitations)
- **Paid**: $7/month for web service
- **Database**: $7/month for PostgreSQL

### Heroku
- **Free Tier**: ❌ Removed
- **Paid**: $7/month minimum
- **Addons**: Extra cost for database/redis

### VPS (DigitalOcean)
- **Cost**: $6/month for basic droplet
- **Setup**: More complex (manual installation)
- **Control**: Full control over everything

## Database Migration

When you deploy, you need to set up your database:

1. **Railway automatically provides DATABASE_URL**
2. **Run your SQL setup**:

```bash
# Get database URL from Railway dashboard
# Then run:
psql YOUR_DATABASE_URL < cloqr-backend/setup_database.sql
```

Or use Railway's built-in SQL console.

## Testing Production

Before distributing to users:

1. **Test the backend**:
   ```bash
   curl https://your-app.railway.app/api/health
   ```

2. **Test with mobile app**:
   - Update api_config.dart with production URL
   - Build and install APK
   - Test registration, login, all features

3. **Monitor logs**:
   - Railway dashboard shows real-time logs
   - Check for errors

## What Users Experience

After deployment:

1. **User downloads APK** (from Play Store or link)
2. **User installs app** (one tap)
3. **User opens app** → Connects to your cloud backend
4. **User registers** → Gets OTP email
5. **User uses app** → Everything works!

**No backend setup needed for users!**

## Summary

**For Development** (Now):
- Backend runs on your computer
- Only works on your network
- Good for testing

**For Production** (Deploy):
- Backend runs on cloud server (Railway/Render/Heroku)
- Works anywhere in the world
- Users just install APK
- No setup required for users

**Recommended Path**:
1. Deploy backend to Railway (15 minutes)
2. Update mobile app with production URL
3. Build release APK
4. Upload to Google Play Store
5. Users download and use!

## Next Steps

Want me to help you:
1. Set up Railway deployment?
2. Configure the production environment?
3. Build the release APK?
4. Prepare for Play Store submission?

Let me know which deployment platform you prefer!
