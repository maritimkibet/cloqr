# 🚀 Deploy to Render.com (100% FREE - No Credit Card!)

## Why Render.com?

- ✅ **Completely FREE** tier (no credit card required)
- ✅ **750 hours/month** free (enough for 24/7 operation)
- ✅ **PostgreSQL database** included FREE
- ✅ **Redis** included FREE
- ✅ **Auto-deploy** from Git
- ✅ **HTTPS** included
- ✅ **No billing surprises**

---

## 🎯 Quick Deployment (10 minutes)

### Step 1: Create Render Account (2 minutes)

1. Go to: https://render.com
2. Click "Get Started"
3. Sign up with GitHub (or email)
4. **No credit card required!**

---

### Step 2: Push Code to GitHub (3 minutes)

```bash
# Initialize git in backend folder
cd cloqr-backend

# Create .gitignore if not exists
cat > .gitignore << 'EOF'
node_modules/
.env
uploads/*
!uploads/.gitkeep
*.log
EOF

# Initialize git
git init
git add .
git commit -m "Initial commit for Render deployment"

# Create GitHub repo and push
# (Or use existing repo)
```

**Or use GitHub Desktop / VS Code to push**

---

### Step 3: Deploy Backend on Render (5 minutes)

1. **Go to Render Dashboard**: https://dashboard.render.com

2. **Click "New +"** → **"Web Service"**

3. **Connect your GitHub repo** (or use public repo)

4. **Configure:**
   - **Name**: `cloqr-backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: **Free** ✅

5. **Add Environment Variables** (click "Advanced"):
   ```
   NODE_ENV=production
   PORT=10000
   JWT_SECRET=your_secure_random_string_here
   JWT_EXPIRES_IN=7d
   ADMIN_EMAIL=brianvocaldo@gmail.com
   ADMIN_PASSWORD=kiss2121
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USER=brianvocaldo@gmail.com
   EMAIL_PASSWORD=ujac lgxh wegg bfxs
   ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.edu,university.edu
   MAX_FILE_SIZE=5242880
   ```

6. **Click "Create Web Service"**

7. **Wait 3-5 minutes** for deployment

8. **Get your URL**: `https://cloqr-backend-xxxx.onrender.com`

---

### Step 4: Add PostgreSQL Database (2 minutes)

1. **In Render Dashboard**, click "New +" → **"PostgreSQL"**

2. **Configure:**
   - **Name**: `cloqr-db`
   - **Database**: `cloqr`
   - **User**: `cloqr_user`
   - **Plan**: **Free** ✅

3. **Click "Create Database"**

4. **Copy connection details** (Internal Database URL)

5. **Go back to your Web Service** → **Environment**

6. **Add database variables:**
   ```
   DATABASE_URL=<paste_internal_database_url>
   ```

   Or separately:
   ```
   DB_HOST=<from Render>
   DB_PORT=5432
   DB_NAME=cloqr
   DB_USER=cloqr_user
   DB_PASSWORD=<from Render>
   ```

7. **Save Changes** (auto-redeploys)

---

### Step 5: Add Redis (2 minutes)

1. **In Render Dashboard**, click "New +" → **"Redis"**

2. **Configure:**
   - **Name**: `cloqr-redis`
   - **Plan**: **Free** ✅

3. **Click "Create Redis"**

4. **Copy connection details** (Internal Redis URL)

5. **Go back to your Web Service** → **Environment**

6. **Add Redis variables:**
   ```
   REDIS_URL=<paste_internal_redis_url>
   ```

   Or separately:
   ```
   REDIS_HOST=<from Render>
   REDIS_PORT=6379
   ```

7. **Save Changes**

---

### Step 6: Initialize Database (2 minutes)

1. **Connect to your database:**
   - In Render Dashboard → PostgreSQL → **"Connect"**
   - Use **PSQL Command** or **External Connection**

2. **Run your SQL schema:**
   ```bash
   # Copy your schema
   cat cloqr-backend/setup_database.sql
   
   # Paste into PSQL connection
   ```

