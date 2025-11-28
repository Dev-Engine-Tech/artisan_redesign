class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://apistaging.artisansbridge.com';

  // ==================== AUTHENTICATION ENDPOINTS ====================
  // Auth endpoints (NOTE: Backend uses /auth/ NOT /auth/api/ - documentation is wrong)
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String verifyOtp = '/auth/verify-otp/';
  static const String resendOtp = '/auth/resend-otp/';
  static const String refreshToken = '/auth/token/refresh/';
  static const String forgotPassword = '/auth/forgot-password/';
  static const String resetPassword = '/auth/password/reset/';
  static const String changePassword = '/auth/password/change/';
  static const String logout = '/user/api/logout-user';

  // Social Auth
  static const String googleSignIn = '/auth/google/';
  static const String appleSignIn = '/auth/login/apple';
  static const String oauthConvertToken = '/auth/login/oauth/';

  // Phone Management
  static const String addPhoneNumber = '/auth/add-phone-number';
  static const String verifyPhoneNumber = '/auth/add-phone-number/verify';
  static const String sendPhoneOtp = '/user/api/phone-otp-send';
  static const String verifyPhoneOtp = '/user/api/phone-otp-verify';

  // Account Management
  static const String closeAccountRequest = '/auth/close/account/request/';
  static const String closeAccount = '/auth/close/account/';

  // ==================== SUBSCRIPTION MANAGEMENT ====================
  static const String subscriptionCurrent =
      '/artisan/api/subscription/current/';
  static const String subscriptionPlans = '/artisan/api/subscription/plans/';
  static const String subscriptionPurchase =
      '/artisan/api/subscription/purchase/';
  static const String subscriptionCompletePayment =
      '/artisan/api/subscription/complete-payment/';
  static const String subscriptionUpgrade =
      '/artisan/api/subscription/upgrade/';
  static const String subscriptionCancel = '/artisan/api/subscription/cancel/';
  static const String subscriptionStatus = '/artisan/api/subscription/status/';
  static const String subscriptionApplicationLimit =
      '/artisan/api/subscription/application-limit/';

  // ==================== COLLABORATION SYSTEM ====================
  static const String collaborationInvite =
      '/artisan/api/collaboration/invite/';
  static const String collaborationInviteExternal =
      '/artisan/api/collaboration/invite-external/';
  static const String myCollaborations =
      '/artisan/api/collaboration/my-collaborations/';
  static String collaborationRespond(int collaborationId) =>
      '/artisan/api/collaboration/$collaborationId/respond/';
  static String jobCollaborators(int jobApplicationId) =>
      '/artisan/api/collaboration/job/$jobApplicationId/';

  // ==================== RECOMMENDATION ENGINE ====================
  static const String recommendedJobs = '/artisan/api/recommendations/jobs/';
  static const String recommendedCatalogs =
      '/artisan/api/recommendations/catalogs/';
  static const String recommendationStats =
      '/artisan/api/recommendations/stats/';
  static const String clearRecommendationCache =
      '/artisan/api/recommendations/clear-cache/';

  // ==================== SEARCH & SUGGESTIONS ====================
  static const String searchJobs = '/artisan/api/search/jobs/';
  static const String searchArtisans = '/artisan/api/search/artisans/';
  static const String searchCatalogs = '/artisan/api/search/catalogs/';
  static const String searchCategories = '/artisan/api/search/categories/';
  static const String searchSkills = '/artisan/api/search/skills/';
  static const String searchLocations = '/artisan/api/search/locations/';
  static const String unifiedSearch = '/artisan/api/search/unified/';

  // ==================== PORTFOLIO MANAGEMENT ====================
  static const String portfolioProjects =
      '/artisan/api/portfolio/project/list-create/';
  static String portfolioProject(int id) =>
      '/artisan/api/portfolio/project/$id/update-retrieve-delete/';

  // ==================== BANK DETAILS ====================
  static const String bankDetails = '/artisan/api/add/bank/list-create/';
  static const String addBankAccount =
      '/artisan/api/add/bank/list-create/'; // Alias for backward compatibility
  static const String getBankAccounts =
      '/artisan/api/add/bank/list-create/'; // Alias for backward compatibility
  static const String deleteBankAccount =
      '/artisan/api/add/bank/list-create/'; // Alias for backward compatibility
  static String bankDetail(int id) =>
      '/artisan/api/bank/details/$id/update-retrieve/';
  static const String getBankList = '/user/api/bank-list/';
  static const String verifyBankAccount = '/user/api/verify-bank-account/';
  static const String getBanks = '/job/api/get-banks';

  // ==================== PROFILE & EARNINGS ====================
  static const String artisanProfile = '/artisan/api/profile/';
  static const String userProfile =
      '/artisan/api/profile/'; // Alias for backward compatibility
  static const String updateProfile = '/artisan/api/profile/';
  static const String userEarnings = '/artisan/api/earning/';
  static const String userDetails = '/user/api/user-details/';
  static const String updateBio = '/user/api/bio/update/';
  static const String uploadProfilePicture =
      '/user/api/profile-picture/update/';
  static const String businessSettings = '/artisan/api/business-settings/';
  static const String uploadCompanyLogo =
      '/artisan/api/business-settings/logo/';

  // ==================== WITHDRAWAL & PAYMENTS ====================
  static const String withdrawal = '/artisan/api/withdrawal/';
  static const String withdrawFund = '/artisan/api/withdraw/fund/';
  static const String withdrawEarnings =
      '/artisan/api/withdraw/fund/'; // Alias for backward compatibility
  static const String verifyAccount = '/artisan/api/verify_account/';
  static const String setWithdrawalPin = '/user/api/withdrawal/';
  static const String verifyWithdrawalPin = '/user/api/withdrawal/verify';
  static const String confirmWithdrawalPin = '/user/api/withdrawal/confirm/';
  static const String validateWithdrawalPin =
      '/user/validate-withdrawal-pin/'; // Legacy endpoint
  static const String transactionSummary = '/user/api/transaction/summary/';
  static const String transactionHistory =
      '/user/api/transaction/summary/'; // Alias for backward compatibility

  // ==================== DASHBOARD & ANALYTICS ====================
  static const String dashboard = '/artisan/api/dashboard/';
  static const String projects = '/artisan/api/project/';
  static const String artisanLocation = '/artisan/api/location/';

  // ==================== INVOICE & CUSTOMER MANAGEMENT ====================
  static const String invoices = '/artisan/api/invoices/';
  static String invoice(String uuid) => '/artisan/api/invoices/$uuid/';
  static String sendInvoice(String uuid) => '/artisan/api/invoices/$uuid/send/';
  static String markInvoicePaid(String uuid) =>
      '/artisan/api/invoices/$uuid/mark-paid/';
  static String invoicePdf(String uuid) => '/artisan/api/invoices/$uuid/pdf/';
  static String createInvoiceJob(String uuid) =>
      '/artisan/api/invoices/$uuid/create-job/';
  static const String invoiceDashboard = '/artisan/api/invoices/dashboard/';

  static const String customers = '/artisan/api/customers/';
  static String customer(String uuid) => '/artisan/api/customers/$uuid/';
  static String customerInvoices(String uuid) =>
      '/artisan/api/customers/$uuid/invoices/';

  // ==================== PROFILE BUILDING ====================
  // Professions (NOTE: Backend uses /auth/ NOT /auth/api/)
  static const String professions = '/auth/profession/list-create/';
  static String profession(int id) =>
      '/auth/profession/$id/update-retrieve-delete/';

  // Skills
  static const String skills = '/auth/skills/';
  static const String artisanSkills = '/auth/artisan/skill/list-create/';
  static String skill(int id) => '/auth/skills/$id/';
  static String artisanSkill(int id) =>
      '/auth/artisan/skill/$id/update-retrieve-delete/';

  // Education
  static const String educations = '/auth/educations/';
  static const String educationList = '/auth/education/list-create/';
  static String education(int id) => '/auth/educations/$id/';
  static String educationDetail(int id) =>
      '/auth/education/$id/update-retrieve-delete/';

  // Work Experience
  static const String workExperiences = '/auth/work-experience/';
  static const String workExperienceList = '/auth/work/experience/list-create/';
  static String workExperience(int id) => '/auth/work-experience/$id/';
  static String workExperienceDetail(int id) =>
      '/auth/work/experience/$id/update-retrieve-delete/';

  // Languages, Work Methods, Hour Rates
  static const String languages = '/auth/language/list-create/';
  static const String workMethods = '/auth/work-method/list-create/';
  static const String hourRates = '/auth/hour-rate/list-create/';

  // ==================== JOB MANAGEMENT ====================
  static const String jobs = '/job/api/jobs/';
  static String jobById(int id) => '/job/api/jobs/$id/';
  static const String jobApplication = '/job/api/jobs/application/';
  static const String applyToJob =
      '/job/api/jobs/application/'; // Alias for backward compatibility
  static String jobApplicationWithIds(String jobId, String artisanId) =>
      '/job/api/jobs/application/$jobId/$artisanId/';
  static const String jobApplications = '/job/api/jobs/applications/';
  static String jobApplicationDetails(int appliedJobId) =>
      '/job/api/jobs/applications/$appliedJobId';
  static String saveOrUnsaveJob(int jobId) =>
      '/job/api/jobs/$jobId/save-or-unsave/';
  static const String jobCategories = '/job/api/categories';
  static const String jobSkills = '/job/api/skills/';
  static const String jobSkillsAutocomplete = '/job/api/skills/autocomplete/';

  // Job Contracts
  static String jobContracts(int jobId) =>
      '/job/api/job/$jobId/contracts/list-create/';
  static String jobContract(int id) =>
      '/job/api/job/contracts/$id/update-retrieve-delete/';

  // Job Agreements & Submissions
  static const String jobAgreement = '/job/api/jobs/agreement/';
  static String jobAgreementDetails(int id) => '/job/api/jobs/agreement/$id';
  static String jobAgreementDetailsWithIds(String artisanId, int jobId) =>
      '/job/api/jobs/agreement-quote/details/$artisanId/$jobId/';
  static String acceptProjectAgreement(int id) =>
      '/job/api/project/$id/accept/';
  static String requestProjectChange(int id) =>
      '/job/api/project/$id/request-change/';
  static String jobSubmission(int jobId, int artisanId) =>
      '/job/api/jobs/submissions/$jobId/artisan/$artisanId';
  static String milestoneSubmission(int milestoneId, int artisanId) =>
      '/job/api/jobs/milestone-submissions/$milestoneId/artisan/$artisanId';
  static String jobTimeline(int jobId, int userId) =>
      '/job/api/jobs/application/$jobId/$userId';
  static String materialPayment(int applicationId) =>
      '/job/api/material-payment/$applicationId';
  static String payInspectionFee(String applicationId) =>
      '/job/api/jobs/applications/$applicationId/pay-inspection-fee/';
  static const String payInspectionLegacy = '/job/api/pay-inspection';

  // ==================== NOTIFICATIONS ====================
  static const String notifications = '/user/api/notifications/';
  static const String notificationList = '/user/api/notification/list/';
  static String notification(int id) => '/user/api/notifications/$id/';
  static String notificationRetrieveDelete(int id) =>
      '/user/api/notification/$id/retrieve-delete/';
  static String markNotificationRead(int id) =>
      '/user/api/notifications/$id/read/';
  static String markNotificationReadAlt(int id) =>
      '/user/api/notification/$id/read';
  static const String markNotificationAsRead =
      '/notifications/mark-as-read/'; // Legacy endpoint
  static const String markAllNotificationsRead =
      '/user/api/notifications/mark-all-read/';
  static const String markAllNotificationsAsRead =
      '/notifications/mark-all-as-read/'; // Legacy endpoint
  static const String markAllNotificationsReadAlt =
      '/user/api/mark/all-notifications/';
  static String archiveNotification(int id) =>
      '/user/api/notifications/$id/archive/';
  static String archiveNotificationAlt(int id) =>
      '/user/api/notification/$id/archive';
  static const String deleteAllNotifications =
      '/user/api/notifications/delete-all/';
  static const String deleteAllNotificationsAlt =
      '/user/api/delete/all-notifications/';
  static String notificationStream(int userId) =>
      '/user/api/notifications/$userId';

  // ==================== RATING SYSTEM ====================
  static String userRatings(int userId) => '/user/api/api/ratings/$userId/';
  static String ratingSummary(int userId) =>
      '/user/api/api/ratings/$userId/summary/';
  static const String myRatings = '/user/api/api/ratings/my-ratings/';
  static String canRateUser(int userId) =>
      '/user/api/api/ratings/$userId/can-rate/';
  static const String pendingRatings = '/user/api/api/ratings/pending/';
  static String ratingDetail(int ratingId) =>
      '/user/api/api/ratings/detail/$ratingId/';

  // Legacy rating endpoints (deprecated)
  static String getUserRatingsLegacy(int id) => '/user/api/$id/ratings';
  static String rateUserLegacy(int id) => '/user/api/$id/rate-user';

  // ==================== IDENTITY & VERIFICATION ====================
  static const String submitIdentity = '/user/api/identity/';
  static const String verifyIdentity = '/user/api/verify/identity/';
  static const String checkIdVerification = '/user/api/check/id/verification';
  static const String verificationStatus = '/user/api/verification-status';
  static const String subcategories = '/user/api/subcategories/';

  // ==================== DEVICE & SOCIAL ====================
  static const String deviceTokens = '/user/api/device-tokens/';
  static const String deviceTokensRegister =
      '/user/api/device-tokens/register/'; // Alias for registration
  static String deviceToken(int id) => '/user/api/device-tokens/$id/';
  static const String subscribeToTopics =
      '/user/api/device-tokens/subscribe-to-topics/';
  static const String testPushNotification =
      '/user/api/test-push-notification/';

  // ==================== LOCATION SERVICES ====================
  static const String states = '/user/api/states/';
  static const String statesLocations = '/locations/states/';
  static const String lgas = '/locations/lga/';
  static String lgasByState(int stateId) => '/locations/lga/$stateId/';
  static const String predictLocations = '/locations/predict/';
  static const String getLocationByCoordinates = '/locations/get-location/';

  // ==================== BANNERS ====================
  static String getBanners(String category) =>
      '/auth/get/banners/$category/'; // NOTE: Backend uses /auth/ NOT /auth/api/
  static const String banners = '/banners/';
  static String bannersByCategory(String category) =>
      '/banners/category/$category/';
  static String getBannersByCategory(String category) =>
      '/banners/category/$category/'; // Alias for backward compatibility

  // ==================== CATALOG ENDPOINTS ====================
  static const String catalog = '/catalog/api/artisan/catalog/lists/';
  // For artisans: GET returns own catalogs; POST creates new catalog
  static const String catalogProducts = '/catalog/api/catalog/products/';
  static const String createCatalog = '/catalog/api/catalog/products/';
  static const String updateCatalog = '/catalog/api/catalog/product/';
  static const String deleteCatalog = '/catalog/api/catalog/product/';
  static const String catalogRequests =
      '/catalog/api/artisan/catalog/request/lists/';
  static const String catalogRequestDetails =
      '/catalog/api/artisan/catalog/request/';
  static const String respondToCatalogRequest =
      '/catalog/api/respond-to-catalog-request/';
  static const String myCatalogItems = '/catalog/api/artisan/catalog/lists/';
  static const String catalogByUser = '/catalog/api/artisan/catalog/lists/';
  static String catalogProductDetails(int id) =>
      '/catalog/api/catalog/product/details/$id/';
  static String catalogById(int catalogId) =>
      '/catalog/api/catalog/product/details/$catalogId/';

  // ==================== LEGACY/MISCELLANEOUS ====================
  static const String getUserById = '/user/get-user-by-id/';
  static const String updateUserSkills = '/user/update-user-skills/';
  static const String deleteAccount = '/user/delete-account/';
  static const String jobInvitations = '/job/api/job-invitations/';
  static const String respondToInvitation = '/job/api/respond-to-invitation/';
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
  static const String discoverJobs = '/job/api/discover-jobs/';
  static const String discoverArtisans = '/user/discover-artisans/';
  static const String searchArtisansLegacy = '/user/search-artisans/';
  static const String filterJobs = '/job/api/filter-jobs/';
  static const String uploadImage = '/upload/image/';
  static const String uploadDocument = '/upload/document/';
  static const String uploadVideo = '/upload/video/';
  static const String reportUser = '/user/report-user/';
  static const String blockUser = '/user/block-user/';
  static const String unblockUser = '/user/unblock-user/';
  static const String contactSupport = '/support/contact/';
  static const String appFeedback = '/support/feedback/';

  // Dynamic endpoints with parameters (backward compatibility)
  // Accepts string to support numeric IDs or UUIDs returned by backend
  static String getUserProfileById(String userId) => '/user/profile/$userId/';
  static String acceptAgreementByProjectId(String id) =>
      '/job/api/project/$id/accept/';
  static String saveOrUnsaveJobById(String id) =>
      '/job/api/jobs/$id/save-or-unsave/';
  static String jobRequestChangeById(String jobId) =>
      '/job/api/request-change/$jobId/';
  static String jobProgressById(int jobId) => '/job/api/job-progress/$jobId/';
  static String notificationById(int notificationId) =>
      '/notifications/$notificationId/';
}
