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
  static const String chatHistory = '/nahl/chat/rooms';
  static String chatById(String chatId) => '/nahl/chat/history/$chatId';

  /// Mono Link Account endpoints
  static const String fetchInstitutions =
      '/wallet/mono/linkaccount/institutions';
  static const String fetchMonoInputData =
      '/wallet/mono/linkaccount/fetch_mono_inputdata';
  static const String linkAccount = '/wallet/mono/linkaccount/link';
  static const unlinkAccount = '/wallet/mono/linkaccount/unlink';
  static const dashboardData = '/wallet/mono/details/dashboard';
  static const String linkedAccounts = '/wallet/mono/details/alluserbanks';

  /// Account Creation endpoints
  static const String createNairaAccount = '/wallet/accountcreation/ng';

  /// KYC Endpoints
  static const String verifyNin = '/auth/kyc/identity-number/nin/ng';
  static const String verifyBvn = '/auth/kyc/identity-number/bvn/ng';

  /// Home Endpoints
  static const String homeDashboard = '/auth/profile/user/dashboard';

  /// Home Endpoints
  static const String updateProfileAvatar = '/auth/update/avatar';

  /// Debt Endpoints
  static const String debtHome = '/tools/debt/home';
  static String createDebtStep(String stepNumber) =>
      '/tools/debt/create/$stepNumber';
  static String manualFundDebt(String debtId) => '/tools/debt/fund/$debtId';

  /// Bills Endpoints
  // Airtime
  static const String initializeAirtime =
      '/wallet/transactions/bills/airtime/initialize';
  static const String verifyAirtimeTransaction =
      '/wallet/transactions/bills/airtime/verify';

  // Data
  static const String fetchDataPlans = '/wallet/transactions/bills/data/plans';
  static const String initializeDataPurchase =
      '/wallet/transactions/bills/data/initialize';
  static const String verifyDataTransaction =
      '/wallet/transactions/bills/data/verify';

  // TV
  static const String fetchTVProviders =
      '/wallet/transactions/bills/tv/providers';
  static const String fetchTVPlans = '/wallet/transactions/bills/tv/plans';
  static const String initializeTVSubscription =
      '/wallet/transactions/bills/tv/initialize';
  static const String verifyTVSubscription =
      '/wallet/transactions/bills/tv/verify';

  // Electricity
  static const String fetchEletricityProviders =
      '/wallet/transactions/bills/electricity/providers';
  static const String initializeElectricity =
      '/wallet/transactions/bills/electricity/initialize';
  static const String verifyElectricity =
      '/wallet/transactions/bills/electricity/verify';

  /// Streak Endpoints
  static const String streakDetails = '/hive/streak/details';
  static const String streaktopUp = '/hive/streak/topup';
  static const String hiveDetails = '/hive/details';
  static String resourceTopUp(String type) => '/hive/operations/$type';
  static const String addAchievement = '/hive/operations/add/achievement';

  /// Leaderboard Endpoint
  static const String leaderboard = '/hive/details/leaderboard';

  /// Transfer Endpoint
  static const String banks = '/wallet/transactions/sendmoney/getbanks';
  static const String verifyAccounts =
      '/wallet/transactions/sendmoney/verifyaccount';
  static const String initializeTransaction =
      '/wallet/transactions/sendmoney/initialize';
  static const String verifyTransaction =
      '/wallet/transactions/sendmoney/verify';
  static const String sendMoneyInternally =
      '/wallet/transactions/sendmoney/send-internally';

  /// Taxation Endpoints
  static const String taxationHome = '/tools/taxation/home';
  static const String taxationCalculator = '/tools/taxation/calculator';
  static const String taxationStrategies = '/tools/taxation/strategies';
}
