# Quick Setup: Student Email Verification

## What Changed
✅ Student email verification with OTP codes is now active
✅ Only students with valid university/college emails can register
✅ Prevents non-students and older users from accessing the app

## Quick Start

### 1. Configure Email Service (Backend)
Edit `cloqr-backend/.env`:
```env
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_gmail_app_password
ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.university.edu
```

### 2. Get Gmail App Password
1. Go to https://myaccount.google.com/security
2. Enable 2-Step Verification
3. Search for "App passwords"
4. Generate password for "Mail"
5. Copy to `EMAIL_PASSWORD` in `.env`

### 3. Customize Allowed Domains
Add your institution's email domains to `ALLOWED_EMAIL_DOMAINS`:
```env
# Example for multiple universities
ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.mit.edu,alumni.stanford.edu
```

### 4. Restart Backend
```bash
cd cloqr-backend
npm start
```

## User Registration Flow

1. **Enter Email & Password**
   - User enters student email (e.g., john@university.edu)
   - Creates a password

2. **Receive Verification Code**
   - 6-digit code sent to email
   - Valid for 10 minutes

3. **Verify Email**
   - Enter code in app
   - Click "Verify & Continue"

4. **Complete Profile**
   - Setup username, campus, avatar
   - Start using the app

## Testing

Test with your own student email:
```bash
# 1. Make sure your domain is in ALLOWED_EMAIL_DOMAINS
# 2. Register in the app with your email
# 3. Check your inbox for the code
# 4. Enter code and complete registration
```

## Features

- ✅ Domain whitelist validation
- ✅ 6-digit OTP codes
- ✅ 10-minute expiration
- ✅ Resend with 60s cooldown
- ✅ Email hashing for privacy
- ✅ Admin bypass for admin accounts
- ✅ Clear error messages

## Files Modified

**Backend**:
- `cloqr-backend/src/controllers/auth.controller.js` - OTP logic
- `cloqr-backend/.env` - Email config

**Mobile**:
- `mobile/lib/screens/auth/email_verification_screen.dart` - OTP UI
- `mobile/lib/providers/auth_provider.dart` - OTP methods
- `mobile/lib/screens/auth/profile_setup_screen.dart` - Pass verification flag
- `mobile/lib/screens/auth/avatar_selection_screen.dart` - Pass verification flag

## Admin Login (Auto-Detected)

**Admin accounts automatically bypass OTP verification!**

Just use the regular login/registration with admin credentials:
- Email: `brianvocaldo@gmail.com`
- Password: `kiss2121`
- System auto-detects admin - no OTP required!

See [ADMIN_LOGIN_GUIDE.md](ADMIN_LOGIN_GUIDE.md) for details.

## Troubleshooting

**"Only student email addresses are allowed"**
→ Add your domain to `ALLOWED_EMAIL_DOMAINS`

**"Failed to send verification code"**
→ Check `EMAIL_USER` and `EMAIL_PASSWORD` in `.env`

**Code not received**
→ Check spam folder, verify Gmail app password

**"Verification code expired"**
→ Request new code (wait 60s between requests)

**Admin can't login**
→ See [ADMIN_LOGIN_GUIDE.md](ADMIN_LOGIN_GUIDE.md)
