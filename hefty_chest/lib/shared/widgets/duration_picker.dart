import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

import '../theme/app_colors.dart';

/// A trigger button that displays current duration and opens picker sheet
class DurationPickerTrigger extends StatelessWidget {
  final Duration duration;
  final ValueChanged<Duration> onChanged;
  final bool isEdited;

  const DurationPickerTrigger({
    super.key,
    required this.duration,
    required this.onChanged,
    this.isEdited = true,
  });

  String _formatDuration() {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => showDurationPickerSheet(
        context: context,
        initialDuration: duration,
        onChanged: onChanged,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDuration(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isEdited ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.edit,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a bottom sheet with duration picker wheels
Future<void> showDurationPickerSheet({
  required BuildContext context,
  required Duration initialDuration,
  required ValueChanged<Duration> onChanged,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgPrimary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _DurationPickerSheet(
      initialDuration: initialDuration,
      onConfirm: (duration) {
        onChanged(duration);
        Navigator.pop(context);
      },
    ),
  );
}

/// Internal sheet content with picker and confirm button
class _DurationPickerSheet extends HookWidget {
  final Duration initialDuration;
  final ValueChanged<Duration> onConfirm;

  // Seconds options in 5-second intervals
  static const _secondsOptions = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];

  const _DurationPickerSheet({
    required this.initialDuration,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = useState(initialDuration.inMinutes);
    // Round to nearest 5-second interval
    final initialSecondsIndex = ((initialDuration.inSeconds % 60) / 5).round().clamp(0, 11);
    final secondsIndex = useState(initialSecondsIndex);

    final controller = useMemoized(
      () => FPickerController(initialIndexes: [minutes.value, secondsIndex.value]),
      [],
    );

    void handleChange(List<int> indexes) {
      minutes.value = indexes[0];
      secondsIndex.value = indexes[1] % _secondsOptions.length;
    }

    return Container(
      height: 380,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          const Text(
            'Set Duration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Picker
          Expanded(
            child: FPicker(
              controller: controller,
              onChange: handleChange,
              children: [
                // Minutes wheel (0-59)
                FPickerWheel.builder(
                  flex: 1,
                  itemExtent: 40,
                  builder: (context, index) => Center(
                    child: Text(
                      '${index % 60}m',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                // Separator
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                // Seconds wheel (5-second intervals: 0, 5, 10, ... 55)
                FPickerWheel.builder(
                  flex: 1,
                  itemExtent: 40,
                  builder: (context, index) => Center(
                    child: Text(
                      '${_secondsOptions[index % _secondsOptions.length]}s',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Confirm button
          SizedBox(
            width: double.infinity,
            child: FButton(
              onPress: () {
                final actualMinutes = minutes.value % 60;
                final actualSeconds = _secondsOptions[secondsIndex.value % _secondsOptions.length];
                onConfirm(Duration(minutes: actualMinutes, seconds: actualSeconds));
              },
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}
