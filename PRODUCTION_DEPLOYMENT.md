# 🚀 Production Deployment Guide

## ✅ Step 1: Code Deployed to GitHub

Your code has been pushed to GitHub and Render.com is automatically deploying it!

**GitHub Repo**: https://github.com/maritimkibet/cloqr

---

## ⏳ Step 2: Wait for Render Deployment (2-3 minutes)

1. Go to: https://dashboard.render.com
2. Click on **cloqr-backend** service
3. Watch the deployment logs
4. Wait for "Deploy succeeded" message

---

## 📊 Step 3: Run Database Migration

Once deployment succeeds, run the migration:

### Option A: Using Render Shell (Easiest)

1. Go to https://dashboard.render.com
2. Click on **cloqr-backend** service
3. Click **Shell** tab at the top
4. Run this command:
   ```bash
   node migrate-new-features.js
   ```
5. You should see: "✅ Migration completed successfully!"

### Option B: Using External Connection

1. Go to https://dashboard.render.com
2. Click on **cloqr-db** database
3. Click **Connect** → Copy **External Database URL**
4. On your local machine, run:
   ```bash
   psql <PASTE_DATABASE_URL_HERE> -f cloqr-backend/NEW_FEATURES_SCHEMA.sql
   ```

---

## 🧪 Step 4: Test the Backend

Test that the backend is working:

```bash
curl https://cloqr-backend.onrender.com/health
```

Should return: `{"status":"ok","timestamp":"..."}`

Test new features endpoint:
```bash
curl https://cloqr-backend.onrender.com/api/features/icebreaker
```

Should return: `{"error":"Authentication required"}` (this is correct!)

---

## 📱 Step 5: Build Flutter APK

Now build the production APK:

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

**Build time**: 3-5 minutes

**Output location**: `mobile/build/app/outputs/flutter-apk/app-release.apk`

**File size**: ~20-30 MB

---

## 📤 Step 6: Share the APK

### Option 1: Direct Share
1. Find the APK: `mobile/build/app/outputs/flutter-apk/app-release.apk`
2. Send via WhatsApp, Telegram, Email, Google Drive, etc.

### Option 2: Upload to Cloud
```bash
# Upload to Google Drive, Dropbox, or any file sharing service
# Then share the download link
```

### Option 3: ADB Install (if nearby)
```bash
adb install mobile/build/app/outputs/flutter-apk/app-release.apk
```

---

## 👥 Step 7: User Instructions

Send these instructions to your users:

### For Android Users:

1. **Download the APK** from the link you shared
2. **Enable "Install from Unknown Sources"**:
   - Go to Settings → Security
   - Enable "Unknown Sources" or "Install Unknown Apps"
3. **Install the APK**:
   - Open the downloaded file
   - Tap "Install"
4. **Open Cloqr app**
5. **Register**:
   - Use your .edu email
   - Verify OTP
   - Complete profile setup
6. **Start using!**

---

## 🎯 What Users Can Do

Once registered, users can:

✅ **Match & Swipe** - Find study partners or dates  
✅ **Events** - Create and attend campus events  
✅ **Chats** - Message matches  
✅ **Rooms** - Join QR code rooms  
✅ **Profile** - Customize their profile  

**New Features Available**:
- Events & Meetups 🎉
- Study Groups 📚
- Communities 🎮
- Polls 📊
- Badges 🏆
- Streaks 🔥
- Location Check-ins 📍
- Enhanced Safety 🛡️

---

## 🔧 Troubleshooting

### Backend Issues

**Problem**: Deployment failed  
**Solution**: Check Render logs, ensure all env vars are set

**Problem**: Migration failed  
**Solution**: Check database connection, run migration again

**Problem**: API not responding  
**Solution**: Check Render service is running, restart if needed

### App Issues

**Problem**: Can't install APK  
**Solution**: Enable "Unknown Sources" in Android settings

**Problem**: App crashes on startup  
**Solution**: Rebuild APK with `flutter clean` first

**Problem**: Can't connect to backend  
**Solution**: Check API config points to Render URL

---

## 📊 Monitoring

### Check Backend Health
```bash
curl https://cloqr-backend.onrender.com/health
```

### Check Database
1. Go to Render Dashboard
2. Click on cloqr-db
3. Check connection count and queries

### Check Logs
1. Go to Render Dashboard
2. Click on cloqr-backend
3. View Logs tab

---

## 🎉 Success Checklist

- [ ] Code pushed to GitHub
- [ ] Render deployment succeeded
- [ ] Database migration completed
- [ ] Backend health check passes
- [ ] Flutter APK built successfully
- [ ] APK shared with users
- [ ] Users can register and login
- [ ] All features working

---

## 🚨 Important Notes

1. **Free Tier Limitations**:
   - Render free tier spins down after 15 min of inactivity
   - First request after spin-down takes 30-60 seconds
   - Consider upgrading to paid tier for production

2. **Database Backups**:
   - Render free tier doesn't include automatic backups
   - Export data regularly: `pg_dump <DATABASE_URL> > backup.sql`

3. **Environment Variables**:
   - Never commit .env file to GitHub
   - Set sensitive vars in Render Dashboard

4. **Updates**:
   - To update: Push to GitHub, Render auto-deploys
   - Rebuild APK after backend changes
   - Users need to reinstall APK for app updates

---

## 📞 Support

If users have issues:
1. Check backend is running (health endpoint)
2. Verify they're using latest APK
3. Check Render logs for errors
4. Test registration flow yourself

---

## 🎊 Congratulations!

Your app is now live and accessible to anyone with the APK!

**Backend**: https://cloqr-backend.onrender.com  
**GitHub**: https://github.com/maritimkibet/cloqr  
**Status**: Production Ready ✅

Share the APK and watch your user base grow! 🚀
