const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const rateLimit = require('express-rate-limit');
const authController = require('../controllers/auth.controller');
const { authenticate } = require('../middleware/auth');

// Rate limiter for OTP requests (max 3 per 15 minutes per IP)
const otpLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 3,
  message: { error: 'Too many OTP requests. Please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Rate limiter for login attempts (max 5 per 15 minutes per IP)
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: { error: 'Too many login attempts. Please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

router.post('/send-otp',
  otpLimiter,
  body('email').isEmail().withMessage('Valid email required'),
  authController.sendOTP
);

router.post('/verify-otp',
  body('email').isEmail(),
  body('otp').isLength({ min: 6, max: 6 }),
  authController.verifyOTP
);

router.post('/register',
  body('email').isEmail(),
  body('username').isLength({ min: 3, max: 50 }),
  body('campus').notEmpty(),
  authController.register
);

router.post('/login',
  loginLimiter,
  body('email').isEmail(),
  authController.login
);

router.post('/setup-pin',
  authenticate,
  body('pin').isLength({ min: 4, max: 6 }),
  authController.setupPIN
);

router.post('/verify-pin',
  authenticate,
  body('pin').isLength({ min: 4, max: 6 }),
  authController.verifyPIN
);

module.exports = router;
