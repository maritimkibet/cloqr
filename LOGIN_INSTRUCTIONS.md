# Admin Login Instructions

## Fixed Issues

1. ✅ **Admin email typo fixed** - Changed from `brianvocalto@gmail.com` to `brianvocaldo@gmail.com`
2. ✅ **Password requirements reduced** - Now only requires 6 characters minimum (was 8 with complexity rules)
3. ✅ **Admin password updated** - Password hash in database updated to match "kiss2121"
4. ✅ **Admin flag ensured** - `is_admin` flag set to `true` in database
5. ✅ **Email whitelist updated** - `brianvocaldo@gmail.com` whitelisted in validators

## Your Admin Credentials

**Email:** brianvocaldo@gmail.com  
**Password:** kiss2121

## How to Login

### Option 1: Direct Login (If you already have an account)
1. Open the app
2. Go to login screen
3. Enter email: `brianvocaldo@gmail.com`
4. Enter password: `kiss2121`
5. You should see the Admin Dashboard instead of Match screen

### Option 2: Register (If account doesn't exist or having issues)
1. Open the app
2. Go to registration
3. Enter email: `brianvocaldo@gmail.com`
4. The app will recognize this as an admin email
5. Complete registration with password: `kiss2121`
6. You'll automatically get admin privileges

## What to Expect

When logged in as admin, you'll see:
- **Admin Dashboard** (instead of Match screen) as the first tab
- Access to:
  - User Management
  - User Reports
  - Campus QR Code Management
  - System Statistics

## Troubleshooting

If you still see the regular user interface:
1. Make sure Render has finished redeploying (check https://dashboard.render.com)
2. Clear app data and login again
3. Check that the backend URL is: `https://cloqr-backend.onrender.com/api`

## Backend Deployment

The backend will automatically redeploy on Render when you push to GitHub.
Wait 2-3 minutes for the deployment to complete before testing.

Check deployment status at: https://dashboard.render.com
