# Deployment Checklist - Rooms & QR Features

## ✅ Backend Setup

### 1. Database Tables
- [x] `qr_rooms` table exists
- [x] `room_members` table exists
- [x] `reports` table exists
- [x] All indexes created

### 2. Backend Dependencies
```bash
cd cloqr-backend
npm install
```

Required packages (already in package.json):
- express
- socket.io
- uuid
- jsonwebtoken
- pg (PostgreSQL)

### 3. Environment Variables
Make sure `.env` has:
```
DATABASE_URL=your_postgres_url
JWT_SECRET=your_secret
PORT=3000
```

### 4. Start Backend
```bash
cd cloqr-backend
npm start
```

## ✅ Mobile App Setup

### 1. Flutter Dependencies
```bash
cd mobile
flutter pub get
```

Required packages (already in pubspec.yaml):
- provider
- qr_flutter
- mobile_scanner
- socket_io_client
- http

### 2. Android Permissions
Already configured in `AndroidManifest.xml`:
- CAMERA
- INTERNET
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE

### 3. Build & Run
```bash
cd mobile
flutter run
```

## 🧪 Testing Checklist

### Room Creation
- [ ] Open app and navigate to Rooms tab
- [ ] Click "Create Room"
- [ ] Fill in room name
- [ ] Select room type
- [ ] Set duration
- [ ] Click "Create Room"
- [ ] Verify QR code is displayed
- [ ] Verify burner username is shown
- [ ] Verify room appears in rooms list

### Room Joining
- [ ] Click "Scan QR" on Rooms screen
- [ ] Camera opens successfully
- [ ] Scan QR code from another device
- [ ] Verify successful join message
- [ ] Verify navigation to room chat
- [ ] Verify burner username is displayed

### Room Chat
- [ ] Send a message in room
- [ ] Verify message appears with burner username
- [ ] Open room on another device
- [ ] Verify messages sync in real-time
- [ ] Verify identity is anonymous

### Admin Features
- [ ] Login as admin user
- [ ] Navigate to Admin Dashboard
- [ ] Click "Statistics"
- [ ] Verify real numbers are displayed
- [ ] Check User Management screen
- [ ] Check User Reports screen
- [ ] Check Campus QR Management

## 🔍 Verification Commands

### Check Backend is Running
```bash
curl http://localhost:3000/api/rooms
```

### Check Database Connection
```bash
psql $DATABASE_URL -c "SELECT COUNT(*) FROM qr_rooms;"
```

### Check Socket.IO
Open browser console and test:
```javascript
const socket = io('http://localhost:3000', {
  auth: { token: 'YOUR_TOKEN' }
});
socket.on('connect', () => console.log('Connected!'));
```

## 🐛 Troubleshooting

### Room not appearing after creation
- Check backend logs for errors
- Verify database connection
- Check JWT token is valid

### QR Scanner not working
- Verify camera permissions granted
- Check Android version (requires API 21+)
- Try toggling camera/flash

### Messages not syncing
- Check Socket.IO connection
- Verify backend is running
- Check network connectivity

### Admin statistics not loading
- Verify user has `is_admin = true` in database
- Check backend admin routes are registered
- Verify JWT token includes admin flag

## 📱 Production Deployment

### Backend
1. Deploy to cloud service (Heroku, AWS, etc.)
2. Set up production PostgreSQL database
3. Configure environment variables
4. Enable HTTPS
5. Set up Redis for Socket.IO scaling (optional)

### Mobile App
1. Update API URLs in `mobile/lib/config/api_config.dart`
2. Build release APK: `flutter build apk --release`
3. Test on physical devices
4. Submit to Play Store

## 🎉 Success Criteria

✅ Users can create rooms with QR codes
✅ Users can join rooms by scanning QR codes
✅ Room chat works with real-time messaging
✅ Burner usernames protect identity
✅ Admin can view real statistics
✅ All "coming soon" messages removed
✅ No mock data - everything is real
✅ Database stores all room data
✅ Socket.IO handles real-time events
