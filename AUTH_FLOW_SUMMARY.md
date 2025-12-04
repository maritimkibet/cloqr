# Authentication Flow Summary

## Student Registration (OTP Required)

```
1. Enter student email (e.g., john@university.edu)
2. Enter password
3. Click "Send Verification Code"
   ↓
4. System validates email domain (.edu, .ac.za, etc.)
5. 6-digit OTP sent to email
   ↓
6. Enter OTP code
7. Click "Verify & Continue"
   ↓
8. Complete profile setup
9. ✅ Registered!
```

## Admin Registration (OTP Skipped)

```
1. Enter admin email (brianvocaldo@gmail.com)
2. Enter admin password (kiss2121)
3. Click "Send Verification Code"
   ↓
4. System detects admin email
5. Shows: "Admin detected - OTP verification skipped"
   ↓
6. Goes directly to profile setup
7. Complete profile
8. ✅ Registered as Admin!
```

## Student Login

```
1. Enter email
2. Enter password
3. Click "Login"
   ↓
4. System verifies credentials
5. ✅ Logged in!
```

## Admin Login

```
1. Enter admin email (brianvocaldo@gmail.com)
2. Enter admin password (kiss2121)
3. Click "Login"
   ↓
4. System detects admin credentials
5. ✅ Logged in as Admin!
```

## Key Differences

| Feature | Student | Admin |
|---------|---------|-------|
| Email Domain | Must be .edu, .ac.za, etc. | Any email (configured in .env) |
| OTP Verification | ✅ Required | ❌ Skipped |
| Campus QR Code | ✅ Required | ❌ Not needed |
| Login Screen | Regular login | Regular login (auto-detected) |
| Registration Flow | Full OTP flow | Simplified (no OTP) |

## Backend Detection Logic

The system automatically detects admin by:

1. **Email Check**: Compares entered email with `ADMIN_EMAIL` in `.env`
2. **Password Check**: For admin, validates against `ADMIN_PASSWORD` in `.env`
3. **Auto-Bypass**: If admin detected, skips all student-specific validations

## Configuration

Set in `cloqr-backend/.env`:

```env
# Admin credentials
ADMIN_EMAIL=brianvocaldo@gmail.com
ADMIN_PASSWORD=kiss2121

# Student email domains
ALLOWED_EMAIL_DOMAINS=edu,ac.za,student.edu,university.edu

# Email service for OTP
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_gmail_app_password
```

## Security Features

✅ **For Students**:
- Domain whitelist validation
- OTP expiration (10 minutes)
- Rate limiting (60s between resends)
- Email hashing for privacy
- Password hashing (bcrypt)

✅ **For Admin**:
- Environment variable credentials
- Direct password validation
- Admin flag in database
- Special privileges

## User Experience

**Students see**:
- "Enter your student email"
- "Verification code sent to your email"
- "Enter the 6-digit code"
- Resend countdown timer

**Admin sees**:
- "Admin detected - OTP verification skipped"
- Direct access to profile setup
- No OTP input required
- Faster registration/login

## No Separate Admin Screen

Unlike traditional systems, there's **no separate admin login screen**. The system intelligently detects admin credentials in the regular login/registration flow, making it seamless for both students and admins to use the same interface.
