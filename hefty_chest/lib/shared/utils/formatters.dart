/// Formats duration in seconds to M:SS format: "1:30", "0:45"
String formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// Formats duration as compact human-readable: "1m 30s", "45s", "0s"
///
/// Omits the minutes component when zero. Always shows seconds when
/// there are no minutes.
String formatDurationCompact(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  if (minutes > 0 && seconds > 0) return '${minutes}m ${seconds}s';
  if (minutes > 0) return '${minutes}m';
  return '${seconds}s';
}

/// Formats [Duration] as "Xm Ys", always showing both components: "2m 0s"
String formatDurationFull(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '${minutes}m ${seconds}s';
}

/// Formats time in seconds as M:SS for display, returning "-" for non-positive
/// values and "Xs" for sub-minute durations: "1:30", "45s", "-"
String formatTimeMinSec(int seconds) {
  if (seconds <= 0) return '-';
  final mins = seconds ~/ 60;
  final secs = seconds % 60;
  if (mins > 0) {
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
  return '${secs}s';
}
