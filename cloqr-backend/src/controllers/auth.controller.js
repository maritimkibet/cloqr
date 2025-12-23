const { validationResult } = require('express-validator');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const pool = require('../config/database');
const redisClient = require('../config/redis');
const { sendEmail } = require('../services/email.service');

const hashEmail = (email) => {
  return crypto.createHash('sha256').update(email.toLowerCase()).digest('hex');
};

// Admin email - automatically gets admin privileges
const ADMIN_EMAIL = 'brianvocalto@gmail.com';

const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Validate student email domain
const isValidStudentEmail = (email) => {
  const allowedDomains = process.env.ALLOWED_EMAIL_DOMAINS?.split(',') || ['edu', 'ac.za'];
  const emailLower = email.toLowerCase();
  
  // Check if email ends with any allowed domain
  return allowedDomains.some(domain => emailLower.endsWith(`.${domain.trim()}`));
};

// Send OTP to student email
exports.sendOTP = async (req, res) => {
  try {
    const { email } = req.body;
    
    // Validate email format
    if (!email || !email.includes('@')) {
      return res.status(400).json({ error: 'Valid email required' });
    }

    // Check if it's admin email (bypass student email check)
    const isAdminEmail = email.toLowerCase() === ADMIN_EMAIL.toLowerCase();
    
    if (!isAdminEmail && !isValidStudentEmail(email)) {
      return res.status(400).json({ 
        error: 'Only student email addresses are allowed. Please use your university/college email.' 
      });
    }

    // Generate OTP
    const otp = generateOTP();
    const emailHash = hashEmail(email);

    // Store OTP in Redis with 10 minute expiration
    await redisClient.setEx(`otp:${emailHash}`, 600, otp);

    // Send OTP via email
    try {
      await sendEmail(
        email,
        'Cloqr - Email Verification Code',
        `Your verification code is: ${otp}\n\nThis code will expire in 10 minutes.`
      );
      
      console.log(`✅ OTP sent to ${email}`);
      res.json({ 
        message: 'Verification code sent to your email',
        emailHash
      });
    } catch (emailError) {
      console.error('Email sending failed:', emailError);
      res.status(500).json({ 
        error: 'Failed to send verification code. Please check your email configuration.' 
      });
    }
  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({ error: 'Failed to send verification code' });
  }
};

// Verify OTP
exports.verifyOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;
    const emailHash = hashEmail(email);

    if (!otp) {
      return res.status(400).json({ error: 'Verification code required' });
    }

    // Get stored OTP from Redis
    const storedOTP = await redisClient.get(`otp:${emailHash}`);

    if (!storedOTP) {
      return res.status(400).json({ error: 'Verification code expired or invalid' });
    }

    if (storedOTP !== otp.trim()) {
      return res.status(400).json({ error: 'Invalid verification code' });
    }

    // Delete OTP after successful verification
    await redisClient.del(`otp:${emailHash}`);

    res.json({ 
      message: 'Email verified successfully', 
      emailHash 
    });
  } catch (error) {
    console.error('Verify OTP error:', error);
    res.status(500).json({ error: 'Verification failed' });
  }
};

