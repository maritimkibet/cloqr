# Admin Login Guide

## Admin Access (No OTP Required)

Admin accounts bypass all student email verification requirements automatically.

## How to Login as Admin

### Existing Admin Account
1. Open the app
2. Tap **"Already have an account? Login"**
3. Enter admin credentials:
   - Email: `brianvocaldo@gmail.com`
   - Password: `kiss2121`
4. Tap **"Login"**
5. System automatically detects admin - you're in! No OTP needed.

### First Time Admin Registration
1. Open the app
2. Tap **"Get Started"** → Choose a mode
3. Enter admin credentials:
   - Email: `brianvocaldo@gmail.com`
   - Password: `kiss2121`
4. System detects admin email and skips OTP verification
5. Complete profile setup
6. Done!

### Backend Configuration

Admin credentials are set in `.env`:
```env
ADMIN_EMAIL=brianvocaldo@gmail.com
ADMIN_PASSWORD=kiss2121
```

## Admin Privileges

✅ **Bypasses Student Email Verification**
- No OTP codes required
- No domain validation
- Direct login access

✅ **Admin Dashboard Access**
- User management
- Campus QR code management
- User reports and moderation
- System statistics

✅ **Special Registration Flow**
- If admin account doesn't exist, can register without campus QR
- Uses admin password for authentication
- Automatically marked as admin in database

## Login Flow Comparison

### Regular Student Registration
1. Enter student email (must be .edu, .ac.za, etc.)
2. Enter password
3. Click "Send Verification Code"
4. Check email for 6-digit code
5. Enter code
6. Complete profile setup

### Regular Student Login
1. Enter email and password
2. Click "Login"
3. Done!

### Admin Registration/Login
1. Enter admin email: `brianvocaldo@gmail.com`
2. Enter admin password: `kiss2121`
3. System automatically detects admin
4. **No OTP verification required**
5. Done! ✅

## Security Notes

- Admin password is stored in environment variables
- Admin email is checked against `ADMIN_EMAIL` in `.env`
- Admin accounts are flagged with `is_admin: true` in database
- Only one admin account per system (defined by `ADMIN_EMAIL`)

## Changing Admin Credentials

Edit `cloqr-backend/.env`:
```env
ADMIN_EMAIL=your_admin@email.com
ADMIN_PASSWORD=your_secure_password
```

Then restart the backend:
```bash
cd cloqr-backend
npm start
```

## How It Works

The system automatically detects admin credentials:

**During Registration**:
- If email matches `ADMIN_EMAIL` from `.env`
- OTP verification is automatically skipped
- Shows message: "Admin detected - OTP verification skipped"
- Proceeds directly to profile setup
- No campus QR code required

**During Login**:
- If email matches `ADMIN_EMAIL` from `.env`
- Password is checked against `ADMIN_PASSWORD` from `.env`
- Direct login without any OTP
- Redirects to home screen with admin privileges

## Troubleshooting

**"Invalid email or password"**
→ Check `ADMIN_EMAIL` and `ADMIN_PASSWORD` in `.env` match what you're entering

**Admin login not working**
→ Verify backend is running and `.env` is configured correctly

**Want to change admin email**
→ Update `ADMIN_EMAIL` in `.env` and restart backend
