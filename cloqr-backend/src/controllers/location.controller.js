const pool = require('../config/database');

// Check in to location
exports.checkIn = async (req, res) => {
  try {
    const { location_name, location_type, campus, latitude, longitude, duration_minutes = 120 } = req.body;
    
    if (!location_name) {
      return res.status(400).json({ error: 'Location name is required' });
    }
    
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + duration_minutes);
    
    // Delete any existing active check-ins for this user
    await pool.query(
      'DELETE FROM location_checkins WHERE user_id = $1',
      [req.userId]
    );
    
    const result = await pool.query(
      `INSERT INTO location_checkins (user_id, location_name, location_type, campus, latitude, longitude, expires_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [req.userId, location_name, location_type, campus, latitude, longitude, expiresAt]
    );
    
    // Update popular location stats
    await pool.query(
      `INSERT INTO popular_locations (name, location_type, campus, latitude, longitude, checkin_count)
       VALUES ($1, $2, $3, $4, $5, 1)
       ON CONFLICT (name, campus) DO UPDATE SET checkin_count = popular_locations.checkin_count + 1`,
      [location_name, location_type, campus, latitude, longitude]
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Check-in error:', error);
    res.status(500).json({ error: 'Failed to check in' });
  }
};

// Get nearby check-ins
exports.getNearbyCheckins = async (req, res) => {
  try {
    const { campus, location_type } = req.query;
    
    let query = `
      SELECT lc.*, u.username, u.avatar_url
      FROM location_checkins lc
      JOIN users u ON lc.user_id = u.user_id
      WHERE lc.expires_at > NOW() AND lc.is_visible = true
    `;
    
    const params = [];
    let paramCount = 0;
    
    if (campus) {
      paramCount++;
      query += ` AND lc.campus = $${paramCount}`;
      params.push(campus);
    }
    
    if (location_type) {
      paramCount++;
      query += ` AND lc.location_type = $${paramCount}`;
      params.push(location_type);
    }
    
    query += ` ORDER BY lc.created_at DESC`;
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Get check-ins error:', error);
    res.status(500).json({ error: 'Failed to fetch check-ins' });
  }
};

// Get popular locations
exports.getPopularLocations = async (req, res) => {
  try {
    const { campus, location_type, limit = 10 } = req.query;
    
    let query = `
      SELECT pl.*, 
             (SELECT COUNT(*) FROM location_checkins WHERE location_name = pl.name AND expires_at > NOW()) as current_checkins
      FROM popular_locations pl
      WHERE 1=1
    `;
    
    const params = [];
    let paramCount = 0;
    
    if (campus) {
      paramCount++;
      query += ` AND pl.campus = $${paramCount}`;
      params.push(campus);
    }
    
    if (location_type) {
      paramCount++;
      query += ` AND pl.location_type = $${paramCount}`;
      params.push(location_type);
    }
    
    paramCount++;
    query += ` ORDER BY pl.checkin_count DESC LIMIT $${paramCount}`;
    params.push(limit);
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Get popular locations error:', error);
    res.status(500).json({ error: 'Failed to fetch popular locations' });
  }
};

// Check out (delete check-in)
exports.checkOut = async (req, res) => {
  try {
    await pool.query(
      'DELETE FROM location_checkins WHERE user_id = $1',
      [req.userId]
    );
    
    res.json({ message: 'Checked out' });
  } catch (error) {
    console.error('Check-out error:', error);
    res.status(500).json({ error: 'Failed to check out' });
  }
};

// Get user's current check-in
exports.getCurrentCheckin = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM location_checkins WHERE user_id = $1 AND expires_at > NOW()',
      [req.userId]
    );
    
    res.json(result.rows[0] || null);
  } catch (error) {
    console.error('Get current check-in error:', error);
    res.status(500).json({ error: 'Failed to fetch check-in' });
  }
};
