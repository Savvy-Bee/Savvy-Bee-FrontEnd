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

  static const String allPersona = '/auth/update/allpersona';

  // Password reset endpoints
  static const String sendResetOtp = '/auth/reset-password/send-otp';
  static const String verifyResetOtp = '/auth/reset-password/reset';

  // Chat endpoints (NAHL - AI Assistant)
  static const String chatSend = '/nahl/chat/send';
  static const String chatHistory = '/nahl/chat/history';

  // Mono Link Account endpoints
  static const String fetchInstitutions =
      '/wallet/mono/linkaccount/institutions';
  static const String fetchMonoInputData =
      '/wallet/mono/linkaccount/fetch_mono_inputdata';
  static const String linkAccount = '/wallet/mono/linkaccount/link_account';
  static const String allLinkedAccounts = '/wallet/mono/details/alluserbanks';

  // Account Creation endpoints
  static const String createNairaAccount = '/wallet/accountcreation/ng';

  // Dashboard Data endpoint
  static const String dashboardData = '/wallet/mono/details/dashboard';
  static const String linkedAccounts = '/wallet/mono/details/alluserbanks';
}
