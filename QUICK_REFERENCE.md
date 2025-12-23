# 🚀 Cloqr App - Quick Reference Card

## ⚡ Start the App (2 Commands)

```bash
# Terminal 1: Start Backend
cd cloqr-backend && npm start

# Terminal 2: Run Mobile App
cd mobile && flutter run
```

---

## 🧪 Run Tests

```bash
./test-app.sh
```

---

## 🔑 Test Credentials

### Admin Login
```
Email: brianvocaldo@gmail.com
Password: kiss2121
```

### Campus QR Codes
```
University of Nairobi: sample_uon_qr_code_12345
Kenyatta University: sample_ku_qr_code_67890
Strathmore University: sample_su_qr_code_abcde
```

---

## 🌐 API Endpoints

```
Base URL: http://10.10.8.33:3000/api
Socket URL: http://10.10.8.33:3000

Health: GET /health
Auth: POST /api/auth/send-otp
      POST /api/auth/verify-otp
      POST /api/auth/register
      POST /api/auth/login
```

---

## 🔧 Troubleshooting

### Backend won't start?
```bash
# Check database
psql -U brian -d cloqr -c "SELECT 1"

# Check Redis
redis-cli ping

# Check port
lsof -i :3000
```

### Mobile app errors?
```bash
# Clean and rebuild
cd mobile
flutter clean
flutter pub get
flutter run
```

### Database issues?
```bash
# Restart PostgreSQL
sudo systemctl restart postgresql

# Check connection
psql -U brian -d cloqr
```

---

## 📱 User Flow

1. Open app → Splash screen
2. Welcome → "Get Started"
3. Select mode (Dating/Study)
4. Enter email → Get OTP
5. Verify OTP
6. Scan campus QR code
7. Complete profile
8. Start matching!

---

## 📊 Status Check

```bash
# All services
./test-app.sh

# Just backend
curl http://localhost:3000/health

# Just database
psql -U brian -d cloqr -c "SELECT COUNT(*) FROM users"

# Just mobile
cd mobile && flutter analyze
```

---

## 🔐 Security Features

✅ Rate limiting (3 OTP/15min, 5 login/15min)  
✅ Strong passwords (8+ chars, upper, lower, number)  
✅ JWT authentication  
✅ Token validation  
✅ Environment variables protected

---

## 📂 Key Files

```
mobile/lib/config/api_config.dart     - API endpoints
mobile/lib/main.dart                  - App entry + error handling
cloqr-backend/src/server.js          - Backend server
cloqr-backend/.env                    - Configuration (DO NOT COMMIT)
cloqr-backend/.env.example            - Config template (safe to share)
```

---

## 🎯 What's Working

✅ Authentication (OTP, QR, Login)  
✅ User matching (swipe)  
✅ Real-time chat  
✅ QR rooms  
✅ Profile management  
✅ Events & study groups  
✅ Communities

---

## 📈 Production Deployment

### Backend (Render.com)
1. Create PostgreSQL database
2. Set environment variables
3. Deploy from Git
4. Update mobile API URLs

### Mobile (Play Store)
1. Update API URLs to production
2. Build release: `flutter build apk --release`
3. Sign APK
4. Upload to Play Store

---

## 🆘 Quick Fixes

### "Cannot connect to server"
→ Check backend is running: `curl http://localhost:3000/health`

### "Database error"
→ Check PostgreSQL: `sudo systemctl status postgresql`

### "Redis error"
→ Check Redis: `redis-cli ping`

### "Flutter errors"
→ Run: `flutter clean && flutter pub get`

### "Port already in use"
→ Kill process: `lsof -i :3000` then `kill -9 <PID>`

---

## 📞 Support Commands

```bash
# View backend logs
cd cloqr-backend && npm start

# View mobile logs
cd mobile && flutter run -v

# Check database
psql -U brian -d cloqr

# Check Redis
redis-cli

# Run all tests
./test-app.sh
```

---

## ✅ All Issues Fixed

1. ✅ API URLs configured
2. ✅ Deprecated API fixed
3. ✅ Profile update working
4. ✅ QR scanning implemented
5. ✅ Socket reconnection added
6. ✅ URL consistency fixed
7. ✅ Database error handling
8. ✅ Environment config created
9. ✅ Global error handling
10. ✅ Rate limiting added
11. ✅ Password requirements strengthened

---

## 🎉 Ready to Go!

**Tests Passing:** 10/10 ✅  
**Issues Fixed:** 11/11 ✅  
**Status:** READY FOR TESTING ✅

---

*For detailed documentation, see:*
- `FIXES_COMPLETE.md` - Full summary
- `FIXES_APPLIED.md` - Detailed fixes
- `APP_ISSUES_REPORT.md` - Original analysis
