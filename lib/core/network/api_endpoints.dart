/// API endpoint constants following the artisan app backend structure
class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://artisansbridge.azurewebsites.net';
  
  // Auth endpoints
  static const String auth = 'auth';
  static const String login = '$auth/login/';
  static const String register = '$auth/register/';
  static const String forgotPassword = '$auth/forgot-password/';
  static const String resetPassword = '$auth/password/reset/';
  static const String verifyOtp = '$auth/verify-otp/';
  static const String resendOtp = '$auth/resend-otp/';
  static const String googleSignIn = '$auth/login/oauth/';
  static const String appleSignIn = '$auth/login/apple';
  
  // User endpoints
  static const String user = 'user';
  static const String updateProfileImage = '$user/api/profile-picture/update/';
  static const String updateBio = '$user/api/bio/update/';
  static const String occupationList = '$user/api/occupations';
  static const String transactionHistory = '$user/api/transaction/summary/';
  static const String withdrawalPin = '$user/api/withdrawal/';
  static const String confirmWithdrawalPin = '$user/api/withdrawal/confirm/';
  static const String verifyWithdrawalPin = '$user/api/withdrawal/verify';
  
  // Artisan endpoints
  static const String artisan = 'artisan';
  static const String profile = '$artisan/api/profile/';
  static const String addBank = '$artisan/api/add/bank/list-create/';
  static const String earnings = '$artisan/api/earning/';
  static const String withdrawal = '$artisan/api/withdraw/fund/';
  
  // Job endpoints
  static const String job = 'job';
  static const String jobs = '$job/api/jobs/';
  static const String jobApplications = '${jobs}applications/';
  static const String jobCategories = '$job/api/categories';
  
  // Dynamic job endpoints
  static String saveJob(int jobId) => '$job/api/jobs/$jobId/save-or-unsave/';
  static String acceptAgreement(int agreementId) => '$job/api/project/$agreementId/accept/';
  static String submitProgress(int jobId, int userId) => '${jobs}submissions/$jobId/artisan/$userId';
  
  // Catalog endpoints
  static const String catalog = 'catalog';
  static const String catalogRequests = '$catalog/api/artisan/catalog/request/lists/';
  static const String createCatalogProduct = '$catalog/api/catalog/products/';
  static const String getCatalogProducts = '$catalog/api/artisan/catalog/lists/';
  
  // Dynamic catalog endpoints
  static String catalogRequestDetail(int requestId) => '$catalog/api/catalog/request/details/$requestId/';
  static String catalogRequestMaterials(int requestId) => '$catalog/api/catalog/request/$requestId/materials/';
  static String catalogRequestAgreement(int requestId) => '$catalog/api/catalog/requests/$requestId/artisan-approve-or-disapprove/';
  static String catalogRequestDecline(int requestId) => '$catalog/api/catalog/request/$requestId/decline/';
  static String updateCatalog(int catalogId) => '$catalog/api/catalog/product/$catalogId/';
}