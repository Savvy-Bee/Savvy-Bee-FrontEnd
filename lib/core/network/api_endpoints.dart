class ApiEndpoints {
  /// Base URL
  static const String baseUrl =
      'https://savvy-bee-backend-nodejs-express-mongodb.onrender.com';

  /// Auth endpoints
  static const String register = '/auth/register';
  static const String resendOtp = '/auth/register/resendOtp';
  static const String verifyEmail = '/auth/register/verify-email';
  static const String setOtherDetails = "/auth/register/setotherDetails";
  static const String login = '/auth/login';
  static const String updateUserData = '/auth/update/userdata';
  static const String postOnboard = '/auth/register/postonboard';

  static const String allPersona = '/auth/update/allpersona';

  /// Password reset endpoints
  static const String sendResetOtp = '/auth/reset-password/send-otp';
  static const String verifyResetOtp = '/auth/reset-password/reset';

  /// Chat endpoints (NAHL - AI Assistant)
  static const String chatSend = '/nahl/chat/send';
  static const String chatHistory = '/nahl/chat/history';

  /// Mono Link Account endpoints
  static const String fetchInstitutions =
      '/wallet/mono/linkaccount/institutions';
  static const String fetchMonoInputData =
      '/wallet/mono/linkaccount/fetch_mono_inputdata';
  static const String linkAccount = '/wallet/mono/linkaccount/link_account';
  static const String allLinkedAccounts = '/wallet/mono/details/alluserbanks';

  /// Account Creation endpoints
  static const String createNairaAccount = '/wallet/accountcreation/ng';

  /// Dashboard Data endpoint
  static const String dashboardData = '/wallet/mono/details/dashboard';
  static const String linkedAccounts = '/wallet/mono/details/alluserbanks';

  /// KYC Endpoints
  static const String verifyNin = '/auth/kyc/identity-number/nin/ng';
  static const String verifyBvn = '/auth/kyc/identity-number/bvn/ng';

  /// Home Endpoints
  static const String homeDashboard = '/auth/profile/user/dashboard';

  /// Debt Endpoints
  static const String debtHome = '/tools/debt/home';
  static String createDebtStep(String stepNumber) =>
      '/tools/debt/create/$stepNumber';
  static String manualFundDebt(String debtId) => '/tools/debt/fund/$debtId';

  /// Bills Endpoints
  // Airtime
  static String initializeAirtime = '/wallet/transactions/bills/airtime/initialize';
  static String verifyAirtimeTransaction = '/wallet/transactions/bills/airtime/verify';
  
  // Data
  static String fetchDataPlans = '/wallet/transactions/bills/data/plans';
  static String initializeDataPurchase = '/wallet/transactions/bills/data/initialize';
  static String verifyDataTransaction = '/wallet/transactions/bills/data/verify';
  
  // TV
  static String fetchTVProviders = '/wallet/transactions/bills/tv/providers';
  static String fetchTVPlans = '/wallet/transactions/bills/tv/plans';
  static String initializeTVSubscription = '/wallet/transactions/bills/tv/initialize';
  static String verifyTVSubscription = '/wallet/transactions/bills/tv/verify';
  
  // Electricity
  static String fetchEletricityProviders = '/wallet/transactions/bills/electricity/providers';
  static String initializeElectricity = '/wallet/transactions/bills/electricity/initialize';
  static String verifyElectricity = '/wallet/transactions/bills/electricity/verify';

}
