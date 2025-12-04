# 🚀 Deploy NOW - 100% FREE (No Credit Card!)

## ✅ Your Backend is Ready for Render.com!

I've updated your code to work with Render.com's free tier. No billing, no credit card required!

---

## 🎯 Quick Deploy (5 clicks!)

### Option 1: One-Click Deploy (Easiest!)

**Click this button:**

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

Then:
1. Sign up/Login to Render (free, no credit card)
2. Connect your GitHub repo
3. Click "Apply"
4. Wait 5 minutes
5. Done! ✅

---

### Option 2: Manual Deploy (10 minutes)

#### Step 1: Push to GitHub (3 minutes)

```bash
cd cloqr-backend

# Initialize git
git init
git add .
git commit -m "Ready for Render deployment"

# Push to GitHub
# (Use GitHub Desktop or command line)
```

#### Step 2: Deploy on Render (5 minutes)

1. **Go to**: https://dashboard.render.com
2. **Sign up** (free, no credit card)
3. **Click "New +"** → **"Web Service"**
4. **Connect GitHub repo**
5. **Configure**:
   - Name: `cloqr-backend`
   - Environment: `Node`
   - Build: `npm install`
   - Start: `npm start`
   - Plan: **FREE** ✅
6. **Add Environment Variables**:
   ```
   NODE_ENV=production
   ADMIN_EMAIL=brianvocaldo@gmail.com
   ADMIN_PASSWORD=kiss2121
   EMAIL_USER=brianvocaldo@gmail.com
   EMAIL_PASSWORD=ujac lgxh wegg bfxs
   ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.edu
   ```
7. **Click "Create Web Service"**
8. **Wait 3-5 minutes**
9. **Get your URL**: `https://cloqr-backend-xxxx.onrender.com`

#### Step 3: Add Database (2 minutes)

1. **Click "New +"** → **"PostgreSQL"**
2. **Name**: `cloqr-db`
3. **Plan**: **FREE** ✅
4. **Create**
5. **Copy "Internal Database URL"**
6. **Go to Web Service** → **Environment**
7. **Add**: `DATABASE_URL=<paste_url>`
8. **Save** (auto-redeploys)

#### Step 4: Add Redis (2 minutes)

1. **Click "New +"** → **"Redis"**
2. **Name**: `cloqr-redis`
3. **Plan**: **FREE** ✅
4. **Create**
5. **Copy "Internal Redis URL"**
6. **Go to Web Service** → **Environment**
7. **Add**: `REDIS_URL=<paste_url>`
8. **Save**

---

## 📱 Update Mobile App

```bash
# Update API URL
./update-mobile-url.sh

# Enter your Render URL when prompted:
# https://cloqr-backend-xxxx.onrender.com

# Build APK
cd mobile
flutter build apk --release
```

---

## ✅ Done!

Your app is now:
- ✅ Deployed on Render (FREE)
- ✅ PostgreSQL database (FREE)
- ✅ Redis cache (FREE)
- ✅ HTTPS included
- ✅ No credit card required
- ✅ No billing surprises

**APK Location**: `mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## 💰 Render Free Tier

| Resource | Free Tier |
|----------|-----------|
| Web Service | 750 hours/month |
| PostgreSQL | 1GB, 90 days |
| Redis | 25MB |
| Bandwidth | 100GB/month |

**Perfect for your app!**

---

## ⚠️ Important Notes

1. **Service sleeps after 15 min inactivity**
   - First request takes ~30 seconds
   - Solution: Set up uptime monitor (free)

2. **Database expires after 90 days**
   - Export data before expiry
   - Or upgrade to paid ($7/month)

3. **Keep service awake** (optional):
   - Use https://uptimerobot.com (free)
   - Ping your `/health` endpoint every 5 minutes

---

## 🚀 Next Steps

1. **Deploy to Render** (see above)
2. **Update mobile app URL**
3. **Build APK**
4. **Test everything**
5. **Distribute to users!** 🎉

---

## 📚 Full Guide

See `DEPLOY_RENDER_FREE.md` for detailed instructions.

---

**Deploy now**: https://dashboard.render.com

**No credit card. No billing. 100% FREE!** 🎉
