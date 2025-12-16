const pool = require('../config/database');

// Get all communities
exports.getCommunities = async (req, res) => {
  try {
    const { campus, category } = req.query;
    
    let query = `
      SELECT c.*, 
             (SELECT COUNT(*) FROM community_members WHERE community_id = c.community_id) as member_count,
             (SELECT role FROM community_members WHERE community_id = c.community_id AND user_id = $1) as user_role
      FROM communities c
      WHERE c.is_active = true
    `;
    
    const params = [req.userId];
    let paramCount = 1;
    
    if (campus) {
      paramCount++;
      query += ` AND (c.campus = $${paramCount} OR c.campus IS NULL)`;
      params.push(campus);
    }
    
    if (category) {
      paramCount++;
      query += ` AND c.category = $${paramCount}`;
      params.push(category);
    }
    
    query += ` ORDER BY member_count DESC`;
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Get communities error:', error);
    res.status(500).json({ error: 'Failed to fetch communities' });
  }
};

// Join community
exports.joinCommunity = async (req, res) => {
  try {
    const { communityId } = req.params;
    
    await pool.query(
      'INSERT INTO community_members (community_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [communityId, req.userId]
    );
    
    res.json({ message: 'Joined community' });
  } catch (error) {
    console.error('Join community error:', error);
    res.status(500).json({ error: 'Failed to join community' });
  }
};

// Leave community
exports.leaveCommunity = async (req, res) => {
  try {
    const { communityId } = req.params;
    
    await pool.query(
      'DELETE FROM community_members WHERE community_id = $1 AND user_id = $2',
      [communityId, req.userId]
    );
    
    res.json({ message: 'Left community' });
  } catch (error) {
    console.error('Leave community error:', error);
    res.status(500).json({ error: 'Failed to leave community' });
  }
};

// Get community posts
exports.getCommunityPosts = async (req, res) => {
  try {
    const { communityId } = req.params;
    const { limit = 20, offset = 0 } = req.query;
    
    const result = await pool.query(
      `SELECT cp.*, 
              u.username, u.avatar_url,
              (SELECT COUNT(*) FROM post_likes WHERE post_id = cp.post_id) as likes_count,
              EXISTS(SELECT 1 FROM post_likes WHERE post_id = cp.post_id AND user_id = $1) as user_liked
       FROM community_posts cp
       JOIN users u ON cp.user_id = u.user_id
       WHERE cp.community_id = $2
       ORDER BY cp.created_at DESC
       LIMIT $3 OFFSET $4`,
      [req.userId, communityId, limit, offset]
    );
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get posts error:', error);
    res.status(500).json({ error: 'Failed to fetch posts' });
  }
};

// Create post
exports.createPost = async (req, res) => {
  try {
    const { communityId } = req.params;
    const { content, media_url } = req.body;
    
    if (!content) {
      return res.status(400).json({ error: 'Content is required' });
    }
    
    // Check if user is member
    const member = await pool.query(
      'SELECT * FROM community_members WHERE community_id = $1 AND user_id = $2',
      [communityId, req.userId]
    );
    
    if (member.rows.length === 0) {
      return res.status(403).json({ error: 'Must be a member to post' });
    }
    
    const result = await pool.query(
      `INSERT INTO community_posts (community_id, user_id, content, media_url)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [communityId, req.userId, content, media_url]
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Create post error:', error);
    res.status(500).json({ error: 'Failed to create post' });
  }
};

// Like post
exports.likePost = async (req, res) => {
  try {
    const { postId } = req.params;
    
    await pool.query(
      'INSERT INTO post_likes (post_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [postId, req.userId]
    );
    
    // Update likes count
    await pool.query(
      'UPDATE community_posts SET likes_count = (SELECT COUNT(*) FROM post_likes WHERE post_id = $1) WHERE post_id = $1',
      [postId]
    );
    
    res.json({ message: 'Post liked' });
  } catch (error) {
    console.error('Like post error:', error);
    res.status(500).json({ error: 'Failed to like post' });
  }
};

// Unlike post
exports.unlikePost = async (req, res) => {
  try {
    const { postId } = req.params;
    
    await pool.query(
      'DELETE FROM post_likes WHERE post_id = $1 AND user_id = $2',
      [postId, req.userId]
    );
    
    // Update likes count
    await pool.query(
      'UPDATE community_posts SET likes_count = (SELECT COUNT(*) FROM post_likes WHERE post_id = $1) WHERE post_id = $1',
      [postId]
    );
    
    res.json({ message: 'Post unliked' });
  } catch (error) {
    console.error('Unlike post error:', error);
    res.status(500).json({ error: 'Failed to unlike post' });
  }
};
