/*
================================================================================
MONO BANK LINKING FLOW - COMPLETE DOCUMENTATION
================================================================================

📱 SCREEN FLOW:
================================================================================

1️⃣  ConnectBankIntroBottomSheet
    ↓
    User clicks "Continue"
    ↓
2️⃣  SelectBankBottomSheet
    ↓
    - Fetches: institutionsProvider → DashboardRepository.fetchInstitutions()
    - User searches & selects bank
    ↓
3️⃣  SelectedBankLoginBottomSheet
    ↓
    - Fetches: monoInputDataProvider → DashboardRepository.fetchMonoInputData()
    - Gets encrypted BVN, name, email, monoCustomerId
    - User clicks "Go to log in"
    ↓
4️⃣  ProcessingConnectionBottomSheet
    ↓
    - Decrypts BVN using EncryptionService
    - Configures Mono SDK with:
      * publicKey (from Constants)
      * customer data (name, email, BVN)
      * selected institution
    - Launches Mono widget (external bank login)
    ↓
    👤 USER LOGS INTO THEIR BANK (Mono Widget)
    ↓
    ✅ Mono onSuccess callback → Returns `code`
    ↓
5️⃣  _handleLinkAccount(code)
    ↓
    - Calls: linkedAccountsProvider.notifier.linkAccount(code)
    - → DashboardRepository.linkAccount(code)
    - → POST /wallet/mono/linkaccount/link
    ↓
    🔀 TWO POSSIBLE OUTCOMES:
    ↓
    ✅ SUCCESS (status 200, success: true)
    ↓
6️⃣  BankConnectionStatusBottomSheet
    - Shows success message
    - Invalidates dashboardDataProvider
    - Invalidates linkedAccountsProvider
    ↓
    🎉 DONE!

    OR

    ❌ ERROR (status 400/500, success: false)
    ↓
    🚨 Show error SnackBar with message
    ↓
    Close bottom sheet after 3 seconds


================================================================================
🔴 ERROR HANDLING POINTS:
================================================================================

Error Point 1: Camera/BVN Decryption
Location: ProcessingConnectionBottomSheet._connectionConfig()
Error: "Failed to decrypt your identity information"
User sees: SnackBar + bottom sheet closes

Error Point 2: Mono Configuration
Location: ProcessingConnectionBottomSheet.initState()
Error: "Configuration error: [details]"
User sees: SnackBar + bottom sheet closes

Error Point 3: Link Account API Call
Location: ProcessingConnectionBottomSheet._handleLinkAccount()
Errors:
  - 400: "Issue on our end. Please try again in a moment."
  - 401: "Authentication failed. Please check your credentials."
  - 500: "Server error. We're working on it!"
  - Network: "Network error. Check your connection."
User sees: SnackBar + bottom sheet closes after 3 seconds

Error Point 4: User Closes Mono Widget
Location: ConnectConfiguration.onClose
Action: Just closes bottom sheet (no error shown)


================================================================================
📊 DATA FLOW:
================================================================================

API ENDPOINTS USED:
1. GET  /wallet/mono/fetch-institutions    → List<MonoInstitution>
2. GET  /wallet/mono/user-data             → MonoInputData
3. POST /wallet/mono/linkaccount/link      → {success, message, data}
4. GET  /wallet/mono/linkedaccounts        → List<LinkedAccount>
5. GET  /wallet/mono/dashboard/id          → DashboardData

PROVIDERS INVOLVED:
- institutionsProvider          (List<MonoInstitution>)
- monoInputDataProvider         (MonoInputData)
- linkedAccountsProvider        (List<LinkedAccount>)
- dashboardDataProvider('all')  (DashboardData)


================================================================================
🔧 KEY MODELS:
================================================================================

MonoInstitution:
  - id: String
  - institution: String (full name)
  - displayName: String (short name)

MonoInputData:
  - name: String
  - email: String
  - identity: String (encrypted BVN)
  - monoCustomerId: String?

LinkedAccount:
  - id: String
  - monoLinkedAcctId: String
  - institution: AccountInstitution
  - details: Details (account number, name, type)
  - balance: AccountBalance


================================================================================
🐛 DEBUGGING CHECKLIST:
================================================================================

✅ Check Mono public key in Constants
✅ Verify BVN encryption/decryption works
✅ Test API endpoint: POST /wallet/mono/linkaccount/link
✅ Check response format matches ApiResponse<Map<String, dynamic>>
✅ Verify backend is returning correct success/error flags
✅ Test network error scenarios
✅ Check if user has valid BVN
✅ Verify Mono customer ID for existing users


================================================================================
🎯 YOUR CURRENT ERROR:
================================================================================

Error: "Issue on our end. Please try again."
Status: 400
Endpoint: POST /wallet/mono/linkaccount/link

This means:
- Mono SDK returned success with a code ✅
- User logged in successfully ✅
- But YOUR backend couldn't process the link ❌

Possible causes:
1. Backend issue with Mono API integration
2. Invalid code from Mono (expired/used)
3. Duplicate account linking attempt
4. Missing/invalid BVN data
5. Mono account verification failed

Solution:
- Check backend logs for detailed error
- Verify Mono webhook/callback setup
- Test with Mono's test credentials
- Check if code is being sent correctly
- Verify Mono secret key on backend

*/