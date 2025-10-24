class ApiEndpoints {
  // Base URL
  static const String baseUrl =
      'https://savvy-bee-backend-nodejs-express-mongodb.onrender.com';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String resendOtp = '/auth/register/resendOtp';
  static const String verifyEmail = '/auth/register/verify-email';
  static const String setOtherDetails = "/auth/register/setotherDetails";
  static const String login = '/auth/login';
  static const String updateUserData = '/auth/update/userdata';

  // Password reset endpoints
  static const String sendResetOtp = '/auth/reset-password/send-otp';
  static const String verifyResetOtp = '/auth/reset-password/reset';

  // Chat endpoints (NAHL - AI Assistant)
  static const String chatSend = '/nahl/chat/send';
  static const String chatHistory = '/nahl/chat/history';
}
