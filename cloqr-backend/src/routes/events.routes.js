const express = require('express');
const router = express.Router();
const eventsController = require('../controllers/events.controller');
const { authenticate } = require('../middleware/auth');

router.get('/', authenticate, eventsController.getEvents);
router.post('/', authenticate, eventsController.createEvent);
router.post('/:eventId/rsvp', authenticate, eventsController.rsvpEvent);
router.get('/:eventId/attendees', authenticate, eventsController.getEventAttendees);
router.delete('/:eventId', authenticate, eventsController.deleteEvent);

module.exports = router;
