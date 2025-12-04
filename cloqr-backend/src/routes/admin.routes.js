const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const { authenticate } = require('../middleware/auth');

// Middleware to check if user is admin
const isAdmin = async (req, res, next) => {
  const pool = require('../config/database');
  const result = await pool.query(
    'SELECT is_admin FROM users WHERE user_id = $1',
    [req.userId]
  );

  if (!result.rows[0] || !result.rows[0].is_admin) {
    return res.status(403).json({ error: 'Admin access required' });
  }

  next();
};

router.get('/statistics', authenticate, isAdmin, adminController.getStatistics);
router.get('/users', authenticate, isAdmin, adminController.getUsers);
router.post('/users/:userId/ban', authenticate, isAdmin, adminController.banUser);
router.post('/users/:userId/verify', authenticate, isAdmin, adminController.verifyUser);
router.get('/reports', authenticate, isAdmin, adminController.getReports);
router.post('/reports/:reportId/resolve', authenticate, isAdmin, adminController.resolveReport);

module.exports = router;
