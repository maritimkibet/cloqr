const express = require('express');
const router = express.Router();
const communityController = require('../controllers/community.controller');
const { authenticate } = require('../middleware/auth');

router.get('/', authenticate, communityController.getCommunities);
router.post('/:communityId/join', authenticate, communityController.joinCommunity);
router.post('/:communityId/leave', authenticate, communityController.leaveCommunity);
router.get('/:communityId/posts', authenticate, communityController.getCommunityPosts);
router.post('/:communityId/posts', authenticate, communityController.createPost);
router.post('/posts/:postId/like', authenticate, communityController.likePost);
router.delete('/posts/:postId/like', authenticate, communityController.unlikePost);

module.exports = router;
