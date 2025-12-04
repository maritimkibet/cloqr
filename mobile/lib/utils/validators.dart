class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    
    return null;
  }
  
  static String? validateCampusEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campus email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    
    // Check for campus email domains
    final email = value.toLowerCase();
    if (!email.endsWith('.edu') &&
        !email.endsWith('.ac.za') &&
        !email.contains('student') &&
        !email.contains('university')) {
      return 'Please use your campus email address';
    }
    
    return null;
  }
  
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.length > 50) {
      return 'Username must be less than 50 characters';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }
  
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    
    return null;
  }
  
  static String? validatePIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    
    if (value.length < 4 || value.length > 6) {
      return 'PIN must be 4-6 digits';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'PIN must contain only numbers';
    }
    
    return null;
  }
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
