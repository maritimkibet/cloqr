const pool = require('../config/database');

// ============================================
// ICEBREAKER QUESTIONS
// ============================================

exports.getRandomIcebreaker = async (req, res) => {
  try {
    const { category } = req.query;
    
    let query = 'SELECT * FROM icebreaker_questions WHERE is_active = true';
    const params = [];
    
    if (category) {
      query += ' AND category = $1';
      params.push(category);
    }
    
    query += ' ORDER BY RANDOM() LIMIT 1';
    
    const result = await pool.query(query, params);
    res.json(result.rows[0] || null);
  } catch (error) {
    console.error('Get icebreaker error:', error);
    res.status(500).json({ error: 'Failed to fetch icebreaker' });
  }
};

// ============================================
// POLLS
// ============================================

exports.getPolls = async (req, res) => {
  try {
    const { campus } = req.query;
    
    let query = `
      SELECT p.*, 
             u.username as creator_name,
             (SELECT COUNT(*) FROM poll_votes WHERE poll_id = p.poll_id) as total_votes,
             (SELECT option_index FROM poll_votes WHERE poll_id = p.poll_id AND user_id = $1) as user_vote
      FROM polls p
      JOIN users u ON p.creator_id = u.user_id
      WHERE p.is_active = true AND (p.expires_at IS NULL OR p.expires_at > NOW())
    `;
    
    const params = [req.userId];
    
    if (campus) {
      query += ' AND (p.campus = $2 OR p.campus IS NULL)';
      params.push(campus);
    }
    
    query += ' ORDER BY p.created_at DESC';
    
    const result = await pool.query(query, params);
    
    // Get vote counts for each option
    for (let poll of result.rows) {
      const voteCounts = await pool.query(
        'SELECT option_index, COUNT(*) as count FROM poll_votes WHERE poll_id = $1 GROUP BY option_index',
        [poll.poll_id]
      );
      poll.vote_counts = voteCounts.rows;
    }
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get polls error:', error);
    res.status(500).json({ error: 'Failed to fetch polls' });
  }
};

exports.createPoll = async (req, res) => {
  try {
    const { question, options, campus, expires_at } = req.body;
    
    if (!question || !options || options.length < 2) {
      return res.status(400).json({ error: 'Question and at least 2 options required' });
    }
    
    const result = await pool.query(
      'INSERT INTO polls (creator_id, question, options, campus, expires_at) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [req.userId, question, JSON.stringify(options), campus, expires_at]
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Create poll error:', error);
    res.status(500).json({ error: 'Failed to create poll' });
  }
};

exports.votePoll = async (req, res) => {
  try {
    const { pollId } = req.params;
    const { option_index } = req.body;
    
    if (option_index === undefined) {
      return res.status(400).json({ error: 'Option index required' });
    }
    
    await pool.query(
      'INSERT INTO poll_votes (poll_id, user_id, option_index) VALUES ($1, $2, $3) ON CONFLICT (poll_id, user_id) DO UPDATE SET option_index = $3',
      [pollId, req.userId, option_index]
    );
    
    res.json({ message: 'Vote recorded' });
  } catch (error) {
    console.error('Vote poll error:', error);
    res.status(500).json({ error: 'Failed to vote' });
  }
};

// ============================================
// USER BADGES
// ============================================

exports.getUserBadges = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const result = await pool.query(
      'SELECT * FROM user_badges WHERE user_id = $1 ORDER BY earned_at DESC',
      [userId]
    );
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get badges error:', error);
    res.status(500).json({ error: 'Failed to fetch badges' });
  }
};

exports.awardBadge = async (req, res) => {
  try {
    const { userId, badge_type } = req.body;
    
    await pool.query(
      'INSERT INTO user_badges (user_id, badge_type) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [userId, badge_type]
    );
    
    res.json({ message: 'Badge awarded' });
  } catch (error) {
    console.error('Award badge error:', error);
    res.status(500).json({ error: 'Failed to award badge' });
  }
};

// ============================================
// USER STREAKS
// ============================================

exports.updateStreak = async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    
    const streak = await pool.query(
      'SELECT * FROM user_streaks WHERE user_id = $1',
      [req.userId]
    );
    
    if (streak.rows.length === 0) {
      // First login
      await pool.query(
        'INSERT INTO user_streaks (user_id, login_streak, last_login_date, longest_streak, total_logins) VALUES ($1, 1, $2, 1, 1)',
        [req.userId, today]
      );
      return res.json({ login_streak: 1, longest_streak: 1 });
    }
    
    const lastLogin = streak.rows[0].last_login_date;
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split('T')[0];
    
    let newStreak = streak.rows[0].login_streak;
    
    if (lastLogin === today) {
      // Already logged in today
      return res.json({ 
        login_streak: newStreak, 
        longest_streak: streak.rows[0].longest_streak 
      });
    } else if (lastLogin === yesterdayStr) {
      // Consecutive day
      newStreak++;
    } else {
      // Streak broken
      newStreak = 1;
    }
    
    const longestStreak = Math.max(newStreak, streak.rows[0].longest_streak);
    
    await pool.query(
      'UPDATE user_streaks SET login_streak = $1, last_login_date = $2, longest_streak = $3, total_logins = total_logins + 1 WHERE user_id = $4',
      [newStreak, today, longestStreak, req.userId]
    );
    
    // Award badge for 7-day streak
    if (newStreak === 7) {
      await pool.query(
        'INSERT INTO user_badges (user_id, badge_type) VALUES ($1, $2) ON CONFLICT DO NOTHING',
        [req.userId, 'active_user']
      );
    }
    
    res.json({ login_streak: newStreak, longest_streak: longestStreak });
  } catch (error) {
    console.error('Update streak error:', error);
    res.status(500).json({ error: 'Failed to update streak' });
  }
};

