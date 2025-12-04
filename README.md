# CloQR - Campus Social Platform

Privacy-first social matching platform for campus communities with **fully functional QR rooms and real-time features**.

## ✨ Latest Updates

**🎉 ALL FEATURES NOW WORKING WITH REAL DATA!**
- ✅ QR Room creation and joining fully functional
- ✅ Real-time anonymous chat in rooms
- ✅ Admin dashboard with live statistics
- ✅ All "coming soon" placeholders removed
- ✅ Complete data collection and storage

See [ROOMS_AND_QR_FIXED.md](ROOMS_AND_QR_FIXED.md) for details.

## 🚀 Quick Start

### Backend
```bash
cd cloqr-backend
npm install
npm start
```
Server runs on: http://localhost:3000

### Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

## 👨‍💼 Admin Credentials
- Email: `brianvocaldo@gmail.com`
- Password: `kiss2121`

## 🎯 Features (All Working!)

### Core Features
- ✅ **QR-based Campus Registration** - Verify students with campus QR codes
- ✅ **Swipe Matching System** - Tinder-style matching with compatibility scores
- ✅ **Real-time Chat** - Instant messaging with Socket.IO
- ✅ **QR Study Rooms** - Create/join anonymous group chats via QR codes
- ✅ **Admin Dashboard** - User management, statistics, and moderation

### Room Features
- ✅ Create rooms with custom names and types (Hostel, Class, Study, Event, Vibe)
- ✅ Generate unique QR codes for each room
- ✅ Scan QR codes to join rooms instantly
- ✅ Anonymous chat with burner usernames
- ✅ Real-time messaging via Socket.IO
- ✅ Configurable room duration (1-48 hours)
- ✅ Member count tracking

### Admin Features
- ✅ Real-time statistics (users, chats, rooms, matches)
- ✅ User management (ban, verify, search)
- ✅ Reports management
- ✅ Campus QR code management

## 🛠 Tech Stack
- **Backend:** Node.js, Express, PostgreSQL, Socket.io
- **Mobile:** Flutter, Provider, QR Scanner
- **Auth:** JWT, bcrypt
- **Real-time:** Socket.IO
- **Database:** PostgreSQL with full schema

## 📱 Configuration

### Backend API URL
Edit `mobile/lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
static const String socketUrl = 'http://YOUR_IP:3000';
```

### Database Connection
Edit `cloqr-backend/.env`:
```
DATABASE_URL=postgresql://user:pass@host:5432/dbname
JWT_SECRET=your_secret_key
PORT=3000
```

## 📚 Documentation

- [QUICK_START.md](QUICK_START.md) - Get started in 5 minutes
- [ROOMS_AND_QR_FIXED.md](ROOMS_AND_QR_FIXED.md) - Room features documentation
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Production deployment guide
- [CHANGES_SUMMARY.md](CHANGES_SUMMARY.md) - Complete list of changes

## 🧪 Testing

### Test Room Creation
```bash
curl -X POST http://localhost:3000/api/rooms/create \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Room","roomType":"study","duration":24}'
```

### Test Admin Statistics
```bash
curl http://localhost:3000/api/admin/statistics \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

## 🎨 App Flow

1. **Registration** → Scan campus QR code → Verify email → Create profile
2. **Matching** → Swipe on profiles → Get matches → Start chatting
3. **Rooms** → Create/join QR rooms → Anonymous group chat
4. **Admin** → Monitor users → View statistics → Manage reports

## 🔒 Security Features

- JWT authentication on all endpoints
- Admin-only routes protected
- QR code validation and expiration
- Anonymous identity protection in rooms
- SQL injection prevention
- Password hashing with bcrypt

## 📊 Database Schema

Complete schema in `cloqr-backend/src/database/schema.sql`:
- Users & Profiles
- Matches & Swipes
- Chats & Messages
- QR Rooms & Members
- Reports & Blocks
- Campus QR Codes

## 🚀 Deployment

See [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) for complete deployment guide.

### Quick Deploy
1. Set up PostgreSQL database
2. Configure environment variables
3. Deploy backend to cloud service
4. Update API URLs in mobile app
5. Build and release mobile app

## 🐛 Troubleshooting

### Common Issues
- **Cannot connect**: Check backend is running and API URL is correct
- **Camera not working**: Grant camera permissions in Android settings
- **QR not scanning**: Ensure good lighting and steady camera
- **Not authorized**: Verify JWT token is valid

See [QUICK_START.md](QUICK_START.md) for more troubleshooting tips.

## 📈 Project Status

✅ **Production Ready**
- All core features implemented
- Real data collection active
- Admin tools functional
- Socket.IO real-time working
- No mock data or placeholders

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## 📄 License
MIT

---

**Built with ❤️ for campus communities**
