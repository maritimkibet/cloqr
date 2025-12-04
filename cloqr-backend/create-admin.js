require('dotenv').config();
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const pool = require('./src/config/database');

const hashEmail = (email) => {
  return crypto.createHash('sha256').update(email.toLowerCase()).digest('hex');
};

async function createAdmin() {
  try {
    const adminEmail = process.env.ADMIN_EMAIL;
    const adminPassword = process.env.ADMIN_PASSWORD;

    if (!adminEmail || !adminPassword) {
      console.error('❌ ADMIN_EMAIL and ADMIN_PASSWORD must be set in .env file');
      process.exit(1);
    }

    const emailHash = hashEmail(adminEmail);

    // Check if admin already exists
    const existing = await pool.query(
      'SELECT * FROM users WHERE email_hash = $1',
      [emailHash]
    );

    if (existing.rows.length > 0) {
      console.log('✅ Admin account already exists');
      console.log('Email:', adminEmail);
      console.log('You can login with your admin credentials');
      process.exit(0);
    }

    // Create admin account
    const passwordHash = await bcrypt.hash(adminPassword, 10);
    
    const result = await pool.query(
      `INSERT INTO users (
        email_hash, 
        username, 
        campus, 
        avatar_url, 
        is_verified, 
        is_admin, 
        pin_hash,
        mode
      ) VALUES ($1, $2, $3, $4, true, true, $5, $6) 
      RETURNING user_id, username, campus, is_admin`,
      [
        emailHash,
        'Admin',
        'Admin',
        'https://api.dicebear.com/7.x/avataaars/svg?seed=admin',
        passwordHash,
        'dating'
      ]
    );

    console.log('✅ Admin account created successfully!');
    console.log('');
    console.log('Admin Details:');
    console.log('Email:', adminEmail);
    console.log('Password:', adminPassword);
    console.log('User ID:', result.rows[0].user_id);
    console.log('');
    console.log('You can now login using the Admin Access button in the app');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin account:', error.message);
    process.exit(1);
  }
}

createAdmin();
