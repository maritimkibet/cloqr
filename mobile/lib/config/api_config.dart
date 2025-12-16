class ApiConfig {
  // PRODUCTION: Render.com URL
  static const String baseUrl = 'https://cloqr-backend.onrender.com/api';
  static const String socketUrl = 'https://cloqr-backend.onrender.com';
  
  // Auth endpoints
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String setupPin = '$baseUrl/auth/setup-pin';
  static const String verifyPin = '$baseUrl/auth/verify-pin';
  
  // Profile endpoints
  static const String profile = '$baseUrl/profile';
  static const String selectAvatar = '$baseUrl/profile/avatar';
  static const String uploadPhoto = '$baseUrl/profile/photo';
  static const String reportUser = '$baseUrl/profile/report';
  static const String blockUser = '$baseUrl/profile/block';
  
  // Match endpoints
  static const String matchQueue = '$baseUrl/match/queue';
  static const String swipe = '$baseUrl/match/swipe';
  static const String matches = '$baseUrl/match/matches';
  static const String studyPartners = '$baseUrl/match/study-partners';
  
  // Chat endpoints
  static const String chats = '$baseUrl/chat';
  static const String createChat = '$baseUrl/chat/create';
  
  // Room endpoints
  static const String rooms = '$baseUrl/rooms';
  static const String createRoom = '$baseUrl/rooms/create';
  static const String joinRoom = '$baseUrl/rooms/join';
  
  // Events endpoints
  static const String events = '$baseUrl/events';
  static const String createEvent = '$baseUrl/events';
  static String eventRsvp(String eventId) => '$baseUrl/events/$eventId/rsvp';
  static String eventAttendees(String eventId) => '$baseUrl/events/$eventId/attendees';
  static String deleteEvent(String eventId) => '$baseUrl/events/$eventId';
  
  // Study Groups endpoints
  static const String studyGroups = '$baseUrl/study-groups';
  static const String createStudyGroup = '$baseUrl/study-groups';
  static String joinStudyGroup(String groupId) => '$baseUrl/study-groups/$groupId/join';
  static String studyGroupMembers(String groupId) => '$baseUrl/study-groups/$groupId/members';
  static String studyGroupSessions(String groupId) => '$baseUrl/study-groups/$groupId/sessions';
  
  // Communities endpoints
  static const String communities = '$baseUrl/communities';
  static String joinCommunity(String communityId) => '$baseUrl/communities/$communityId/join';
  static String leaveCommunity(String communityId) => '$baseUrl/communities/$communityId/leave';
  static String communityPosts(String communityId) => '$baseUrl/communities/$communityId/posts';
  static String likePost(String postId) => '$baseUrl/communities/posts/$postId/like';
  
  // Features endpoints
  static const String icebreaker = '$baseUrl/features/icebreaker';
  static const String polls = '$baseUrl/features/polls';
  static String votePoll(String pollId) => '$baseUrl/features/polls/$pollId/vote';
  static String userBadges(String userId) => '$baseUrl/features/badges/$userId';
  static const String streak = '$baseUrl/features/streak';
  static String messageReactions(String messageId) => '$baseUrl/features/messages/$messageId/reactions';
  static String profilePrompts(String userId) => '$baseUrl/features/prompts/$userId';
  static const String updatePrompts = '$baseUrl/features/prompts';
  static String mutualConnections(String userId) => '$baseUrl/features/mutual/$userId';
  static const String preferences = '$baseUrl/features/preferences';
  
  // Safety endpoints
  static const String safetyReport = '$baseUrl/safety/report';
  static const String safetyTips = '$baseUrl/safety/tips';
  static const String blockWithFeedback = '$baseUrl/safety/block';
  
  // Location endpoints
  static const String checkIn = '$baseUrl/location/checkin';
  static const String checkOut = '$baseUrl/location/checkout';
  static const String nearbyCheckins = '$baseUrl/location/checkins';
  static const String popularLocations = '$baseUrl/location/popular';
  static const String currentCheckin = '$baseUrl/location/current';
}
