const pool = require('../config/database');

// Get all events
exports.getEvents = async (req, res) => {
  try {
    const { campus, type, upcoming } = req.query;
    
    let query = `
      SELECT e.*, 
             u.username as creator_name,
             (SELECT COUNT(*) FROM event_attendees WHERE event_id = e.event_id) as attendee_count,
             (SELECT status FROM event_attendees WHERE event_id = e.event_id AND user_id = $1) as user_status
      FROM events e
      JOIN users u ON e.creator_id = u.user_id
      WHERE 1=1
    `;
    
    const params = [req.userId];
    let paramCount = 1;
    
    if (campus) {
      paramCount++;
      query += ` AND e.campus = $${paramCount}`;
      params.push(campus);
    }
    
    if (type) {
      paramCount++;
      query += ` AND e.event_type = $${paramCount}`;
      params.push(type);
    }
    
    if (upcoming === 'true') {
      query += ` AND e.start_time > NOW()`;
    }
    
    query += ` ORDER BY e.start_time ASC`;
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Get events error:', error);
    res.status(500).json({ error: 'Failed to fetch events' });
  }
};

// Create event
exports.createEvent = async (req, res) => {
  try {
    const { title, description, event_type, location, campus, start_time, end_time, max_attendees, is_public, tags } = req.body;
    
    if (!title || !start_time) {
      return res.status(400).json({ error: 'Title and start time are required' });
    }
    
    const result = await pool.query(
      `INSERT INTO events (creator_id, title, description, event_type, location, campus, start_time, end_time, max_attendees, is_public, tags)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING *`,
      [req.userId, title, description, event_type, location, campus, start_time, end_time, max_attendees, is_public, JSON.stringify(tags || [])]
    );
    
    // Auto-join creator
    await pool.query(
      'INSERT INTO event_attendees (event_id, user_id, status) VALUES ($1, $2, $3)',
      [result.rows[0].event_id, req.userId, 'going']
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Create event error:', error);
    res.status(500).json({ error: 'Failed to create event' });
  }
};

// RSVP to event
exports.rsvpEvent = async (req, res) => {
  try {
    const { eventId } = req.params;
    const { status } = req.body; // going, interested, maybe
    
    if (!['going', 'interested', 'maybe'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }
    
    // Check if event exists and has space
    const event = await pool.query('SELECT * FROM events WHERE event_id = $1', [eventId]);
    if (event.rows.length === 0) {
      return res.status(404).json({ error: 'Event not found' });
    }
    
    if (event.rows[0].max_attendees) {
      const attendeeCount = await pool.query(
        'SELECT COUNT(*) FROM event_attendees WHERE event_id = $1 AND status = $2',
        [eventId, 'going']
      );
      if (parseInt(attendeeCount.rows[0].count) >= event.rows[0].max_attendees && status === 'going') {
        return res.status(400).json({ error: 'Event is full' });
      }
    }
    
    await pool.query(
      `INSERT INTO event_attendees (event_id, user_id, status)
       VALUES ($1, $2, $3)
       ON CONFLICT (event_id, user_id) DO UPDATE SET status = $3`,
      [eventId, req.userId, status]
    );
    
    res.json({ message: 'RSVP updated', status });
  } catch (error) {
    console.error('RSVP event error:', error);
    res.status(500).json({ error: 'Failed to RSVP' });
  }
};

// Get event attendees
exports.getEventAttendees = async (req, res) => {
  try {
    const { eventId } = req.params;
    
    const result = await pool.query(
      `SELECT u.user_id, u.username, u.avatar_url, ea.status, ea.joined_at
       FROM event_attendees ea
       JOIN users u ON ea.user_id = u.user_id
       WHERE ea.event_id = $1
       ORDER BY ea.joined_at ASC`,
      [eventId]
    );
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get attendees error:', error);
    res.status(500).json({ error: 'Failed to fetch attendees' });
  }
};

// Delete event
exports.deleteEvent = async (req, res) => {
  try {
    const { eventId } = req.params;
    
    const result = await pool.query(
      'DELETE FROM events WHERE event_id = $1 AND creator_id = $2 RETURNING *',
      [eventId, req.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Event not found or unauthorized' });
    }
    
    res.json({ message: 'Event deleted' });
  } catch (error) {
    console.error('Delete event error:', error);
    res.status(500).json({ error: 'Failed to delete event' });
  }
};
