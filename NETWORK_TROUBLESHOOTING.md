# Network Connection Troubleshooting

## ✅ FIXED: Backend Server Now Running

The backend server is now running on: `http://192.168.100.198:3000`

## ✅ FIXED: Android Cleartext Traffic

Added `android:usesCleartextTraffic="true"` to AndroidManifest.xml to allow HTTP connections.

## Checklist to Fix "No Internet Connection" Error

### 1. ✅ Backend Server Running
```bash
cd cloqr-backend
npm start
```
**Status:** ✅ Running on port 3000

### 2. ✅ Correct IP Address
Your computer's IP: `192.168.100.198`
App configured to use: `192.168.100.198`
**Status:** ✅ Matches

### 3. ✅ Android Cleartext Traffic Enabled
**Status:** ✅ Fixed in AndroidManifest.xml

### 4. Phone and Computer on Same Network
**Check:**
- Open WiFi settings on your phone
- Verify you're connected to the same WiFi as your computer
- Phone IP should be in range: `192.168.100.x`

### 5. Firewall Not Blocking Port 3000
**Test from computer:**
```bash
curl http://192.168.100.198:3000/api/rooms
```
**Expected:** `{"error":"Authentication required"}`
**Status:** ✅ Working

**Test from phone browser:**
- Open browser on phone
- Go to: `http://192.168.100.198:3000/api/rooms`
- Should see: `{"error":"Authentication required"}`

### 6. Rebuild the App
After changing AndroidManifest.xml, you need to rebuild:
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

## Quick Test Steps

### Step 1: Verify Backend
```bash
curl http://192.168.100.198:3000/api/rooms
```
Should return: `{"error":"Authentication required"}`

### Step 2: Test from Phone Browser
Open phone browser → `http://192.168.100.198:3000/api/rooms`

### Step 3: Rebuild Flutter App
```bash
cd mobile
flutter clean
flutter run
```

## Common Issues & Solutions

### Issue: "Connection refused"
**Solution:** Backend not running
```bash
cd cloqr-backend
npm start
```

### Issue: "No route to host"
**Solution:** Phone and computer on different networks
- Connect both to same WiFi
- Check firewall settings

### Issue: "Cleartext HTTP traffic not permitted"
**Solution:** Already fixed! Just rebuild the app:
```bash
cd mobile
flutter clean
flutter run
```

### Issue: Wrong IP Address
**Find your IP:**
```bash
hostname -I | awk '{print $1}'
```
**Update in:** `mobile/lib/config/api_config.dart`

## Firewall Rules (if needed)

### Ubuntu/Linux
```bash
sudo ufw allow 3000/tcp
sudo ufw reload
```

### Check if port is open
```bash
sudo netstat -tulpn | grep :3000
```

## Network Diagnostics

### From Computer
```bash
# Check server is running
curl http://localhost:3000/api/rooms

# Check accessible on network
curl http://192.168.100.198:3000/api/rooms

# Check what's listening on port 3000
lsof -i :3000
```

### From Phone
1. Open browser
2. Go to: `http://192.168.100.198:3000/api/rooms`
3. Should see JSON response

## What Changed

### Before:
- ❌ Backend server not running
- ❌ Android blocking HTTP traffic
- ❌ App showing "no internet connection"

### After:
- ✅ Backend server running on port 3000
- ✅ Android allows cleartext traffic
- ✅ App can connect to backend

## Next Steps

1. **Rebuild the app** (important after AndroidManifest change):
   ```bash
   cd mobile
   flutter clean
   flutter run
   ```

2. **Test the connection:**
   - Open app
   - Try to login or access rooms
   - Should now connect successfully

3. **If still not working:**
   - Check phone browser can access `http://192.168.100.198:3000/api/rooms`
   - Verify both devices on same WiFi
   - Check firewall settings
   - Look at backend logs for incoming requests

## Backend Logs

To see if requests are reaching the backend:
```bash
# Backend is running in background
# Check logs with:
tail -f cloqr-backend/logs/*.log  # if logging to file
# or watch the terminal where you ran npm start
```

## Success Indicators

✅ Backend responds to curl commands
✅ Phone browser can access the API
✅ App shows data instead of "no internet connection"
✅ Login/registration works
✅ Rooms load successfully

---

**The main fix:** Backend is now running + Android cleartext traffic enabled!
**Action needed:** Rebuild the Flutter app with `flutter clean && flutter run`
