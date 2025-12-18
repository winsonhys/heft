import 'package:shared_preferences/shared_preferences.dart';

import '../gen/session.pb.dart';

/// Service for persisting session data locally as a backup
class SessionStorage {
  static const _backupKey = 'session_backup';
  static const _backupTimestampKey = 'session_backup_timestamp';

  /// Save session to local storage
  static Future<void> saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert protobuf to JSON string
    final jsonStr = session.writeToJson();
    await prefs.setString(_backupKey, jsonStr);
    await prefs.setInt(
        _backupTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Load session from local storage
  static Future<Session?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_backupKey);

    if (jsonStr == null || jsonStr.isEmpty) {
      return null;
    }

    try {
      return Session.fromJson(jsonStr);
    } catch (e) {
      // Corrupted data - clear it
      await clearSession();
      return null;
    }
  }

  /// Get backup timestamp
  static Future<DateTime?> getBackupTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_backupTimestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if there's a backup
  static Future<bool> hasBackup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_backupKey);
  }

  /// Clear local session backup
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_backupKey);
    await prefs.remove(_backupTimestampKey);
  }
}