exports.getStreak = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM user_streaks WHERE user_id = $1',
      [req.userId]
    );
    
    res.json(result.rows[0] || { login_streak: 0, longest_streak: 0, total_logins: 0 });
  } catch (error) {
    console.error('Get streak error:', error);
    res.status(500).json({ error: 'Failed to fetch streak' });
  }
};

// ============================================
// MESSAGE REACTIONS
// ============================================

exports.addReaction = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { emoji } = req.body;
    
    if (!emoji) {
      return res.status(400).json({ error: 'Emoji required' });
    }
    
    await pool.query(
      'INSERT INTO message_reactions (message_id, user_id, emoji) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING',
      [messageId, req.userId, emoji]
    );
    
    res.json({ message: 'Reaction added' });
  } catch (error) {
    console.error('Add reaction error:', error);
    res.status(500).json({ error: 'Failed to add reaction' });
  }
};

exports.removeReaction = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { emoji } = req.body;
    
    await pool.query(
      'DELETE FROM message_reactions WHERE message_id = $1 AND user_id = $2 AND emoji = $3',
      [messageId, req.userId, emoji]
    );
    
    res.json({ message: 'Reaction removed' });
  } catch (error) {
    console.error('Remove reaction error:', error);
    res.status(500).json({ error: 'Failed to remove reaction' });
  }
};

exports.getReactions = async (req, res) => {
  try {
    const { messageId } = req.params;
    
    const result = await pool.query(
      `SELECT emoji, COUNT(*) as count, 
              json_agg(json_build_object('user_id', user_id, 'username', (SELECT username FROM users WHERE user_id = message_reactions.user_id))) as users
       FROM message_reactions
       WHERE message_id = $1
       GROUP BY emoji`,
      [messageId]
    );
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get reactions error:', error);
    res.status(500).json({ error: 'Failed to fetch reactions' });
  }
};

// ============================================
// PROFILE PROMPTS
// ============================================

exports.getProfilePrompts = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const result = await pool.query(
      'SELECT * FROM profile_prompts WHERE user_id = $1 ORDER BY display_order ASC',
      [userId]
    );
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get prompts error:', error);
    res.status(500).json({ error: 'Failed to fetch prompts' });
  }
};

exports.updateProfilePrompts = async (req, res) => {
  try {
    const { prompts } = req.body; // Array of {prompt_text, answer, display_order}
    
    // Delete existing prompts
    await pool.query('DELETE FROM profile_prompts WHERE user_id = $1', [req.userId]);
    
    // Insert new prompts
    for (let prompt of prompts) {
      await pool.query(
        'INSERT INTO profile_prompts (user_id, prompt_text, answer, display_order) VALUES ($1, $2, $3, $4)',
        [req.userId, prompt.prompt_text, prompt.answer, prompt.display_order || 0]
      );
    }
    
    res.json({ message: 'Prompts updated' });
  } catch (error) {
    console.error('Update prompts error:', error);
    res.status(500).json({ error: 'Failed to update prompts' });
  }
};

// ============================================
// MUTUAL CONNECTIONS
// ============================================

exports.getMutualConnections = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const result = await pool.query(
      `SELECT COUNT(*) as mutual_count
       FROM user_connections uc1
       JOIN user_connections uc2 ON (
         (uc1.user_b = uc2.user_a OR uc1.user_b = uc2.user_b) AND
         uc1.user_a = $1 AND uc2.user_a = $2
       )`,
      [req.userId, userId]
    );
    
    res.json({ mutual_count: parseInt(result.rows[0]?.mutual_count || 0) });
  } catch (error) {
    console.error('Get mutual connections error:', error);
    res.status(500).json({ error: 'Failed to fetch mutual connections' });
  }
};

// ============================================
// USER PREFERENCES
// ============================================

exports.getPreferences = async (req, res) => {
  try {
    let result = await pool.query(
      'SELECT * FROM user_preferences WHERE user_id = $1',
      [req.userId]
    );
    
    if (result.rows.length === 0) {
      // Create default preferences
      result = await pool.query(
        'INSERT INTO user_preferences (user_id) VALUES ($1) RETURNING *',
        [req.userId]
      );
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get preferences error:', error);
    res.status(500).json({ error: 'Failed to fetch preferences' });
  }
};

exports.updatePreferences = async (req, res) => {
  try {
    const updates = req.body;
    const allowedFields = ['dark_mode', 'notifications_enabled', 'email_notifications', 'show_trust_score', 'show_online_status', 'discovery_enabled'];
    
    const setClause = [];
    const values = [];
    let paramCount = 1;
    
    for (let field of allowedFields) {
      if (updates[field] !== undefined) {
        setClause.push(`${field} = $${paramCount}`);
        values.push(updates[field]);
        paramCount++;
      }
    }
    
    if (setClause.length === 0) {
      return res.status(400).json({ error: 'No valid fields to update' });
    }
    
    values.push(req.userId);
    
    const result = await pool.query(
      `INSERT INTO user_preferences (user_id) VALUES ($${paramCount}) 
       ON CONFLICT (user_id) DO UPDATE SET ${setClause.join(', ')}, updated_at = NOW()
       RETURNING *`,
      values
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Update preferences error:', error);
    res.status(500).json({ error: 'Failed to update preferences' });
  }
};
