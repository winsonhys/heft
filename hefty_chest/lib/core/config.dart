/// App configuration constants
class AppConfig {
  AppConfig._();

  /// Backend API base URL
  static const String backendUrl = 'http://localhost:8080';

  /// Hardcoded user ID for MVP (from seed data)
  static const String hardcodedUserId = '00000000-0000-0000-0000-000000000001';

  /// Default rest timer duration in seconds
  static const int defaultRestTimerSeconds = 90;
}
