# Create Admin User on Render

Your admin login is failing because the admin user doesn't exist in the production database yet. Here's how to create it:

## Method 1: Via Render Shell (Recommended)

1. **Go to Render Dashboard**
   - Visit https://dashboard.render.com
   - Select your `cloqr-backend` service

2. **Open Shell**
   - Click on "Shell" tab in the left sidebar
   - This opens a terminal connected to your production server

3. **Run the Admin Creation Script**
   ```bash
   node create-admin-render.js
   ```

4. **Note the Credentials**
   - The script will output:
     - Email: `brianvocalto@gmail.com`
     - Password: `admin123`
   - **IMPORTANT**: Change this password after first login!

## Method 2: Via Local Script with Render Database URL

1. **Get Database URL from Render**
   - Go to your Render dashboard
   - Click on your PostgreSQL database
   - Copy the "External Database URL"

2. **Run Locally**
   ```bash
   cd cloqr-backend
   DATABASE_URL="your-render-database-url" node create-admin-render.js
   ```

## Method 3: Add to Deployment (Automatic)

If you want the admin to be created automatically on deployment:

1. **Update render.yaml** to run the script after deployment
2. This will create the admin user every time you deploy (script checks if exists)

---

## After Creating Admin

### Test Admin Login

1. **Via API**:
   ```bash
   curl -X POST https://cloqr-backend.onrender.com/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"brianvocalto@gmail.com","password":"admin123"}'
   ```

2. **Via Mobile App**:
   - Open the app
   - Go to Admin Login
   - Enter:
     - Email: `brianvocalto@gmail.com`
     - Password: `admin123`
   - You should now be logged in as admin

### Change Password

After first login, you should change the password:

1. Go to Profile Settings
2. Change password to something secure
3. Or update directly in database:
   ```sql
   UPDATE users 
   SET pin_hash = '$2a$10$your-new-bcrypt-hash'
   WHERE email_hash = 'your-email-hash';
   ```

---

## Troubleshooting

### "Admin user already exists"
- The script detected an existing admin
- Use the existing credentials or delete the user first

### "Connection timeout"
- Your Render service might be spinning up (cold start)
- Wait 30-60 seconds and try again
- The mobile app now has 60-second timeout to handle this

### "Cannot connect to database"
- Check that DATABASE_URL is set correctly
- Verify your Render PostgreSQL service is running

### "Login failed" after creating admin
- Wait a few seconds for database to sync
- Try the curl command to test the API directly
- Check Render logs for any errors

---

## Security Notes

1. **Change Default Password**: The script uses `admin123` - change this immediately!
2. **Use Strong Password**: Use a password manager to generate a secure password
3. **Limit Admin Access**: Only create admin accounts for trusted users
4. **Monitor Admin Actions**: Check logs regularly for admin activity

---

## Current Status

✅ Mobile app timeout increased to 60 seconds (handles Render cold starts)
✅ Admin creation script ready
⏳ Need to run script on Render to create admin user
⏳ Need to test admin login after creation

---

## Quick Commands

**Create admin on Render:**
```bash
# In Render Shell
node create-admin-render.js
```

**Test login:**
```bash
curl -X POST https://cloqr-backend.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"brianvocalto@gmail.com","password":"admin123"}'
```

**Check if admin exists:**
```bash
# In Render Shell or psql
psql $DATABASE_URL -c "SELECT user_id, username, email_hash, is_admin FROM users WHERE is_admin = true;"
```
