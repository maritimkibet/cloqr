require('dotenv').config();
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const pool = require('./src/config/database');

const hashEmail = (email) => {
  return crypto.createHash('sha256').update(email.toLowerCase()).digest('hex');
};

async function updateBrianPassword() {
  try {
    const adminEmail = 'brianvocaldo@gmail.com';
    const adminPassword = 'kiss2121';

    const emailHash = hashEmail(adminEmail);

    // Check if admin exists
    const existing = await pool.query(
      'SELECT * FROM users WHERE email_hash = $1',
      [emailHash]
    );

    if (existing.rows.length === 0) {
      console.log('❌ Admin account does not exist');
      process.exit(1);
    }

    // Update password
    const passwordHash = await bcrypt.hash(adminPassword, 10);
    
    await pool.query(
      'UPDATE users SET pin_hash = $1, is_admin = true WHERE email_hash = $2',
      [passwordHash, emailHash]
    );

    console.log('✅ Admin password updated successfully!');
    console.log('');
    console.log('Admin Details:');
    console.log('Email:', adminEmail);
    console.log('Password:', adminPassword);
    console.log('');
    console.log('You can now login with these credentials');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error updating password:', error.message);
    process.exit(1);
  }
}

updateBrianPassword();
