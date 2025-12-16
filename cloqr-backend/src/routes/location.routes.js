const express = require('express');
const router = express.Router();
const locationController = require('../controllers/location.controller');
const { authenticate } = require('../middleware/auth');

router.post('/checkin', authenticate, locationController.checkIn);
router.get('/checkins', authenticate, locationController.getNearbyCheckins);
router.get('/popular', authenticate, locationController.getPopularLocations);
router.delete('/checkout', authenticate, locationController.checkOut);
router.get('/current', authenticate, locationController.getCurrentCheckin);

module.exports = router;
