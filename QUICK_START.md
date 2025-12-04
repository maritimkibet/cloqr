# Quick Start Guide - Rooms & QR Features

## 🚀 Start the App

### 1. Start Backend
```bash
cd cloqr-backend
npm install
npm start
```
Backend runs on: http://localhost:3000

### 2. Start Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

## 📱 Using Room Features

### Create a Room
1. Open app → Navigate to **Rooms** tab
2. Tap **"Create Room"**
3. Enter room name (e.g., "Study Group")
4. Select room type (Hostel, Class, Study, Event, Vibe)
5. Set duration (1-48 hours)
6. Tap **"Create Room"**
7. QR code appears → Share with others
8. Your burner username is displayed

### Join a Room
1. Open app → Navigate to **Rooms** tab
2. Tap **"Scan QR"**
3. Point camera at QR code
4. Automatically joins and opens room chat
5. Your burner username is assigned

### Chat in Room
1. Type message in text field
2. Tap send button
3. Message appears with your burner username
4. All room members see it in real-time
5. Identity remains anonymous

## 👨‍💼 Admin Features

### View Statistics
1. Login as admin
2. Go to Admin Dashboard
3. Tap **"Statistics"**
4. See real-time data:
   - Total users
   - Active chats
   - Active rooms
   - Total matches
   - Verified users
   - Pending reports

### Manage Users
1. Admin Dashboard → **"User Management"**
2. View all registered users
3. Ban/verify users
4. Search by username or campus

### Handle Reports
1. Admin Dashboard → **"User Reports"**
2. View pending reports
3. Review and resolve
4. Take action on reported users

## 🔧 Configuration

### Backend API URL
Edit: `mobile/lib/config/api_config.dart`
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
static const String socketUrl = 'http://YOUR_IP:3000';
```

### Database Connection
Edit: `cloqr-backend/.env`
```
DATABASE_URL=postgresql://user:pass@host:5432/dbname
JWT_SECRET=your_secret_key
PORT=3000
```

## ✅ Verify Everything Works

### Test Room Creation
```bash
curl -X POST http://localhost:3000/api/rooms/create \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Room","roomType":"study","duration":24}'
```

### Test Get Rooms
```bash
curl http://localhost:3000/api/rooms \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test Admin Statistics
```bash
curl http://localhost:3000/api/admin/statistics \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

## 🐛 Common Issues

### "Cannot connect to server"
- Check backend is running
- Verify API URL in api_config.dart
- Check firewall settings

### "Camera not working"
- Grant camera permissions in Android settings
- Check AndroidManifest.xml has CAMERA permission

### "QR code not scanning"
- Ensure good lighting
- Hold camera steady
- Try toggling flash

### "Not authorized"
- Check JWT token is valid
- Verify user is logged in
- For admin features, check is_admin flag

## 📊 Database Queries

### Check rooms
```sql
SELECT * FROM qr_rooms WHERE expires_at > NOW();
```

### Check room members
```sql
SELECT * FROM room_members WHERE room_id = 'ROOM_ID';
```

### Make user admin
```sql
UPDATE users SET is_admin = true WHERE email_hash = 'USER_EMAIL_HASH';
```

## 🎉 Success Indicators

✅ Rooms appear in list after creation
✅ QR codes scan successfully
✅ Messages appear in real-time
✅ Burner usernames are displayed
✅ Admin statistics show real numbers
✅ No "coming soon" messages anywhere

## 📞 Support

If issues persist:
1. Check backend logs
2. Check mobile app logs
3. Verify database connection
4. Review DEPLOYMENT_CHECKLIST.md
5. Check CHANGES_SUMMARY.md for details

---

**Everything is now working with real data collection!** 🎊
