# QR Code Debug Guide

## Current Status

✅ Backend server is running with debug logging
✅ Frontend has debug logging added
✅ QR code display enhanced with white background and UUID shown

## How to Test & See Output

### 1. Watch Backend Terminal
The backend is running and will show:
```
📝 Creating room: { name, roomType, duration, userId }
✅ Room created: { roomId, qrCode, burnerUsername }
```

To see backend logs:
```bash
# The backend is already running in background
# Check the process output (I'll show you)
```

### 2. Watch Flutter Console
When you create a room, you'll see:
```
🚀 Creating room: [name], type: [type], duration: [hours]
🔵 RoomProvider: Creating room...
   URL: http://192.168.100.198:3000/api/rooms/create
   Data: name=..., roomType=..., duration=...
✅ RoomProvider: Room created successfully
   Response: {...}
🎯 Showing QR Code: [uuid]
👤 Burner Username: [name]
```

### 3. Test Room Creation

**Steps:**
1. Open the app
2. Make sure you're logged in
3. Go to **Rooms** tab
4. Tap **"Create Room"**
5. Fill in:
   - Room name: "Test Room"
   - Select any room type
   - Set duration (default 24 hours is fine)
6. Tap **"Create Room"** button

**What Should Happen:**
1. Loading spinner appears
2. Backend receives request (check backend logs)
3. Room is created in database
4. Dialog appears with:
   - QR code (black and white square)
   - UUID string below QR code
   - Your burner username
   - "Done" button

### 4. If QR Code Doesn't Show

**Check these:**

1. **Is the dialog appearing at all?**
   - If no dialog → Check Flutter console for errors
   - If dialog but no QR → QR widget issue

2. **Check Flutter console for:**
   ```
   🎯 Showing QR Code: [should see a UUID here]
   ```
   - If you see this, the data is there
   - QR widget should render

3. **Check backend logs for:**
   ```
   ✅ Room created: { roomId: ..., qrCode: ..., burnerUsername: ... }
   ```
   - If you see this, backend is working

4. **Common Issues:**
   - Not logged in → "Authentication required" error
   - No internet → "Cannot connect" error
   - QR package issue → Rebuild app

### 5. Verify QR Code Data

The QR code contains a UUID like:
```
a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

This UUID is:
- Stored in database as `qr_code`
- Used to join the room
- Displayed as text below the QR code
- Encoded in the QR image

### 6. Test QR Scanning

After creating a room:
1. Take screenshot of QR code OR
2. Open app on another device
3. Go to Rooms → **"Scan QR"**
4. Point camera at QR code
5. Should automatically join room

## Debug Commands

### Check Backend Logs
```bash
# I'll show you the process output
# Look for room creation logs
```

### Check Database
```bash
# See created rooms
psql -U brian -d cloqr -c "SELECT room_id, name, qr_code, room_type FROM qr_rooms ORDER BY created_at DESC LIMIT 5;"
```

### Test Backend Directly
```bash
# Get your JWT token from app storage, then:
curl -X POST http://192.168.100.198:3000/api/rooms/create \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Room","roomType":"study","duration":24}'
```

## What I Changed

### Backend (`room.controller.js`)
- Added console.log for room creation
- Shows: name, type, duration, userId
- Shows: roomId, qrCode, burnerUsername

### Frontend (`create_room_screen.dart`)
- Added loading spinner
- Added debug prints
- Enhanced QR dialog:
  - White background for QR code
  - Shows UUID as text
  - Better layout
  - Scrollable content

### Provider (`room_provider.dart`)
- Added debug logging
- Shows URL being called
- Shows request data
- Shows response or error

## Expected Flow

```
User taps "Create Room"
  ↓
🚀 Creating room: [logs in Flutter]
  ↓
🔵 RoomProvider: Creating room... [logs in Flutter]
  ↓
📝 Creating room: {...} [logs in Backend]
  ↓
✅ Room created: {...} [logs in Backend]
  ↓
✅ RoomProvider: Room created successfully [logs in Flutter]
  ↓
🎯 Showing QR Code: [uuid] [logs in Flutter]
  ↓
Dialog appears with QR code
```

## Troubleshooting

### "Authentication required"
- You're not logged in
- JWT token expired
- Solution: Login again

### "Cannot connect to server"
- Backend not running
- Wrong IP address
- Phone on different WiFi
- Solution: Check NETWORK_TROUBLESHOOTING.md

### QR code is blank/white
- Data is empty
- QR widget issue
- Solution: Check console for UUID

### Dialog doesn't appear
- Error in room creation
- Check Flutter console
- Check backend logs

### QR code shows but can't scan
- QR data might be too long
- Camera permissions
- Lighting issues
- Try manual entry of UUID

## Next Steps

1. **Run the app** with `flutter run`
2. **Watch the console** for debug logs
3. **Create a room** and observe the flow
4. **Check backend logs** (I'll show you)
5. **Report what you see** - I'll help debug further

---

**The QR code WILL show if:**
- ✅ You're logged in
- ✅ Backend is running (it is!)
- ✅ Room creation succeeds
- ✅ Response contains qr_code field

Let me know what you see in the console!
