const express = require('express');
const router = express.Router();
const roomController = require('../controllers/room.controller');
const { authenticate } = require('../middleware/auth');

router.post('/create', authenticate, roomController.createRoom);
router.get('/', authenticate, roomController.getRooms);
router.post('/join', authenticate, roomController.joinRoom);
router.post('/leave', authenticate, roomController.leaveRoom);
router.get('/:roomId/members', authenticate, roomController.getRoomMembers);

module.exports = router;
