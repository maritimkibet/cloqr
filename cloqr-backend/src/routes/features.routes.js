const express = require('express');
const router = express.Router();
const featuresController = require('../controllers/features.controller');
const { authenticate } = require('../middleware/auth');

// Icebreakers
router.get('/icebreaker', authenticate, featuresController.getRandomIcebreaker);

// Polls
router.get('/polls', authenticate, featuresController.getPolls);
router.post('/polls', authenticate, featuresController.createPoll);
router.post('/polls/:pollId/vote', authenticate, featuresController.votePoll);

// Badges
router.get('/badges/:userId', authenticate, featuresController.getUserBadges);
router.post('/badges/award', authenticate, featuresController.awardBadge);

// Streaks
router.get('/streak', authenticate, featuresController.getStreak);
router.post('/streak', authenticate, featuresController.updateStreak);

// Message Reactions
router.post('/messages/:messageId/reactions', authenticate, featuresController.addReaction);
router.delete('/messages/:messageId/reactions', authenticate, featuresController.removeReaction);
router.get('/messages/:messageId/reactions', authenticate, featuresController.getReactions);

// Profile Prompts
router.get('/prompts/:userId', authenticate, featuresController.getProfilePrompts);
router.put('/prompts', authenticate, featuresController.updateProfilePrompts);

// Mutual Connections
router.get('/mutual/:userId', authenticate, featuresController.getMutualConnections);

// Preferences
router.get('/preferences', authenticate, featuresController.getPreferences);
router.put('/preferences', authenticate, featuresController.updatePreferences);

module.exports = router;
