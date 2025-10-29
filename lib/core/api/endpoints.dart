class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://apiprod.artisansbridge.com';

  // Auth endpoints
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String forgotPassword = '/auth/forgot-password/';
  static const String resetPassword = '/auth/password/reset/';
  static const String changePassword = '/auth/password/change/';
  static const String verifyOtp = '/auth/verify-otp/';
  static const String resendOtp = '/auth/resend-otp/';
  static const String googleSignIn = '/auth/login/oauth/';
  static const String appleSignIn = '/auth/login/apple';
  static const String addPhoneNumber = '/auth/add-phone-number';
  static const String verifyPhoneNumber = '/auth/add-phone-number/verify';

  // User/Profile endpoints (align to GetX app working path)
  static const String userProfile = '/artisan/api/profile/';
  static const String updateProfile = '/artisan/api/profile/';
  static const String getUserById = '/user/get-user-by-id/';
  static const String updateUserSkills = '/user/update-user-skills/';
  static const String uploadProfilePicture =
      '/user/api/profile-picture/update/';
  static const String deleteAccount = '/user/delete-account/';

  // Earnings and Transaction endpoints (artisan scope)
  static const String userEarnings = '/artisan/api/earning/';
  static const String withdrawEarnings = '/artisan/api/withdraw/fund/';
  static const String transactionHistory = '/user/api/transaction/summary/';
  static const String validateWithdrawalPin = '/user/validate-withdrawal-pin/';
  static const String setWithdrawalPin = '/user/set-withdrawal-pin/';

  // Bank Management endpoints
  static const String addBankAccount = '/artisan/api/add/bank/list-create/';
  static const String getBankAccounts = '/artisan/api/add/bank/list-create/';
  static const String deleteBankAccount = '/artisan/api/add/bank/list-create/';
  static const String getBankList = '/user/bank-list/';
  static const String verifyBankAccount = '/user/verify-bank-account/';

  // Jobs/Projects endpoints
  static const String jobs = '/job/api/jobs/';
  static const String jobCategories = '/job/api/categories';
  static const String jobsByCategory = '/job/api/jobs-by-category/';
  static const String applyToJob = '/job/api/jobs/applications/';
  static const String jobApplications = '/job/api/jobs/applications/';
  static const String jobInvitations = '/job/api/job-invitations/';
  static const String respondToInvitation = '/job/api/respond-to-invitation/';
  static const String saveJob = '/job/api/jobs/{id}/save-or-unsave/';
  static const String savedJobs = '/job/api/jobs/saved/';
  static const String appliedJobs = '/job/api/jobs/applications/';
  static const String myJobs = '/job/api/project/';
  static const String jobDetails = '/job/api/job-details/';
  static const String inviteArtisan = '/job/api/invite-artisan/';
  static const String acceptAgreement = '/job/api/project/{id}/accept/';
  static const String requestChange = '/job/api/request-change/';
  static const String submitProgress = '/job/api/submit-progress/';
  static const String approveProgress = '/job/api/approve-progress/';
  static const String completeJob = '/job/api/complete-job/';
  static const String rateUser = '/job/api/rate-user/';

  // Catalog endpoints - Updated to match actual backend API
  static const String catalog = '/catalog/api/artisan/catalog/lists/';
  static const String createCatalog = '/catalog/api/catalog/products/';
  static const String updateCatalog = '/catalog/api/catalog/product/';
  static const String deleteCatalog = '/catalog/api/catalog/product/';
  static const String catalogRequests =
      '/catalog/api/artisan/catalog/request/lists/';
  static const String catalogRequestDetails =
      '/catalog/api/catalog-request-details/';
  static const String respondToCatalogRequest =
      '/catalog/api/respond-to-catalog-request/';
  static const String myCatalogItems = '/catalog/api/artisan/catalog/lists/';
  static const String catalogByUser = '/catalog/api/artisan/catalog/lists/';

  // Discovery/Search endpoints
  static const String discoverJobs = '/job/api/discover-jobs/';
  static const String discoverArtisans = '/user/discover-artisans/';
  static const String searchJobs = '/job/api/search-jobs/';
  static const String searchArtisans = '/user/search-artisans/';
  static const String filterJobs = '/job/api/filter-jobs/';

  // Location endpoints
  static const String states = '/location/states/';
  static const String lgas = '/location/lgas/';
  static const String getLocationByCoordinates = '/location/get-location/';

  // Notification endpoints
  static const String notifications = '/notifications/';
  static const String markNotificationAsRead = '/notifications/mark-as-read/';
  static const String markAllNotificationsAsRead =
      '/notifications/mark-all-as-read/';
  static const String deviceTokensRegister = '/user/api/device-tokens/register/';
  static const String testPushNotification = '/user/api/test-push-notification/';

  // File Upload endpoints
  static const String uploadImage = '/upload/image/';
  static const String uploadDocument = '/upload/document/';
  static const String uploadVideo = '/upload/video/';

  // Banner endpoints
  static const String banners = '/banners/';
  static const String bannersByCategory = '/banners/category/';

  // Miscellaneous endpoints
  static const String reportUser = '/user/report-user/';
  static const String blockUser = '/user/block-user/';
  static const String unblockUser = '/user/unblock-user/';
  static const String contactSupport = '/support/contact/';
  static const String appFeedback = '/support/feedback/';

  // Dynamic endpoints with parameters
  static String getUserProfileById(int userId) => '/user/profile/$userId/';
  static String jobById(int jobId) => '/job/api/jobs/$jobId/';
  static String acceptAgreementByProjectId(String id) =>
      '/job/api/project/$id/accept/';
  static String saveOrUnsaveJobById(String id) =>
      '/job/api/jobs/$id/save-or-unsave/';
  static String catalogById(int catalogId) =>
      '/catalog/api/catalog/$catalogId/';
  static String jobRequestChangeById(String jobId) =>
      '/job/api/request-change/$jobId/';
  static String jobProgressById(int jobId) => '/job/api/job-progress/$jobId/';
  static String notificationById(int notificationId) =>
      '/notifications/$notificationId/';
  static String lgasByState(int stateId) => '/location/lgas/$stateId/';
  static String getBannersByCategory(String category) =>
      '/banners/category/$category/';

  // Banner endpoints with category support
  static String getBanners(String category) => '/auth/get/banners/$category/';
}
