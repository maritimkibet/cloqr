const pool = require('../config/database');

// Create safety report
exports.createReport = async (req, res) => {
  try {
    const { reported_id, report_type, description, evidence_url } = req.body;
    
    if (!reported_id || !report_type) {
      return res.status(400).json({ error: 'Reported user and report type are required' });
    }
    
    const validTypes = ['harassment', 'spam', 'fake_profile', 'inappropriate_content', 'other'];
    if (!validTypes.includes(report_type)) {
      return res.status(400).json({ error: 'Invalid report type' });
    }
    
    const result = await pool.query(
      `INSERT INTO safety_reports (reporter_id, reported_id, report_type, description, evidence_url)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [req.userId, reported_id, report_type, description, evidence_url]
    );
    
    // Decrease trust score of reported user
    await pool.query(
      'UPDATE users SET trust_score = GREATEST(trust_score - 5, 0) WHERE user_id = $1',
      [reported_id]
    );
    
    res.json({ message: 'Report submitted', report: result.rows[0] });
  } catch (error) {
    console.error('Create report error:', error);
    res.status(500).json({ error: 'Failed to submit report' });
  }
};

// Get all reports (admin only)
exports.getAllReports = async (req, res) => {
  try {
    const { status = 'pending' } = req.query;
    
    const result = await pool.query(
      `SELECT sr.*, 
              reporter.username as reporter_name,
              reported.username as reported_name,
              resolver.username as resolver_name
       FROM safety_reports sr
       LEFT JOIN users reporter ON sr.reporter_id = reporter.user_id
       LEFT JOIN users reported ON sr.reported_id = reported.user_id
       LEFT JOIN users resolver ON sr.resolved_by = resolver.user_id
       WHERE sr.status = $1
       ORDER BY sr.created_at DESC`,
      [status]
    );
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get reports error:', error);
    res.status(500).json({ error: 'Failed to fetch reports' });
  }
};

// Update report status (admin only)
exports.updateReportStatus = async (req, res) => {
  try {
    const { reportId } = req.params;
    const { status, admin_notes } = req.body;
    
    const validStatuses = ['pending', 'reviewing', 'resolved', 'dismissed'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }
    
    const result = await pool.query(
      `UPDATE safety_reports 
       SET status = $1, admin_notes = $2, resolved_by = $3, resolved_at = NOW()
       WHERE report_id = $4
       RETURNING *`,
      [status, admin_notes, req.userId, reportId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Report not found' });
    }
    
    // If resolved and confirmed, further decrease trust score
    if (status === 'resolved') {
      await pool.query(
        'UPDATE users SET trust_score = GREATEST(trust_score - 10, 0) WHERE user_id = (SELECT reported_id FROM safety_reports WHERE report_id = $1)',
        [reportId]
      );
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Update report error:', error);
    res.status(500).json({ error: 'Failed to update report' });
  }
};

// Get safety tips
exports.getSafetyTips = async (req, res) => {
  try {
    const tips = [
      {
        title: 'Meet in Public Places',
        description: 'Always meet new connections in public, well-lit areas on campus.',
        icon: '🏛️'
      },
      {
        title: 'Tell a Friend',
        description: 'Let someone know where you\'re going and who you\'re meeting.',
        icon: '👥'
      },
      {
        title: 'Trust Your Instincts',
        description: 'If something feels off, it probably is. Don\'t hesitate to leave.',
        icon: '🎯'
      },
      {
        title: 'Keep Personal Info Private',
        description: 'Don\'t share your address, financial info, or other sensitive details.',
        icon: '🔒'
      },
      {
        title: 'Report Suspicious Behavior',
        description: 'Help keep the community safe by reporting inappropriate conduct.',
        icon: '⚠️'
      },
      {
        title: 'Video Chat First',
        description: 'Consider a video call before meeting in person to verify identity.',
        icon: '📹'
      }
    ];
    
    res.json(tips);
  } catch (error) {
    console.error('Get safety tips error:', error);
    res.status(500).json({ error: 'Failed to fetch safety tips' });
  }
};

// Block user with feedback
exports.blockUserWithFeedback = async (req, res) => {
  try {
    const { blocked_id, reason } = req.body;
    
    if (!blocked_id) {
      return res.status(400).json({ error: 'User ID is required' });
    }
    
    // Insert block
    await pool.query(
      'INSERT INTO blocks (blocker_id, blocked_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [req.userId, blocked_id]
    );
    
    // If reason provided, create a report
    if (reason) {
      await pool.query(
        `INSERT INTO safety_reports (reporter_id, reported_id, report_type, description)
         VALUES ($1, $2, $3, $4)`,
        [req.userId, blocked_id, 'other', `Block reason: ${reason}`]
      );
    }
    
    res.json({ message: 'User blocked' });
  } catch (error) {
    console.error('Block user error:', error);
    res.status(500).json({ error: 'Failed to block user' });
  }
};
