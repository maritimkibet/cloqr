class AppConstants {
  // App Info
  static const String appName = 'Cloqr';
  static const String appVersion = '1.0.0';
  
  // Modes
  static const String modeDating = 'dating';
  static const String modeStudy = 'study';
  static const String modeFriends = 'friends';
  static const String modeGroups = 'groups';
  
  // Chat Types
  static const String chatTypeDirect = 'direct';
  static const String chatTypeGroup = 'group';
  
  // Message Types
  static const String messageTypeText = 'text';
  static const String messageTypePhoto = 'photo';
  static const String messageTypeOneTime = 'one_time';
  
  // Swipe Directions
  static const String swipeLeft = 'left';
  static const String swipeRight = 'right';
  
  // Room Types
  static const String roomTypeHostel = 'hostel';
  static const String roomTypeClass = 'class';
  static const String roomTypeStudy = 'study';
  static const String roomTypeEvent = 'event';
  static const String roomTypeVibe = 'vibe';
  
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyUserPin = 'user_pin';
  
  // Validation
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 50;
  static const int otpLength = 6;
  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  
  // Timeouts
  static const int apiTimeout = 30; // seconds
  static const int otpExpiry = 10; // minutes
  static const int messageExpiry = 24; // hours
  
  // Limits
  static const int maxInterests = 10;
  static const int maxBioLength = 500;
  static const int maxMessageLength = 1000;
  static const int matchQueueSize = 20;
}
