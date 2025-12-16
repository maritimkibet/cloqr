# Cloqr New Features Implementation Guide

## ✅ Completed Backend Setup

### Database Schema
- ✅ All new tables created in `schema.sql`
- ✅ Migration script created: `migrate-new-features.js`
- ✅ Indexes added for performance
- ✅ Seed data for icebreakers and communities

### Backend Controllers Created
1. ✅ `events.controller.js` - Events & meetups
2. ✅ `study-groups.controller.js` - Study groups & sessions
3. ✅ `community.controller.js` - Interest-based communities
4. ✅ `features.controller.js` - Icebreakers, polls, badges, streaks, reactions, prompts
5. ✅ `safety.controller.js` - Enhanced safety reports
6. ✅ `location.controller.js` - Check-ins & popular locations

### Backend Routes Created
1. ✅ `/api/events` - Event management
2. ✅ `/api/study-groups` - Study group management
3. ✅ `/api/communities` - Community features
4. ✅ `/api/features` - Misc features (polls, badges, etc)
5. ✅ `/api/safety` - Safety & reporting
6. ✅ `/api/location` - Location features

### Frontend Models Created
1. ✅ `event_model.dart`
2. ✅ `community_model.dart`
3. ✅ `study_group_model.dart`
4. ✅ `poll_model.dart`

### API Config Updated
- ✅ All new endpoints added to `api_config.dart`

---

## 🚀 How to Deploy Backend Changes

### Step 1: Run Database Migration
```bash
cd cloqr-backend
node migrate-new-features.js
```

### Step 2: Test Backend Locally
```bash
npm start
```

### Step 3: Deploy to Render
```bash
git add .
git commit -m "Add new features: events, study groups, communities, etc"
git push origin main
```

Render will auto-deploy. Check logs for any errors.

---

## 📱 Frontend Implementation TODO

### Priority 1: Core Screens (Implement First)

#### 1. Events Screen
**File**: `mobile/lib/screens/events/events_screen.dart`
**Features**:
- List all upcoming events
- Filter by type (party, study, sports, social)
- RSVP buttons (Going, Interested, Maybe)
- Create new event button
- Show attendee count

**Provider**: `mobile/lib/providers/event_provider.dart`
- `getEvents()`
- `createEvent()`
- `rsvpEvent()`
- `getEventAttendees()`

#### 2. Study Groups Screen
**File**: `mobile/lib/screens/study/study_groups_screen.dart`
**Features**:
- List study groups by course
- Join/leave groups
- View group members
- Create study sessions
- Show upcoming sessions

**Provider**: `mobile/lib/providers/study_group_provider.dart`
- `getStudyGroups()`
- `createStudyGroup()`
- `joinGroup()`
- `createSession()`

#### 3. Communities Screen
**File**: `mobile/lib/screens/community/communities_screen.dart`
**Features**:
- Grid of community cards with icons
- Join/leave communities
- View community posts
- Create posts
- Like/unlike posts

**Provider**: `mobile/lib/providers/community_provider.dart`
- `getCommunities()`
- `joinCommunity()`
- `getPosts()`
- `createPost()`
- `likePost()`

### Priority 2: Enhanced Features

#### 4. Update Home Screen Navigation
**File**: `mobile/lib/screens/home/home_screen.dart`
**Changes**:
- Add "Discover" tab with:
  - Events
  - Study Groups
  - Communities
  - Polls
- Keep existing tabs: Match, Chats, Rooms, Profile

#### 5. Profile Enhancements
**File**: `mobile/lib/screens/profile/profile_screen.dart`
**Add**:
- Badges display
- Streak counter with fire emoji
- Profile prompts section
- Trust score visibility toggle

#### 6. Chat Enhancements
**File**: `mobile/lib/screens/chat/chat_detail_screen.dart`
**Add**:
- Message reactions (emoji picker)
- Icebreaker question button
- Reaction display under messages

#### 7. Settings Screen Updates
**File**: `mobile/lib/screens/profile/settings_screen.dart`
**Add**:
- Dark mode toggle
- Notification preferences
- Trust score visibility
- Online status visibility
- Discovery enabled toggle

### Priority 3: Location & Safety

#### 8. Location Check-in Screen
**File**: `mobile/lib/screens/location/location_screen.dart`
**Features**:
- Check in to location
- See who's nearby
- Popular locations list
- Map view (optional)

#### 9. Safety Center
**File**: `mobile/lib/screens/safety/safety_center_screen.dart`
**Features**:
- Safety tips
- Report user with categories
- Block with feedback
- Emergency contacts

### Priority 4: Polls & Engagement

#### 10. Polls Screen
**File**: `mobile/lib/screens/polls/polls_screen.dart`
**Features**:
- Active polls list
- Vote on polls
- Create new poll
- View results with percentages

