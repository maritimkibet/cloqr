# 🚀 Firebase Deployment - Quick Reference Card

## ⚡ Deploy in 3 Commands

```bash
./verify-firebase-setup.sh    # Check if ready
./deploy-to-firebase.sh        # Deploy everything
./update-mobile-url.sh         # Update mobile app
```

---

## 📁 Files You Need

| File | Purpose |
|------|---------|
| `START_DEPLOYMENT_HERE.md` | **START HERE** - Quick guide |
| `FIREBASE_EVERYTHING_READY.md` | Complete overview |
| `deploy-to-firebase.sh` | Automated deployment |
| `verify-firebase-setup.sh` | Check setup |
| `update-mobile-url.sh` | Update mobile app |
| `test-deployment.sh` | Test deployment |

---

## 🔧 Essential Commands

```bash
# Deploy backend
cd cloqr-backend
gcloud run deploy cloqr-backend --source . --region us-central1

# View logs
gcloud run services logs read cloqr-backend --region us-central1 --limit 50

# Get service URL
gcloud run services describe cloqr-backend --region us-central1 --format="value(status.url)"

# Update env var
gcloud run services update cloqr-backend --region us-central1 --set-env-vars "KEY=value"

# Build APK
cd mobile && flutter build apk --release

# Test backend
curl https://YOUR-SERVICE-URL/health
```

---

## 💰 Cost

- **Free**: 2M requests/month + $300 credit
- **Paid**: ~$37/month (Cloud SQL + Redis)

---

## 🆘 Quick Fixes

```bash
# Not logged in?
gcloud auth login

# Check logs
gcloud run services logs read cloqr-backend --region us-central1 --limit 100

# Check service
gcloud run services describe cloqr-backend --region us-central1

# Check database
gcloud sql instances list

# Check Redis
gcloud redis instances list --region us-central1
```

---

## ✅ Success Check

```bash
# Should return: {"status":"ok","timestamp":"..."}
curl https://YOUR-SERVICE-URL/health
```

---

## 📱 Mobile App Update

Edit `mobile/lib/config/api_config.dart`:

```dart
static const String baseUrl = 'https://YOUR-SERVICE-URL/api';
```

Then:

```bash
cd mobile
flutter build apk --release
```

---

## 🎯 Next Steps

1. Run `./deploy-to-firebase.sh`
2. Wait 30 minutes
3. Run `./update-mobile-url.sh`
4. Distribute APK
5. Done! 🎉

---

**Full docs:** See `FIREBASE_EVERYTHING_READY.md`
