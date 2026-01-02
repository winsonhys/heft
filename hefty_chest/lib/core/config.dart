import 'package:flutter/foundation.dart';
/// App configuration constants
class AppConfig {
  AppConfig._();
  // static const String backendUrl ='https://heft-backend.onrender.com';
  /// Backend API base URL
  
  static const String backendUrl = kReleaseMode ? 'https://heft-751339253558.asia-southeast1.run.app' : 'http://localhost:8080' ;

  /// Default rest timer duration in seconds
  static const int defaultRestTimerSeconds = 90;
}
