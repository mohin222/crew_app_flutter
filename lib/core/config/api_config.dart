class ApiConfig {
  // ✅ UPDATED — staging URL from sir
  static const String baseUrl = "https://api-class.rezolv.app";

  // Auth endpoints
  static const String tokenEndpoint = "/api/v1/auth/token/";
  static const String refreshEndpoint = "/api/v1/auth/token/refresh/";
  static const String meEndpoint = "/api/v1/auth/me/";

  // Crew data endpoints
  static const String bookingsEndpoint = "/api/v1/bookings/";
  static const String rosterEndpoint = "/api/v1/roster-lines/";
}