---

## 🎨 UI Components to Create

### 1. Event Card Widget
```dart
// mobile/lib/widgets/event_card.dart
- Event title, time, location
- Attendee avatars
- RSVP button
- Event type badge
```

### 2. Study Group Card Widget
```dart
// mobile/lib/widgets/study_group_card.dart
- Group name, course
- Member count
- Join button
- Tags display
```

### 3. Community Card Widget
```dart
// mobile/lib/widgets/community_card.dart
- Community icon & name
- Member count
- Join/Joined status
- Category badge
```

### 4. Badge Widget
```dart
// mobile/lib/widgets/badge_widget.dart
- Badge icon
- Badge name
- Earned date
- Tooltip with description
```

### 5. Streak Counter Widget
```dart
// mobile/lib/widgets/streak_counter.dart
- Fire emoji
- Current streak number
- Longest streak
- Progress indicator
```

### 6. Poll Card Widget
```dart
// mobile/lib/widgets/poll_card.dart
- Question
- Options with vote percentages
- Vote button
- Total votes
```

### 7. Reaction Picker Widget
```dart
// mobile/lib/widgets/reaction_picker.dart
- Emoji grid
- Quick reactions (❤️ 😂 👍 🔥)
- Add reaction to message
```

---

## 🔧 Implementation Steps

### Week 1: Events & Study Groups
1. Create event provider & screens
2. Create study group provider & screens
3. Test event creation & RSVP
4. Test study group joining & sessions

### Week 2: Communities & Engagement
1. Create community provider & screens
2. Implement post creation & likes
3. Create polls provider & screens
4. Add icebreaker integration to chats

### Week 3: Profile & Settings
1. Add badges to profile
2. Implement streak tracking
3. Add profile prompts
4. Update settings with new preferences

### Week 4: Location & Safety
1. Create location check-in feature
2. Implement safety center
3. Add enhanced reporting
4. Test all features end-to-end

---

## 🧪 Testing Checklist

### Backend Tests
- [ ] Events CRUD operations
- [ ] Study groups CRUD operations
- [ ] Community posts & likes
- [ ] Poll voting
- [ ] Streak updates
- [ ] Badge awarding
- [ ] Location check-ins
- [ ] Safety reports

### Frontend Tests
- [ ] Event creation & RSVP
- [ ] Study group joining
- [ ] Community posts
- [ ] Poll voting UI
- [ ] Streak display
- [ ] Badge display
- [ ] Message reactions
- [ ] Profile prompts
- [ ] Dark mode toggle
- [ ] Location check-in
- [ ] Safety reporting

---

## 📊 Database Maintenance

### Cleanup Jobs (Add to cron or scheduled tasks)
```javascript
// Clean expired events
DELETE FROM events WHERE end_time < NOW() - INTERVAL '7 days';

// Clean expired check-ins
DELETE FROM location_checkins WHERE expires_at < NOW();

// Clean expired polls
UPDATE polls SET is_active = false WHERE expires_at < NOW();

// Clean old notifications
DELETE FROM notifications WHERE created_at < NOW() - INTERVAL '30 days' AND is_read = true;
```

---

## 🎯 Quick Start Guide

### For Immediate Testing:

1. **Run Migration**:
```bash
cd cloqr-backend
node migrate-new-features.js
```

2. **Test Events API**:
```bash
curl -X GET http://localhost:3000/api/events \
  -H "Authorization: Bearer YOUR_TOKEN"
```

3. **Create Test Event**:
```bash
curl -X POST http://localhost:3000/api/events \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Study Session",
    "event_type": "study",
    "start_time": "2025-01-01T10:00:00Z",
    "campus": "Main Campus"
  }'
```

4. **Test Study Groups**:
```bash
curl -X GET http://localhost:3000/api/study-groups \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🚨 Important Notes

1. **Streak System**: Call `/api/features/streak` POST endpoint on app launch to update user streaks
2. **Badge Awarding**: Badges are auto-awarded based on actions (7-day streak, verified email, etc)
3. **Location Privacy**: Users can toggle location visibility in preferences
4. **Safety**: All reports are reviewed by admins before action
5. **Performance**: Indexes are added for all frequently queried fields

---

## 📞 Support

If you encounter issues:
1. Check backend logs: `heroku logs --tail` or Render logs
2. Verify database migration completed successfully
3. Test API endpoints with Postman/curl
4. Check Flutter console for errors

---

## 🎉 Next Steps

1. Run the migration script
2. Start with Priority 1 screens (Events, Study Groups, Communities)
3. Test each feature thoroughly
4. Add analytics tracking
5. Gather user feedback
6. Iterate and improve

Good luck! 🚀
