# CloQR Setup Guide

## Prerequisites
- Node.js 16+
- PostgreSQL
- Redis
- Flutter 3.0+

## Backend Setup

1. Install dependencies:
```bash
cd cloqr-backend
npm install
```

2. Configure environment:
```bash
cp .env.example .env
# Edit .env with your settings
```

3. Setup database:
```bash
psql -U postgres -f setup_database.sql
```

4. Start server:
```bash
./run.sh backend
```

## Mobile Setup

1. Install dependencies:
```bash
cd mobile
flutter pub get
```

2. Configure API endpoint in `mobile/lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

3. Run app:
```bash
./run.sh mobile
```

Or build APK:
```bash
./run.sh build
```

## Admin Access
- Email: `brianvocaldo@gmail.com`
- Password: `kiss2121`

## Features
- QR-based campus registration
- Swipe matching
- Real-time chat
- Study rooms
- Admin dashboard
