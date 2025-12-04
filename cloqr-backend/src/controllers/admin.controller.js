const pool = require('../config/database');

exports.getStatistics = async (req, res) => {
  try {
    // Get total users
    const usersResult = await pool.query('SELECT COUNT(*) FROM users');
    const totalUsers = parseInt(usersResult.rows[0].count);

    // Get active chats
    const chatsResult = await pool.query(
      'SELECT COUNT(*) FROM chats WHERE expires_at > NOW()'
    );
    const activeChats = parseInt(chatsResult.rows[0].count);

    // Get active rooms
    const roomsResult = await pool.query(
      'SELECT COUNT(*) FROM qr_rooms WHERE expires_at > NOW()'
    );
    const activeRooms = parseInt(roomsResult.rows[0].count);

    // Get total matches
    const matchesResult = await pool.query(
      "SELECT COUNT(*) FROM matches WHERE status = 'matched'"
    );
    const totalMatches = parseInt(matchesResult.rows[0].count);

    // Get verified users
    const verifiedResult = await pool.query(
      'SELECT COUNT(*) FROM users WHERE is_verified = true'
    );
    const verifiedUsers = parseInt(verifiedResult.rows[0].count);

    // Get pending reports
    const reportsResult = await pool.query(
      "SELECT COUNT(*) FROM reports WHERE status = 'pending'"
    );
    const pendingReports = parseInt(reportsResult.rows[0].count);

    res.json({
      totalUsers,
      activeChats,
      activeRooms,
      totalMatches,
      verifiedUsers,
      pendingReports,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
};

exports.getUsers = async (req, res) => {
  try {
    const { page = 1, limit = 20, search = '' } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT user_id, username, email_hash, campus, is_verified, is_admin, 
             trust_score, created_at
      FROM users
    `;
    const params = [];

    if (search) {
      query += ` WHERE username ILIKE $1 OR campus ILIKE $1`;
      params.push(`%${search}%`);
    }

    query += ` ORDER BY created_at DESC LIMIT $${params.length + 1} OFFSET $${
      params.length + 2
    }`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const countQuery = search
      ? 'SELECT COUNT(*) FROM users WHERE username ILIKE $1 OR campus ILIKE $1'
      : 'SELECT COUNT(*) FROM users';
    const countParams = search ? [`%${search}%`] : [];
    const countResult = await pool.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    res.json({
      users: result.rows,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / limit),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
};

exports.banUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { reason } = req.body;

    await pool.query(
      'UPDATE users SET trust_score = 0, is_verified = false WHERE user_id = $1',
      [userId]
    );

    await pool.query(
      'INSERT INTO reports (reporter_id, reported_id, reason, status) VALUES ($1, $2, $3, $4)',
      [req.userId, userId, reason || 'Banned by admin', 'resolved']
    );

    res.json({ message: 'User banned successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to ban user' });
  }
};

exports.verifyUser = async (req, res) => {
  try {
    const { userId } = req.params;

    await pool.query('UPDATE users SET is_verified = true WHERE user_id = $1', [
      userId,
    ]);

    res.json({ message: 'User verified successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to verify user' });
  }
};

exports.getReports = async (req, res) => {
  try {
    const { status = 'pending' } = req.query;

    const result = await pool.query(
      `
      SELECT r.report_id, r.reason, r.status, r.created_at,
             u1.username as reporter_username,
             u2.username as reported_username
      FROM reports r
      JOIN users u1 ON r.reporter_id = u1.user_id
      JOIN users u2 ON r.reported_id = u2.user_id
      WHERE r.status = $1
      ORDER BY r.created_at DESC
    `,
      [status]
    );

    res.json({ reports: result.rows });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch reports' });
  }
};

exports.resolveReport = async (req, res) => {
  try {
    const { reportId } = req.params;
    const { action } = req.body;

    await pool.query("UPDATE reports SET status = 'resolved' WHERE report_id = $1", [
      reportId,
    ]);

    res.json({ message: 'Report resolved successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to resolve report' });
  }
};
