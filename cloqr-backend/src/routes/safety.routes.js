const express = require('express');
const router = express.Router();
const safetyController = require('../controllers/safety.controller');
const { authenticate, requireAdmin } = require('../middleware/auth');

router.post('/report', authenticate, safetyController.createReport);
router.get('/reports', authenticate, requireAdmin, safetyController.getAllReports);
router.put('/reports/:reportId', authenticate, requireAdmin, safetyController.updateReportStatus);
router.get('/tips', authenticate, safetyController.getSafetyTips);
router.post('/block', authenticate, safetyController.blockUserWithFeedback);

module.exports = router;
