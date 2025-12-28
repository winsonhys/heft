import 'package:logging/logging.dart';

/// Initialize logging for the Heft app.
/// Call this once in main() before runApp().
///
/// Logger hierarchy:
/// - heft.auth      - Authentication operations
/// - heft.session   - Workout session management (CRITICAL)
/// - heft.workout   - Workout builder operations
/// - heft.program   - Program builder operations
/// - heft.profile   - User profile operations
/// - heft.progress  - Progress/stats operations
/// - heft.calendar  - Calendar operations
/// - heft.history   - Session history operations
/// - heft.home      - Home screen operations
/// - heft.storage   - Local storage operations
void initializeLogging() {
  // Set root level - ALL in debug, WARNING in release
  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((record) {
    // Format: [LEVEL] TIME LoggerName: Message
    final time = record.time.toIso8601String().substring(11, 23);
    final output = StringBuffer()
      ..write('[${record.level.name.padRight(7)}] ')
      ..write('$time ')
      ..write('${record.loggerName}: ')
      ..write(record.message);

    // Add error and stack trace for SEVERE/WARNING
    if (record.error != null) {
      output.write('\n  Error: ${record.error}');
    }
    if (record.stackTrace != null && record.level >= Level.SEVERE) {
      output.write('\n  Stack: ${record.stackTrace}');
    }

    // ignore: avoid_print
    print(output.toString());
  });
}

// Pre-defined loggers for each feature
final logAuth = Logger('heft.auth');
final logSession = Logger('heft.session');
final logWorkout = Logger('heft.workout');
final logProgram = Logger('heft.program');
final logProfile = Logger('heft.profile');
final logProgress = Logger('heft.progress');
final logCalendar = Logger('heft.calendar');
final logHistory = Logger('heft.history');
final logHome = Logger('heft.home');
final logStorage = Logger('heft.storage');
