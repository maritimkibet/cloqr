# 📱 How to Build APK for Sharing

## Quick Answer

To share your app with others, you need to **build an APK file**, not just run it.

---

## 🔄 The Difference

### `flutter run --release` ❌ (Not for sharing)
```bash
flutter run --release
```
- Runs app on connected device
- Optimized performance
- **No APK file created**
- **Can't share with others**
- App disappears when you disconnect

### `flutter build apk --release` ✅ (For sharing)
```bash
flutter build apk --release
```
- Creates installable APK file
- **Can share with anyone**
- Users install without USB
- App stays on device permanently
- **This is what you need!**

---

## 🚀 Easy Way: Use the Script

I've created a script that does everything for you:

```bash
./BUILD_AND_SHARE.sh
```

This will:
1. Clean previous builds
2. Get dependencies
3. Build release APK
4. Copy APK to easy location
5. Show sharing instructions

**Result:** `cloqr-app.apk` ready to share!

---

## 📝 Manual Way: Step by Step

If you prefer to do it manually:

### Step 1: Navigate to mobile folder
```bash
cd mobile
```

### Step 2: Clean previous builds (optional but recommended)
```bash
flutter clean
```

### Step 3: Get dependencies
```bash
flutter pub get
```

### Step 4: Build release APK
```bash
flutter build apk --release
```

**Wait 3-5 minutes** for the build to complete.

### Step 5: Find your APK
```bash
# APK location:
mobile/build/app/outputs/flutter-apk/app-release.apk

# Check size:
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

### Step 6: Copy to easy location (optional)
```bash
cp build/app/outputs/flutter-apk/app-release.apk ../cloqr-app.apk
cd ..
```

---

## 📤 How to Share the APK

### Option 1: Google Drive (Recommended)
1. Upload `cloqr-app.apk` to Google Drive
2. Right-click → Share → "Anyone with link"
3. Copy link and share with users

**Pros:** Easy, no file size limits, trackable downloads

### Option 2: WhatsApp/Telegram
1. Open WhatsApp/Telegram
2. Attach `cloqr-app.apk` as file
3. Send to users

**Pros:** Direct, fast, users already have the app  
**Cons:** File size limits (100MB WhatsApp, 2GB Telegram)

### Option 3: USB Transfer
1. Connect user's phone via USB
2. Copy `cloqr-app.apk` to phone
3. User opens file and installs

**Pros:** Works offline, no internet needed  
**Cons:** Requires physical access

### Option 4: Email
1. Attach `cloqr-app.apk` to email
2. Send to users

**Pros:** Professional, trackable  
**Cons:** File size limits (25MB Gmail)

---

## 📋 What to Share with Users

### 1. The APK File
- `cloqr-app.apk` (50-60 MB)

### 2. Installation Instructions
```
1. Download cloqr-app.apk
2. Open the file on your Android phone
3. If prompted, enable "Install from Unknown Sources"
4. Tap "Install"
5. Open Cloqr app
```

### 3. Campus QR Codes
```
University of Nairobi: sample_uon_qr_code_12345
Kenyatta University: sample_ku_qr_code_67890
Strathmore University: sample_su_qr_code_abcde
Masinde Muliro: de79e47648eea42488bab3dedea4bf6a
MMUST: 19fb6d582d42a474d9333581ca9b756f
```

### 4. Sign Up Instructions
```
1. Open Cloqr app
2. Tap "Get Started"
3. Select mode (Dating or Study)
4. Enter your student email
5. Check email for OTP code
6. Enter OTP
7. Scan or enter campus QR code
8. Complete profile
9. Start swiping!
```

---

## ⚠️ Important Notes

### Network Requirement
- Backend runs on: `http://10.10.8.33:3000`
- **Users MUST be on same WiFi network as you**
- This is perfect for testing with nearby friends
- For wider distribution, deploy backend to cloud

### Before Sharing
1. ✅ Make sure backend is running
   ```bash
   cd cloqr-backend && npm start
   ```

2. ✅ Test the APK yourself first
   - Install on your phone
   - Complete registration
   - Test all features

3. ✅ Prepare campus QR codes
   - Create QR code images online
   - Or share text codes

---

## 🧪 Testing the APK

### Before Sharing with Others

1. **Install on your phone:**
   ```bash
   # Connect phone via USB
   adb install cloqr-app.apk
   ```

2. **Test registration flow:**
   - Open app
   - Sign up with test email
   - Verify OTP works
   - Scan campus QR
   - Complete profile

3. **Test with a friend:**
   - Both install APK
   - Both register on same campus
   - Test matching
   - Test chat
   - Test QR rooms

---

## 📊 Build Information

### What Gets Built
- **File:** app-release.apk
- **Size:** ~50-60 MB
- **Type:** Android APK (Android 5.0+)
- **Optimized:** Yes (release mode)
- **Debug info:** Removed
- **Obfuscated:** No (add `--obfuscate` for production)

### Build Time
- **First build:** 5-10 minutes
- **Subsequent builds:** 2-5 minutes
- **With clean:** 5-10 minutes

### Build Output
```
✓ Built build/app/outputs/flutter-apk/app-release.apk (XX.XMB)
```

---

## 🔐 For Production (Later)

When you're ready for wider distribution:

### 1. Sign the APK
```bash
# Generate keystore
keytool -genkey -v -keystore cloqr-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cloqr

# Build signed APK
flutter build apk --release
```

### 2. Deploy Backend to Cloud
- Use Render.com or Heroku
- Update API URLs in app
- Rebuild APK

### 3. Publish to Play Store
- Create developer account ($25 one-time)
- Upload signed APK
- Fill in store listing
- Submit for review

---

## 🐛 Troubleshooting

### Build Fails
```bash
# Clean and retry
cd mobile
flutter clean
flutter pub get
flutter build apk --release
```

### APK Not Found
```bash
# Check if build completed
ls -la build/app/outputs/flutter-apk/

# If empty, check for errors in build output
```

### APK Won't Install
- Enable "Install from Unknown Sources"
- Check Android version (need 5.0+)
- Try uninstalling old version first

### App Crashes on Launch
- Check backend is running
- Check API URLs are correct
- Check logs: `adb logcat`

---

## ✅ Quick Checklist

Before sharing:
- [ ] Backend is running
- [ ] APK is built
- [ ] APK is tested on your phone
- [ ] Campus QR codes are ready
- [ ] Installation instructions prepared
- [ ] Users know about WiFi requirement

---

## 🎯 Summary

**To share your app:**

1. Run: `./BUILD_AND_SHARE.sh`
2. Get: `cloqr-app.apk`
3. Share via Google Drive/WhatsApp
4. Include campus QR codes
5. Make sure backend is running

**Don't use `flutter run --release`** - that's just for testing on your device!

---

**Need help? Check:**
- `READY_TO_SHARE.md` - Complete sharing guide
- `CAMPUS_INFO_FOR_USERS.md` - User instructions
- `QUICK_REFERENCE.md` - Quick commands
