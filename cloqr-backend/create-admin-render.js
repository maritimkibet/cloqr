#!/usr/bin/env node

/**
 * Create Admin User for Render Production
 * Run this via Render Shell or locally with DATABASE_URL set
 */

const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');

// Admin credentials
const ADMIN_EMAIL = 'brianvocalto@gmail.com';
const ADMIN_PASSWORD = 'admin123'; // Change this!
const ADMIN_USERNAME = 'Admin';
const ADMIN_CAMPUS = 'System';

async function createAdmin() {
  // Use DATABASE_URL from environment (Render sets this automatically)
  const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
  });

  try {
    console.log('🔌 Connecting to database...');
    await pool.query('SELECT NOW()');
    console.log('✅ Connected to database');

    // Hash email
    const emailHash = crypto.createHash('sha256').update(ADMIN_EMAIL.toLowerCase()).digest('hex');
    console.log(`📧 Email hash: ${emailHash}`);

    // Check if admin already exists
    const existingAdmin = await pool.query(
      'SELECT user_id, username, is_admin FROM users WHERE email_hash = $1',
      [emailHash]
    );

    if (existingAdmin.rows.length > 0) {
      const user = existingAdmin.rows[0];
      if (user.is_admin) {
        console.log(`✅ Admin user already exists: ${user.username} (ID: ${user.user_id})`);
        console.log('💡 To update password, delete the user first and run this script again');
        process.exit(0);
      } else {
        console.log(`⚠️  User exists but is not admin. Updating to admin...`);
        await pool.query(
          'UPDATE users SET is_admin = true WHERE user_id = $1',
          [user.user_id]
        );
        console.log(`✅ User ${user.username} is now an admin`);
        process.exit(0);
      }
    }

    // Hash password
    console.log('🔐 Hashing password...');
    const passwordHash = await bcrypt.hash(ADMIN_PASSWORD, 10);

    // Create admin user
    console.log('👤 Creating admin user...');
    const result = await pool.query(
      `INSERT INTO users (
        email_hash, 
        username, 
        campus, 
        avatar_url, 
        is_verified, 
        is_admin, 
        pin_hash,
        trust_score,
        mode
      ) VALUES ($1, $2, $3, $4, true, true, $5, 100, 'dating')
      RETURNING user_id, username, campus, is_admin`,
      [
        emailHash,
        ADMIN_USERNAME,
        ADMIN_CAMPUS,
        'https://ui-avatars.com/api/?name=Admin&background=6366f1&color=fff',
        passwordHash
      ]
    );

    const admin = result.rows[0];
    console.log('\n✅ Admin user created successfully!');
    console.log('═══════════════════════════════════════');
    console.log(`User ID: ${admin.user_id}`);
    console.log(`Username: ${admin.username}`);
    console.log(`Campus: ${admin.campus}`);
    console.log(`Is Admin: ${admin.is_admin}`);
    console.log('═══════════════════════════════════════');
    console.log('\n🔑 Login Credentials:');
    console.log(`Email: ${ADMIN_EMAIL}`);
    console.log(`Password: ${ADMIN_PASSWORD}`);
    console.log('\n⚠️  IMPORTANT: Change the password after first login!');

  } catch (error) {
    console.error('❌ Error creating admin:', error.message);
    console.error(error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the script
createAdmin();
