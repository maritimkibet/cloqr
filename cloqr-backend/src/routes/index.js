const express = require('express');
const router = express.Router();

const authRoutes = require('./auth.routes');
const profileRoutes = require('./profile.routes');
const matchRoutes = require('./match.routes');
const chatRoutes = require('./chat.routes');
const roomRoutes = require('./room.routes');
const campusRoutes = require('./campus.routes');
const adminRoutes = require('./admin.routes');
const eventsRoutes = require('./events.routes');
const studyGroupsRoutes = require('./study-groups.routes');
const communityRoutes = require('./community.routes');
const featuresRoutes = require('./features.routes');
const safetyRoutes = require('./safety.routes');
const locationRoutes = require('./location.routes');

router.use('/auth', authRoutes);
router.use('/profile', profileRoutes);
router.use('/match', matchRoutes);
router.use('/chat', chatRoutes);
router.use('/rooms', roomRoutes);
router.use('/campus', campusRoutes);
router.use('/admin', adminRoutes);
router.use('/events', eventsRoutes);
router.use('/study-groups', studyGroupsRoutes);
router.use('/communities', communityRoutes);
router.use('/features', featuresRoutes);
router.use('/safety', safetyRoutes);
router.use('/location', locationRoutes);

module.exports = router;