---

### Step 7: Update Mobile App (2 minutes)

```bash
# Update API URL
./update-mobile-url.sh

# When prompted, enter your Render URL:
# https://cloqr-backend-xxxx.onrender.com
```

Or manually edit `mobile/lib/config/api_config.dart`:

```dart
static const String baseUrl = 'https://cloqr-backend-xxxx.onrender.com/api';
static const String socketUrl = 'https://cloqr-backend-xxxx.onrender.com';
```

---

### Step 8: Build APK (3 minutes)

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

---

## ✅ Done! Your App is Live!

**Backend URL**: `https://cloqr-backend-xxxx.onrender.com`
**APK Location**: `mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## 🎯 Render Free Tier Limits

| Resource | Free Tier |
|----------|-----------|
| Web Services | 750 hours/month (24/7 for 1 app) |
| PostgreSQL | 1GB storage, 97 hours/month |
| Redis | 25MB storage |
| Bandwidth | 100GB/month |
| Build Minutes | 500 minutes/month |

**Perfect for testing and small-scale deployment!**

---

## 📊 Important Notes

### Free Tier Limitations

1. **Services sleep after 15 minutes of inactivity**
   - First request after sleep takes ~30 seconds
   - Subsequent requests are fast
   - **Solution**: Use a cron job to ping every 14 minutes

2. **PostgreSQL database expires after 90 days**
   - You'll need to create a new one
   - Export data before expiry
   - **Solution**: Upgrade to paid ($7/month) for persistent DB

3. **Redis is limited to 25MB**
   - Enough for sessions and cache
   - **Solution**: Upgrade if you need more

---

## 🔧 Keep Your App Awake (Optional)

To prevent your app from sleeping:

### Option 1: Use Cron-job.org (Free)

1. Go to: https://cron-job.org
2. Create account
3. Add job:
   - **URL**: `https://cloqr-backend-xxxx.onrender.com/health`
   - **Interval**: Every 14 minutes
   - **Method**: GET

### Option 2: Use UptimeRobot (Free)

1. Go to: https://uptimerobot.com
2. Create account
3. Add monitor:
   - **URL**: `https://cloqr-backend-xxxx.onrender.com/health`
   - **Interval**: 5 minutes

---

## 🚀 Deployment Checklist

- [ ] Render account created
- [ ] Backend deployed
- [ ] PostgreSQL database created
- [ ] Redis created
- [ ] Environment variables set
- [ ] Database schema imported
- [ ] Mobile app URL updated
- [ ] APK built
- [ ] App tested
- [ ] (Optional) Uptime monitor set up

---

## 💰 Cost Comparison

| Platform | Free Tier | Paid |
|----------|-----------|------|
| **Render** | ✅ FREE (750hrs) | $7/month |
| Google Cloud | ❌ Requires credit card | $37/month |
| Heroku | ❌ No free tier | $5/month |
| Railway | $5 credit | $5/month |

**Render is the best free option!**

---

## 🆘 Troubleshooting

### Backend not responding
- Check logs in Render Dashboard
- Verify environment variables
- Check if service is sleeping

### Database connection failed
- Verify DATABASE_URL is set
- Check database is running
- Verify schema is imported

### App sleeps after 15 minutes
- Set up uptime monitor (see above)
- Or upgrade to paid plan ($7/month)

---

## 📚 Next Steps

1. **Test your app** thoroughly
2. **Set up uptime monitor** to prevent sleeping
3. **Monitor usage** in Render Dashboard
4. **Upgrade to paid** if you need:
   - No sleeping
   - Persistent database
   - More resources

---

## ✅ You're Live!

Your app is now deployed on Render.com with:
- ✅ FREE hosting
- ✅ FREE database
- ✅ FREE Redis
- ✅ HTTPS included
- ✅ No credit card required
- ✅ No billing surprises

**Distribute your APK and start getting users!** 🎉

---

**Render Dashboard**: https://dashboard.render.com
**Documentation**: https://render.com/docs
