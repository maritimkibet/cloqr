const express = require('express');
const router = express.Router();
const studyGroupsController = require('../controllers/study-groups.controller');
const { authenticate } = require('../middleware/auth');

router.get('/', authenticate, studyGroupsController.getStudyGroups);
router.post('/', authenticate, studyGroupsController.createStudyGroup);
router.post('/:groupId/join', authenticate, studyGroupsController.joinStudyGroup);
router.get('/:groupId/members', authenticate, studyGroupsController.getStudyGroupMembers);
router.post('/:groupId/sessions', authenticate, studyGroupsController.createStudySession);
router.get('/:groupId/sessions', authenticate, studyGroupsController.getStudySessions);

module.exports = router;