exports.register = async (req, res) => {
  try {
    let { email, username, campus, avatar = null, qrCode, password, emailVerified } = req.body;
    const emailHash = hashEmail(email);

    // Validate required fields
    if (!email || !username || !password) {
      return res.status(400).json({ error: 'Email, username, and password are required' });
    }

    if (password.length < 8) {
      return res.status(400).json({ error: 'Password must be at least 8 characters' });
    }

    // Check password strength
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumber = /[0-9]/.test(password);
    
    if (!hasUpperCase || !hasLowerCase || !hasNumber) {
      return res.status(400).json({ 
        error: 'Password must contain at least one uppercase letter, one lowercase letter, and one number' 
      });
    }

    // Check if user already exists
    const existing = await pool.query('SELECT * FROM users WHERE email_hash = $1', [emailHash]);
    if (existing.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists. Please login instead.' });
    }

    // Check if this is admin email - automatically grant admin privileges
    const isAdmin = email.toLowerCase() === ADMIN_EMAIL.toLowerCase();

    // Verify email was verified (unless admin)
    if (!isAdmin && !emailVerified) {
      return res.status(400).json({ error: 'Email must be verified before registration' });
    }

    // Validate student email domain (unless admin)
    if (!isAdmin && !isValidStudentEmail(email)) {
      return res.status(400).json({ 
        error: 'Only student email addresses are allowed' 
      });
    }

    let finalCampus = campus;
    let passwordHash;

    if (isAdmin) {
      // Admin registration - no QR code needed
      finalCampus = campus || 'System Admin';
      passwordHash = await bcrypt.hash(password, 10);
      
      console.log(`✅ Admin registration: ${email}`);

    } else {
      // Regular user registration - must have valid campus QR code
      if (!qrCode) {
        return res.status(400).json({ error: 'Campus QR code required for registration' });
      }

      const qrResult = await pool.query(
        'SELECT campus_name FROM campus_qr_codes WHERE qr_code = $1 AND is_active = true',
        [qrCode]
      );

      if (qrResult.rows.length === 0) {
        return res.status(400).json({ error: 'Invalid or inactive campus QR code' });
      }

      // Use campus from QR code
      finalCampus = qrResult.rows[0].campus_name;
      
      // Hash the password for regular users
      passwordHash = await bcrypt.hash(password, 10);
      
      console.log(`✅ User registration: ${email} at ${finalCampus}`);
    }

    // Insert user into database
    const result = await pool.query(
      'INSERT INTO users (email_hash, username, campus, avatar_url, is_verified, is_admin, pin_hash) VALUES ($1, $2, $3, $4, true, $5, $6) RETURNING user_id, username, campus, avatar_url, is_admin, trust_score, mode',
      [emailHash, username, finalCampus, avatar, isAdmin, passwordHash]
    );

    const user = result.rows[0];
    
    // Generate JWT token
    const token = jwt.sign(
      { userId: user.user_id, isAdmin: user.is_admin }, 
      process.env.JWT_SECRET, 
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.json({ 
      token, 
      user,
      message: isAdmin ? 'Admin registered successfully' : 'Registration successful'
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed. Please try again.' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const emailHash = hashEmail(email);

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user by email
    const result = await pool.query('SELECT * FROM users WHERE email_hash = $1', [emailHash]);
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = result.rows[0];

    // Check if user has a password hash
    if (!user.pin_hash) {
      return res.status(400).json({ 
        error: 'Account not set up properly. Please register again.' 
      });
    }

    // Verify password (works for both admin and regular users)
    const isPasswordValid = await bcrypt.compare(password, user.pin_hash);
    
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // Login successful - generate token
    const token = jwt.sign(
      { userId: user.user_id, isAdmin: user.is_admin || false }, 
      process.env.JWT_SECRET, 
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );
    
    return res.json({ 
      token, 
      user: {
        user_id: user.user_id,
        username: user.username,
        email: email,
        campus: user.campus,
        avatar_url: user.avatar_url,
        is_admin: user.is_admin,
        trust_score: user.trust_score,
        mode: user.mode
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed. Please try again.' });
  }
};

exports.setupPIN = async (req, res) => {
  try {
    const { pin } = req.body;
    const pinHash = await bcrypt.hash(pin, 10);

    await pool.query('UPDATE users SET pin_hash = $1 WHERE user_id = $2', [pinHash, req.userId]);

    res.json({ message: 'PIN set successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to set PIN' });
  }
};

exports.verifyPIN = async (req, res) => {
  try {
    const { pin } = req.body;

    const result = await pool.query('SELECT pin_hash FROM users WHERE user_id = $1', [req.userId]);
    const user = result.rows[0];

    if (!user.pin_hash) {
      return res.status(400).json({ error: 'PIN not set' });
    }

    const isValid = await bcrypt.compare(pin, user.pin_hash);
    if (!isValid) {
      return res.status(400).json({ error: 'Invalid PIN' });
    }

    res.json({ message: 'PIN verified' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Verification failed' });
  }
};
