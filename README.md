# Campus Connect Mobile App (Flutter)

## Setup

1. Install Flutter SDK: https://flutter.dev/docs/get-started/install

2. Install dependencies:
```bash
cd mobile
flutter pub get
```

3. Configure API endpoint:
Edit `lib/config/api_config.dart` and update the `baseUrl` with your backend URL.

4. Run the app:
```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web (for testing)
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/
│   └── api_config.dart      # API endpoints
├── models/
│   ├── user_model.dart      # User & Profile models
│   └── message_model.dart   # Message & Chat models
├── providers/
│   ├── auth_provider.dart   # Authentication state
│   ├── chat_provider.dart   # Chat state
│   └── match_provider.dart  # Matching state
├── services/
│   ├── api_service.dart     # HTTP client
│   ├── socket_service.dart  # WebSocket client
│   └── storage_service.dart # Local storage
├── screens/
│   ├── auth/                # Authentication screens
│   ├── home/                # Home screen
│   ├── match/               # Matching screens
│   ├── chat/                # Chat screens
│   ├── rooms/               # QR rooms screens
│   └── profile/             # Profile screens
└── utils/
    └── theme.dart           # App theme
```

## Features Implemented

### Phase 1 & 2:
- ✅ Campus email verification (OTP)
- ✅ Preset avatar selection
- ✅ Profile setup (interests, study info, mode selection)
- ✅ Rule-based matching (filter by: campus, year, course, interests, mode)
- ✅ WhatsApp-style chat UI with auto-delete
- ✅ Screenshot detection + notification
- ✅ Basic trust/safety (report/block)
- ✅ Group chat for study groups
- ✅ Advanced study partner filters
- ✅ QR rooms (temporary chat spaces)

### To Be Implemented:
- Blurred photo upload with PIN unlock
- One-time-view photos
- Improved matching algorithm
- AI features (Phase 3)

## Running on Android

```bash
flutter run
```

## Running on iOS

```bash
flutter run -d ios
```

## Build APK

```bash
flutter build apk --release
```

## Build iOS

```bash
flutter build ios --release
```
# cloqr
