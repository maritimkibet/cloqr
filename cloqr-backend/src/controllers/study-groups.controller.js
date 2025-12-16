const pool = require('../config/database');

// Get all study groups
exports.getStudyGroups = async (req, res) => {
  try {
    const { campus, course, subject } = req.query;
    
    let query = `
      SELECT sg.*, 
             u.username as creator_name,
             (SELECT COUNT(*) FROM study_group_members WHERE group_id = sg.group_id) as member_count,
             (SELECT role FROM study_group_members WHERE group_id = sg.group_id AND user_id = $1) as user_role
      FROM study_groups sg
      JOIN users u ON sg.creator_id = u.user_id
      WHERE sg.is_active = true
    `;
    
    const params = [req.userId];
    let paramCount = 1;
    
    if (campus) {
      paramCount++;
      query += ` AND sg.campus = $${paramCount}`;
      params.push(campus);
    }
    
    if (course) {
      paramCount++;
      query += ` AND sg.course ILIKE $${paramCount}`;
      params.push(`%${course}%`);
    }
    
    if (subject) {
      paramCount++;
      query += ` AND sg.subject ILIKE $${paramCount}`;
      params.push(`%${subject}%`);
    }
    
    query += ` ORDER BY sg.created_at DESC`;
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Get study groups error:', error);
    res.status(500).json({ error: 'Failed to fetch study groups' });
  }
};

// Create study group
exports.createStudyGroup = async (req, res) => {
  try {
    const { name, description, course, subject, campus, max_members, tags } = req.body;
    
    if (!name || !course) {
      return res.status(400).json({ error: 'Name and course are required' });
    }
    
    const result = await pool.query(
      `INSERT INTO study_groups (creator_id, name, description, course, subject, campus, max_members, tags)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [req.userId, name, description, course, subject, campus, max_members || 10, JSON.stringify(tags || [])]
    );
    
    // Auto-join creator as admin
    await pool.query(
      'INSERT INTO study_group_members (group_id, user_id, role) VALUES ($1, $2, $3)',
      [result.rows[0].group_id, req.userId, 'admin']
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Create study group error:', error);
    res.status(500).json({ error: 'Failed to create study group' });
  }
};

// Join study group
exports.joinStudyGroup = async (req, res) => {
  try {
    const { groupId } = req.params;
    
    // Check if group exists and has space
    const group = await pool.query('SELECT * FROM study_groups WHERE group_id = $1 AND is_active = true', [groupId]);
    if (group.rows.length === 0) {
      return res.status(404).json({ error: 'Study group not found' });
    }
    
    const memberCount = await pool.query(
      'SELECT COUNT(*) FROM study_group_members WHERE group_id = $1',
      [groupId]
    );
    
    if (parseInt(memberCount.rows[0].count) >= group.rows[0].max_members) {
      return res.status(400).json({ error: 'Study group is full' });
    }
    
    await pool.query(
      'INSERT INTO study_group_members (group_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [groupId, req.userId]
    );
    
    res.json({ message: 'Joined study group' });
  } catch (error) {
    console.error('Join study group error:', error);
    res.status(500).json({ error: 'Failed to join study group' });
  }
};

// Get study group members
exports.getStudyGroupMembers = async (req, res) => {
  try {
    const { groupId } = req.params;
    
    const result = await pool.query(
      `SELECT u.user_id, u.username, u.avatar_url, sgm.role, sgm.joined_at
       FROM study_group_members sgm
       JOIN users u ON sgm.user_id = u.user_id
       WHERE sgm.group_id = $1
       ORDER BY sgm.role DESC, sgm.joined_at ASC`,
      [groupId]
    );
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get members error:', error);
    res.status(500).json({ error: 'Failed to fetch members' });
  }
};

// Create study session
exports.createStudySession = async (req, res) => {
  try {
    const { groupId } = req.params;
    const { title, location, start_time, end_time } = req.body;
    
    if (!title || !start_time) {
      return res.status(400).json({ error: 'Title and start time are required' });
    }
    
    // Check if user is member
    const member = await pool.query(
      'SELECT * FROM study_group_members WHERE group_id = $1 AND user_id = $2',
      [groupId, req.userId]
    );
    
    if (member.rows.length === 0) {
      return res.status(403).json({ error: 'Not a member of this group' });
    }
    
    const result = await pool.query(
      `INSERT INTO study_sessions (group_id, title, location, start_time, end_time, created_by)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [groupId, title, location, start_time, end_time, req.userId]
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Create session error:', error);
    res.status(500).json({ error: 'Failed to create session' });
  }
};

// Get study sessions
exports.getStudySessions = async (req, res) => {
  try {
    const { groupId } = req.params;
    
    const result = await pool.query(
      `SELECT ss.*, u.username as creator_name
       FROM study_sessions ss
       JOIN users u ON ss.created_by = u.user_id
       WHERE ss.group_id = $1 AND ss.start_time > NOW()
       ORDER BY ss.start_time ASC`,
      [groupId]
    );
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get sessions error:', error);
    res.status(500).json({ error: 'Failed to fetch sessions' });
  }
};
