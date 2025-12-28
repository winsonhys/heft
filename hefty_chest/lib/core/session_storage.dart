import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../gen/session.pb.dart';
import 'logging.dart';

/// Service for persisting session data locally as a backup
class SessionStorage {
  static const _backupKey = 'session_backup';
  static const _backupTimestampKey = 'session_backup_timestamp';

  /// Save session to local storage
  static Future<void> saveSession(Session session) async {
    logStorage.fine('Saving session backup: ${session.id}');
    final prefs = await SharedPreferences.getInstance();

    // Convert protobuf to JSON string using toProto3Json for web compatibility
    final jsonStr = jsonEncode(session.toProto3Json());
    await prefs.setString(_backupKey, jsonStr);
    await prefs.setInt(
        _backupTimestampKey, DateTime.now().millisecondsSinceEpoch);
    logStorage.fine('Session backup saved');
  }

  /// Load session from local storage
  static Future<Session?> loadSession() async {
    logStorage.fine('Loading session backup');
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_backupKey);

    if (jsonStr == null || jsonStr.isEmpty) {
      logStorage.fine('No session backup found');
      return null;
    }

    try {
      // Use mergeFromProto3Json for web compatibility
      final session = Session();
      session.mergeFromProto3Json(jsonDecode(jsonStr));
      logStorage.fine('Session backup loaded: ${session.id}');
      return session;
    } catch (e, st) {
      // Corrupted data - clear it
      logStorage.severe('Corrupted session backup, clearing', e, st);
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
    logStorage.fine('Clearing session backup');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_backupKey);
    await prefs.remove(_backupTimestampKey);
  }
}
