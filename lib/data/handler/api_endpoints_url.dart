class ApiEndpoints {
  ApiEndpoints._();

  static String baseUrl = '';
  static String imageBaseUrl = '';
  static String storage = '';

  // Auth
  static const String signIn = '/auth/sign-in';

  // Dashboard Stats
  static const String dashboardStats = '/api/admin/dashboard/stats';

  // Driver Verification (KYC)
  static const String verifications = '/api/admin/verifications';
  static String verificationDetails(String id) => '/api/admin/verifications/$id';
  static String approveVerification(String id) => '/api/admin/verifications/$id/approve';
  static String rejectVerification(String id) => '/api/admin/verifications/$id/reject';

  // Support Tickets
  static const String tickets = '/api/admin/tickets';
  static String ticketDetails(String id) => '/api/admin/tickets/$id';
  static String replyTicket(String id) => '/api/admin/tickets/$id/reply';
  static String updateTicketStatus(String id) => '/api/admin/tickets/$id/status';

  // Allowed Locations & Service Areas
  static const String locations = '/api/admin/locations';
  static String locationDetails(String id) => '/api/admin/locations/$id';
}
