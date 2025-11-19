class ApiConfig {
  // Use your computer's IP address so phone can connect
  // Change this to 'localhost' if running on emulator
  static const String baseUrl = 'http://10.10.8.33:3000/api';
  static const String socketUrl = 'http://10.10.8.33:3000';
  
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
}
