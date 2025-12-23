const { Pool } = require('pg');
require('dotenv').config();

// Use DATABASE_URL if available (Render), otherwise use individual fields (local)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_URL ? { rejectUnauthorized: false } : false,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

async function migrate() {
  const client = await pool.connect();
  
  try {
    console.log('🚀 Starting migration for new features...');
    
    await client.query('BEGIN');
    
    // Check if tables already exist
    const checkTable = async (tableName) => {
      const result = await client.query(
        `SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = $1)`,
        [tableName]
      );
      return result.rows[0].exists;
    };
    
    // Events & Meetups
    if (!(await checkTable('events'))) {
      console.log('Creating events tables...');
      await client.query(`
        CREATE TABLE events (
          event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          creator_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          title VARCHAR(200) NOT NULL,
          description TEXT,
          event_type VARCHAR(50),
          location VARCHAR(200),
          campus VARCHAR(100),
          start_time TIMESTAMP NOT NULL,
          end_time TIMESTAMP,
          max_attendees INTEGER,
          is_public BOOLEAN DEFAULT true,
          tags JSONB DEFAULT '[]',
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE TABLE event_attendees (
          event_id UUID REFERENCES events(event_id) ON DELETE CASCADE,
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          status VARCHAR(20) DEFAULT 'going',
          joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (event_id, user_id)
        );
        
        CREATE INDEX idx_events_campus ON events(campus);
        CREATE INDEX idx_events_start_time ON events(start_time);
        CREATE INDEX idx_events_type ON events(event_type);
      `);
    }
    
    // Study Groups
    if (!(await checkTable('study_groups'))) {
      console.log('Creating study groups tables...');
      await client.query(`
        CREATE TABLE study_groups (
          group_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          creator_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          name VARCHAR(200) NOT NULL,
          description TEXT,
          course VARCHAR(100),
          subject VARCHAR(100),
          campus VARCHAR(100),
          max_members INTEGER DEFAULT 10,
          is_active BOOLEAN DEFAULT true,
          tags JSONB DEFAULT '[]',
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE TABLE study_group_members (
          group_id UUID REFERENCES study_groups(group_id) ON DELETE CASCADE,
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          role VARCHAR(20) DEFAULT 'member',
          joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (group_id, user_id)
        );
        
        CREATE TABLE study_sessions (
          session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          group_id UUID REFERENCES study_groups(group_id) ON DELETE CASCADE,
          title VARCHAR(200) NOT NULL,
          location VARCHAR(200),
          start_time TIMESTAMP NOT NULL,
          end_time TIMESTAMP,
          created_by UUID REFERENCES users(user_id),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE INDEX idx_study_groups_campus ON study_groups(campus);
        CREATE INDEX idx_study_groups_course ON study_groups(course);
      `);
    }
    
    // Other features
    if (!(await checkTable('icebreaker_questions'))) {
      console.log('Creating icebreaker questions table...');
      await client.query(`
        CREATE TABLE icebreaker_questions (
          question_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          question_text TEXT NOT NULL,
          category VARCHAR(50),
          is_active BOOLEAN DEFAULT true,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        INSERT INTO icebreaker_questions (question_text, category) VALUES
        ('What''s your go-to study snack?', 'fun'),
        ('If you could have dinner with any historical figure, who would it be?', 'deep'),
        ('What''s the most interesting class you''ve taken?', 'study'),
        ('Coffee or tea?', 'random'),
        ('What''s your favorite spot on campus?', 'fun'),
        ('What are you most passionate about?', 'deep'),
        ('Early bird or night owl?', 'random'),
        ('What''s your dream job?', 'deep'),
        ('Favorite way to de-stress during exams?', 'study'),
        ('What''s something you''re learning outside of class?', 'fun');
      `);
    }
    
    // User features
    if (!(await checkTable('user_badges'))) {
      console.log('Creating user features tables...');
      await client.query(`
        CREATE TABLE user_badges (
          badge_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          badge_type VARCHAR(50) NOT NULL,
          earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(user_id, badge_type)
        );
        
        CREATE TABLE user_streaks (
          user_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
          login_streak INTEGER DEFAULT 0,
          last_login_date DATE,
          longest_streak INTEGER DEFAULT 0,
          total_logins INTEGER DEFAULT 0,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE TABLE user_preferences (
          user_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
          dark_mode BOOLEAN DEFAULT false,
          notifications_enabled BOOLEAN DEFAULT true,
          email_notifications BOOLEAN DEFAULT true,
          show_trust_score BOOLEAN DEFAULT true,
          show_online_status BOOLEAN DEFAULT true,
          discovery_enabled BOOLEAN DEFAULT true,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `);
    }
    
    // Polls
    if (!(await checkTable('polls'))) {
      console.log('Creating polls tables...');
      await client.query(`
        CREATE TABLE polls (
          poll_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          creator_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          question TEXT NOT NULL,
          options JSONB NOT NULL,
          campus VARCHAR(100),
          expires_at TIMESTAMP,
          is_active BOOLEAN DEFAULT true,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE TABLE poll_votes (
          vote_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          poll_id UUID REFERENCES polls(poll_id) ON DELETE CASCADE,
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          option_index INTEGER NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(poll_id, user_id)
        );
        
        CREATE INDEX idx_polls_campus ON polls(campus);
        CREATE INDEX idx_polls_expires ON polls(expires_at);
      `);
    }
    
    // Communities
    if (!(await checkTable('communities'))) {
      console.log('Creating communities tables...');
      await client.query(`
        CREATE TABLE communities (
          community_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          name VARCHAR(100) NOT NULL,
          description TEXT,
          category VARCHAR(50),
          campus VARCHAR(100),
          icon VARCHAR(50),
          is_active BOOLEAN DEFAULT true,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE TABLE community_members (
          community_id UUID REFERENCES communities(community_id) ON DELETE CASCADE,
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          role VARCHAR(20) DEFAULT 'member',
          joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (community_id, user_id)
        );
        
        CREATE TABLE community_posts (
          post_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          community_id UUID REFERENCES communities(community_id) ON DELETE CASCADE,
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          content TEXT NOT NULL,
          media_url VARCHAR(255),
          likes_count INTEGER DEFAULT 0,
          comments_count INTEGER DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE TABLE post_likes (
          post_id UUID REFERENCES community_posts(post_id) ON DELETE CASCADE,
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (post_id, user_id)
        );
        
        CREATE INDEX idx_communities_campus ON communities(campus);
        CREATE INDEX idx_community_posts_community ON community_posts(community_id);
        
        INSERT INTO communities (name, description, category, icon) VALUES
        ('Gaming Hub', 'Connect with fellow gamers', 'gaming', '🎮'),
        ('Music Lovers', 'Share and discover music', 'music', '🎵'),
        ('Sports & Fitness', 'Stay active together', 'sports', '⚽'),
        ('Tech & Coding', 'Discuss tech and programming', 'tech', '💻'),
        ('Art & Design', 'Share creative work', 'art', '🎨'),
        ('Book Club', 'Discuss books and literature', 'reading', '📚'),
        ('Foodies', 'Best eats on and off campus', 'food', '🍕'),
        ('Travel & Adventure', 'Share travel experiences', 'travel', '✈️');
      `);
    }
    
    // Message reactions
    if (!(await checkTable('message_reactions'))) {
      console.log('Creating message reactions table...');
      await client.query(`
        CREATE TABLE message_reactions (
          reaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          message_id UUID REFERENCES messages(message_id) ON DELETE CASCADE,
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          emoji VARCHAR(10) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(message_id, user_id, emoji)
        );
      `);
    }
    
    // Profile prompts
    if (!(await checkTable('profile_prompts'))) {
      console.log('Creating profile prompts table...');
      await client.query(`
        CREATE TABLE profile_prompts (
          prompt_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          prompt_text VARCHAR(200) NOT NULL,
          answer TEXT NOT NULL,
          display_order INTEGER DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `);
    }
    
    // User connections
    if (!(await checkTable('user_connections'))) {
      console.log('Creating user connections table...');
      await client.query(`
        CREATE TABLE user_connections (
          connection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_a UUID REFERENCES users(user_id) ON DELETE CASCADE,
          user_b UUID REFERENCES users(user_id) ON DELETE CASCADE,
          connection_type VARCHAR(20) DEFAULT 'match',
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(user_a, user_b)
        );
      `);
    }
    
    // Safety reports
    if (!(await checkTable('safety_reports'))) {
      console.log('Creating safety reports table...');
      await client.query(`
        CREATE TABLE safety_reports (
          report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          reporter_id UUID REFERENCES users(user_id),
          reported_id UUID REFERENCES users(user_id),
          report_type VARCHAR(50),
          description TEXT,
          evidence_url VARCHAR(255),
          status VARCHAR(20) DEFAULT 'pending',
          admin_notes TEXT,
          resolved_by UUID REFERENCES users(user_id),
          resolved_at TIMESTAMP,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE INDEX idx_safety_reports_status ON safety_reports(status);
      `);
    }
    
    // Location features
    if (!(await checkTable('location_checkins'))) {
      console.log('Creating location tables...');
      await client.query(`
        CREATE TABLE location_checkins (
          checkin_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          location_name VARCHAR(200) NOT NULL,
          location_type VARCHAR(50),
          campus VARCHAR(100),
          latitude DECIMAL(10, 8),
          longitude DECIMAL(11, 8),
          expires_at TIMESTAMP NOT NULL,
          is_visible BOOLEAN DEFAULT true,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE TABLE popular_locations (
          location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          name VARCHAR(200) NOT NULL,
          location_type VARCHAR(50),
          campus VARCHAR(100),
          address VARCHAR(255),
          latitude DECIMAL(10, 8),
          longitude DECIMAL(11, 8),
          rating DECIMAL(3, 2) DEFAULT 0,
          checkin_count INTEGER DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(name, campus)
        );
        
        CREATE INDEX idx_location_checkins_expires ON location_checkins(expires_at);
        CREATE INDEX idx_location_checkins_campus ON location_checkins(campus);
      `);
    }
    
    // Notifications
    if (!(await checkTable('notifications'))) {
      console.log('Creating notifications table...');
      await client.query(`
        CREATE TABLE notifications (
          notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
          type VARCHAR(50),
          title VARCHAR(200),
          body TEXT,
          data JSONB,
          is_read BOOLEAN DEFAULT false,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);
      `);
    }
    
    await client.query('COMMIT');
    console.log('✅ Migration completed successfully!');
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

migrate().catch(console.error);
