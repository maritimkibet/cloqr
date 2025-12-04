# Student Email Verification

## Overview
The app now requires student email verification to ensure only current students can register and use the platform.

## How It Works

### 1. Email Domain Validation
- Only emails from approved student domains are accepted
- Default allowed domains: `.edu`, `.ac.za`, `.student.edu`, `.university.edu`
- Admin email bypasses this check

### 2. OTP Verification Flow
1. User enters their student email and password
2. System validates the email domain
3. A 6-digit verification code is sent to the email
4. User enters the code within 10 minutes
5. After verification, user can complete profile setup

### 3. Backend Configuration

**Environment Variables** (`.env`):
```env
# Email service for sending OTP
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password

# Allowed student email domains (comma-separated)
ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.edu,university.edu
```

**Customize Allowed Domains**:
Edit the `ALLOWED_EMAIL_DOMAINS` in your `.env` file to match your institution's email domains.

Example for specific universities:
```env
ALLOWED_EMAIL_DOMAINS=student.university.edu,alumni.university.edu,ac.za
```

### 4. API Endpoints

**Send OTP**:
```
POST /api/auth/send-otp
Body: { "email": "student@university.edu" }
Response: { "message": "Verification code sent", "emailHash": "..." }
```

**Verify OTP**:
```
POST /api/auth/verify-otp
Body: { "email": "student@university.edu", "otp": "123456" }
Response: { "message": "Email verified successfully", "emailHash": "..." }
```

**Register** (requires verified email):
```
POST /api/auth/register
Body: {
  "email": "student@university.edu",
  "username": "johndoe",
  "password": "password123",
  "campus": "Main Campus",
  "avatar": "avatar1.png",
  "emailVerified": true
}
```

### 5. Security Features

- **OTP Expiration**: Codes expire after 10 minutes
- **Rate Limiting**: 60-second cooldown between resend requests
- **Domain Whitelist**: Only approved student email domains accepted
- **Redis Storage**: OTPs stored securely in Redis with automatic expiration
- **Email Hashing**: Emails are hashed before storage for privacy

### 6. Admin Bypass

Admin accounts bypass student email verification:
- Admin email is defined in `ADMIN_EMAIL` environment variable
- Admin can register/login without OTP verification
- Admin uses special admin password from `ADMIN_PASSWORD`
- Admin login uses the dedicated Admin Login screen (no OTP required)
- Admin registration bypasses domain validation and email verification

### 7. Mobile App Flow

**Email Verification Screen**:
1. Enter student email and password
2. Click "Send Verification Code"
3. Check email for 6-digit code
4. Enter code in the app
5. Click "Verify & Continue"
6. Proceed to profile setup

**UI Features**:
- Real-time email domain validation
- Resend code button with countdown timer
- Clear error messages for invalid codes
- Visual confirmation when verified

### 8. Testing

**Test with your own email**:
1. Make sure your email domain is in `ALLOWED_EMAIL_DOMAINS`
2. Configure Gmail app password in `EMAIL_PASSWORD`
3. Register with your student email
4. Check your inbox for the verification code

**Gmail App Password Setup**:
1. Go to Google Account settings
2. Enable 2-factor authentication
3. Generate an app password for "Mail"
4. Use that password in `EMAIL_PASSWORD`

### 9. Error Messages

- "Only student email addresses are allowed" - Email domain not in whitelist
- "Verification code expired or invalid" - OTP expired or wrong code
- "Invalid verification code" - Wrong code entered
- "Failed to send verification code" - Email service configuration issue

### 10. Troubleshooting

**OTP not received**:
- Check spam/junk folder
- Verify `EMAIL_USER` and `EMAIL_PASSWORD` are correct
- Check backend logs for email sending errors
- Ensure Gmail "Less secure app access" or app password is configured

**Domain not accepted**:
- Add your institution's domain to `ALLOWED_EMAIL_DOMAINS`
- Restart the backend server after changing `.env`

**Code expired**:
- Request a new code (60-second cooldown applies)
- Codes are valid for 10 minutes only
