# 🔐 QR Room System - How It Works

## 📋 Overview

The QR Room system in Cloqr allows students to create temporary, anonymous chat rooms that others can join by scanning a QR code. It's perfect for:
- Hostel groups
- Class units
- Study sessions
- Campus events
- Quick meetups

## 🔄 Complete Flow

### 1. **Creating a Room**

**User Journey:**
```
User → Rooms Tab → Create Room → Fill Details → Generate QR
```

**What Happens:**
1. User fills in:
   - Room name (e.g., "CS101 Study Group")
   - Room type (Hostel, Class, Study, Event, Vibe)
   - Duration (1-48 hours)

2. Backend generates:
   - Unique `room_id` (UUID)
   - Unique `qr_code` (UUID string)
   - `expires_at` timestamp
   - Random "burner username" for creator

3. Database stores:
```sql
INSERT INTO qr_rooms (
  creator_id, 
  name, 
  qr_code, 
  room_type, 
  expires_at
)
```

4. Creator is added as first member:
```sql
INSERT INTO room_members (
  room_id, 
  user_id, 
  burner_username
)
```

**Burner Username Generation:**
```javascript
// Example: "BlueEagle#742", "GoldenWolf#123"
adjective + noun + "#" + random_number
```

### 2. **QR Code Generation**

**Current Implementation:**
- QR code is a UUID string (e.g., `"a1b2c3d4-e5f6-7890-abcd-ef1234567890"`)
- This string is encoded into a visual QR code using `qr_flutter` package

**How It Should Work:**
```dart
import 'package:qr_flutter/qr_flutter.dart';

// Display QR Code
QrImageView(
  data: room.qrCode,  // The UUID string
  version: QrVersions.auto,
  size: 200.0,
)
```

**What the QR Contains:**
```
Plain text: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
```

### 3. **Scanning QR Code**

**User Journey:**
```
User → Rooms Tab → Scan QR → Camera Opens → Scan → Join Room
```

**What Happens:**
1. Camera opens with QR scanner
2. User points camera at QR code
3. Scanner extracts the UUID string
4. App sends UUID to backend:
```javascript
POST /api/rooms/join
Body: { qrCode: "a1b2c3d4-e5f6-7890-abcd-ef1234567890" }
```

5. Backend validates:
   - Room exists
   - Room hasn't expired
   - User isn't already a member

6. Backend generates burner username for new member
7. User is added to room
8. User navigates to room chat

### 4. **Room Chat**

**Anonymous Identity:**
- Each user gets a random "burner username"
- Real identity is hidden
- Examples: "CrimsonDragon#456", "AzureFalcon#789"

**Chat Features:**
- Real-time messaging via Socket.IO
- Anonymous usernames displayed
- Messages auto-delete when room expires
- No message history saved

## 🗄️ Database Schema

```sql
-- Rooms Table
CREATE TABLE qr_rooms (
  room_id UUID PRIMARY KEY,
  creator_id UUID REFERENCES users(user_id),
  name VARCHAR(100),
  qr_code VARCHAR(255) UNIQUE,  -- The UUID for QR
  room_type VARCHAR(50),
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Members Table
CREATE TABLE room_members (
  room_id UUID REFERENCES qr_rooms(room_id),
  user_id UUID REFERENCES users(user_id),
  burner_username VARCHAR(50),
  joined_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (room_id, user_id)
);

-- Messages Table (temporary)
CREATE TABLE room_messages (
  message_id UUID PRIMARY KEY,
  room_id UUID REFERENCES qr_rooms(room_id),
  user_id UUID REFERENCES users(user_id),
  burner_username VARCHAR(50),
  content TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 🔧 Current Implementation Status

### ✅ What's Working:
- Room creation API
- Room listing API
- Join room API
- Burner username generation
- Socket.IO room chat
- Room expiration logic

### ⚠️ What's Missing:
- **QR Code Display** - Need to show actual QR image
- **QR Scanner** - Need to implement camera scanner
- **Room QR Screen** - Show QR after creation
- **Better UI** - Current screens are basic

## 🚀 What Needs to Be Implemented

### 1. **Show QR Code After Creation**

Create a new screen to display the QR code:

```dart
// room_qr_display_screen.dart
class RoomQRDisplayScreen extends StatelessWidget {
  final String qrCode;
  final String roomName;
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room QR Code')),
      body: Center(
        child: Column(
          children: [
            Text(roomName),
            QrImageView(
              data: qrCode,
              version: QrVersions.auto,
              size: 300.0,
              backgroundColor: Colors.white,
            ),
            Text('Scan this QR to join'),
          ],
        ),
      ),
    );
  }
}
```

### 2. **Implement QR Scanner**

Need to add QR scanning capability:

```dart
// Add to pubspec.yaml
dependencies:
  mobile_scanner: ^3.5.2  // Modern QR scanner

// In scan_qr_screen.dart
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null) {
              // Join room with this code
              _joinRoom(context, code);
            }
          }
        },
      ),
    );
  }
  
  Future<void> _joinRoom(BuildContext context, String qrCode) async {
    // Call API to join room
    // Navigate to room chat
  }
}
```

### 3. **Add Camera Permissions**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
```

## 🎯 Complete User Flow Example

### Scenario: Study Group

**Alice (Creator):**
1. Opens Cloqr app
2. Goes to Rooms tab
3. Taps "Create Room"
4. Fills in:
   - Name: "CS101 Final Exam Prep"
   - Type: Study Revision
   - Duration: 6 hours
5. Taps "Create Room"
6. **Sees QR code displayed**
7. Gets burner name: "BlueEagle#742"
8. Shows QR to friends

**Bob (Joiner):**
1. Opens Cloqr app
2. Goes to Rooms tab
3. Taps "Scan QR"
4. **Camera opens**
5. Points camera at Alice's QR
6. **Automatically joins room**
7. Gets burner name: "GoldenWolf#123"
8. Starts chatting anonymously

**In the Chat:**
```
BlueEagle#742: Hey everyone! Let's review chapter 5
GoldenWolf#123: Sounds good! I'm confused about recursion
CrimsonDragon#456: I can help with that!
```

**After 6 Hours:**
- Room expires automatically
- All messages deleted
- Members can't access anymore
- Privacy maintained ✅

## 🔐 Privacy Features

1. **Anonymous Usernames**
   - Random generated names
   - No real identity revealed
   - Changes per room

2. **Temporary Rooms**
   - Auto-expire after set duration
   - No permanent record
   - Messages auto-delete

3. **No History**
   - Messages not saved long-term
   - Can't view past rooms
   - Fresh start each time

4. **QR-Only Access**
   - Must physically scan QR
   - Can't join remotely
   - Ensures physical proximity

## 📱 Dependencies Needed

```yaml
# pubspec.yaml
dependencies:
  qr_flutter: ^4.1.0        # Generate QR codes
  mobile_scanner: ^3.5.2     # Scan QR codes
  permission_handler: ^11.0.1 # Camera permissions
```

## 🎨 UI Improvements Needed

Current screens are basic. Should add:
- Beautiful QR display with gradients
- Animated scanner overlay
- Room type icons and colors
- Member count badges
- Expiration countdown timer
- Share QR button (screenshot)

## 🔧 Next Steps

1. **Implement QR Display Screen**
2. **Add QR Scanner with mobile_scanner**
3. **Connect to backend APIs**
4. **Add camera permissions**
5. **Improve UI with animations**
6. **Add share functionality**
7. **Test end-to-end flow**

---

**The system is designed but needs the QR visual components implemented!**
