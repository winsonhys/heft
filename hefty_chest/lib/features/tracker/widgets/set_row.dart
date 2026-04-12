import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../models/session_models.dart';

/// Individual set row with editable inputs
class SetRow extends HookWidget {
  static final _mutedTextStyle = FWidgetStateMap(
      {WidgetState.any: const TextStyle(color: AppColors.textMuted)});

  final SessionSetModel set;
  final SessionSetModel? previousSet;
  final bool isTimeBased;
  final Function(String setId, double? weight, int? reps, int? timeSeconds) onComplete;
  final VoidCallback? onDelete;
  final Function(String setId, double rpe)? onRpeChanged;

  const SetRow({
    super.key,
    required this.set,
    this.previousSet,
    this.isTimeBased = false,
    required this.onComplete,
    this.onDelete,
    this.onRpeChanged,
  });

  int? _parseTime(String value) {
    if (value.isEmpty) return null;
    if (value.contains(':')) {
      final parts = value.split(':');
      if (parts.length == 2) {
        final mins = int.tryParse(parts[0]) ?? 0;
        final secs = int.tryParse(parts[1]) ?? 0;
        return mins * 60 + secs;
      }
    }
    return int.tryParse(value);
  }

  /// Formats weight: "82.5" for fractional, "80" for whole numbers.
  static String _formatWeight(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
  }

  static Widget _stepperButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.bgCardInner,
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  String _formatPR() {
    if (isTimeBased) {
      if (set.targetTimeSeconds > 0) {
        return formatDuration(set.targetTimeSeconds);
      }
      return '-';
    }
    final weight = set.targetWeightKg > 0 ? set.targetWeightKg.toStringAsFixed(0) : '-';
    final reps = set.targetReps > 0 ? set.targetReps.toString() : '-';
    if (set.isBodyweight) {
      return 'BW x $reps';
    }
    return '$weight x $reps';
  }

  String _weightText() => set.weightKg > 0
      ? set.weightKg.toStringAsFixed(0)
      : (set.targetWeightKg > 0 ? set.targetWeightKg.toStringAsFixed(0) : '');

  String _repsText() => set.reps > 0
      ? set.reps.toString()
      : (set.targetReps > 0 ? set.targetReps.toString() : '');

  String _timeText() => set.timeSeconds > 0
      ? formatDuration(set.timeSeconds)
      : (set.targetTimeSeconds > 0
          ? formatDuration(set.targetTimeSeconds)
          : '');

  static String _formatRpe(double value) {
    return value == value.truncate() ? value.toStringAsFixed(0) : value.toString();
  }

  void _showRpeBottomSheet(BuildContext context) {
    const rpeValues = [6.0, 6.5, 7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rate of Perceived Exertion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rpeValues.map((value) {
                  final isSelected = set.rpe == value;
                  return GestureDetector(
                    onTap: () {
                      onRpeChanged?.call(set.id, value);
                      Navigator.of(sheetContext).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentBlue : AppColors.bgCardInner,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatRpe(value),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final weightController = useTextEditingController(text: _weightText());
    final repsController = useTextEditingController(text: _repsText());
    final timeController = useTextEditingController(text: _timeText());

    // Track whether the user has manually edited each field
    final weightEdited = useState(set.weightKg > 0);
    final repsEdited = useState(set.reps > 0);
    final timeEdited = useState(set.timeSeconds > 0);

    // Sync controllers when set.id changes (replaces didUpdateWidget)
    useEffect(() {
      weightController.text = _weightText();
      repsController.text = _repsText();
      timeController.text = _timeText();
      weightEdited.value = set.weightKg > 0;
      repsEdited.value = set.reps > 0;
      timeEdited.value = set.timeSeconds > 0;
      return null;
    }, [set.id]);

    FTextFieldStyle Function(FTextFieldStyle)? mutedStyle(bool edited) {
      if (edited) return null;
      return (style) => style.copyWith(contentTextStyle: _mutedTextStyle);
    }

    final hasCopiedPrevious = useState(false);

    // Optimistic local state - updates INSTANTLY on tap
    final isCompleted = useState(set.isCompleted);

    // Sync with prop when provider eventually updates
    useEffect(() {
      isCompleted.value = set.isCompleted;
      return null;
    }, [set.isCompleted]);

    void handleComplete() {
      // INSTANT visual feedback
      isCompleted.value = !isCompleted.value;

      final weight = double.tryParse(weightController.text);
      final reps = int.tryParse(repsController.text);
      final time = _parseTime(timeController.text);

      onComplete(
        set.id,
        isTimeBased ? null : weight,
        isTimeBased ? null : reps,
        isTimeBased ? time : null,
      );
    }

    final bool currentFieldsEmpty = isTimeBased
        ? timeController.text.isEmpty
        : weightController.text.isEmpty && repsController.text.isEmpty;
    final bool previousHasValues = previousSet != null &&
        (isTimeBased
            ? previousSet!.timeSeconds > 0
            : previousSet!.weightKg > 0 || previousSet!.reps > 0);
    final showPreviousHint = currentFieldsEmpty &&
        previousHasValues &&
        !isCompleted.value &&
        !hasCopiedPrevious.value;

    String previousHintText() {
      if (isTimeBased) {
        return formatDuration(previousSet!.timeSeconds);
      }
      final w = previousSet!.weightKg.toStringAsFixed(0);
      final r = previousSet!.reps.toString();
      return '$w \u00d7 $r';
    }

    void copyFromPrevious() {
      if (isTimeBased) {
        timeController.text = formatDuration(previousSet!.timeSeconds);
        timeEdited.value = true;
      } else {
        if (previousSet!.weightKg > 0) {
          weightController.text = previousSet!.weightKg.toStringAsFixed(0);
          weightEdited.value = true;
        }
        if (previousSet!.reps > 0) {
          repsController.text = previousSet!.reps.toString();
          repsEdited.value = true;
        }
      }
      hasCopiedPrevious.value = true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: isCompleted.value ? AppColors.accentCyan.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
          // Set number
          SizedBox(
            width: 36,
            child: Text(
              set.setNumber.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCompleted.value ? AppColors.accentCyan : AppColors.textPrimary,
              ),
            ),
          ),
          // PR value
          SizedBox(
            width: 52,
            child: Text(
              _formatPR(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Weight or Time input
          if (isTimeBased)
            // Time-based: single wide input
            Expanded(
              flex: 2,
              child: FTextField(
                control: .managed(
                    controller: timeController,
                    onChange: (_) => timeEdited.value = true),
                style: mutedStyle(timeEdited.value),
                hint: '0:00',
                keyboardType: TextInputType.number,
              ),
            )
          else ...[
            // Weight input with +/- stepper buttons
            SizedBox(
              width: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stepperButton(
                    label: '-',
                    onTap: () {
                      final current = double.tryParse(weightController.text) ?? 0;
                      final next = (current - 2.5).clamp(0.0, double.infinity);
                      weightController.text = _formatWeight(next);
                      weightEdited.value = true;
                    },
                  ),
                  const SizedBox(width: 2),
                  SizedBox(
                    width: 44,
                    child: FTextField(
                      control: .managed(
                          controller: weightController,
                          onChange: (_) => weightEdited.value = true),
                      style: mutedStyle(weightEdited.value),
                      hint: '-',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 2),
                  _stepperButton(
                    label: '+',
                    onTap: () {
                      final current = double.tryParse(weightController.text) ?? 0;
                      final next = current + 2.5;
                      weightController.text = _formatWeight(next);
                      weightEdited.value = true;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Reps input
            SizedBox(
              width: 52,
              child: FTextField(
                control: .managed(
                    controller: repsController,
                    onChange: (_) => repsEdited.value = true),
                style: mutedStyle(repsEdited.value),
                hint: '-',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
          const SizedBox(width: 6),
          // Rest duration indicator
          if (set.restDurationSeconds > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    formatDuration(set.restDurationSeconds),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          // RPE badge
          if (set.rpe > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                _formatRpe(set.rpe),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          // Complete button (toggle)
          SizedBox(
            width: 32,
            child: GestureDetector(
              onTap: handleComplete,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted.value ? AppColors.accentGreen : Colors.transparent,
                  border: Border.all(
                    color: isCompleted.value ? AppColors.accentGreen : AppColors.textMuted,
                    width: 2,
                  ),
                ),
                child: isCompleted.value
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.textPrimary,
                      )
                    : null,
              ),
            ),
          ),
          // More button
          SizedBox(
            width: 28,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.textMuted,
              ),
              color: AppColors.bgCard,
              onSelected: (value) {
                if (value == 'rpe') {
                  _showRpeBottomSheet(context);
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'rpe',
                  child: Row(
                    children: [
                      Icon(Icons.speed, size: 18, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text('Set RPE'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: AppColors.accentRed),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.accentRed)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
          if (showPreviousHint)
            GestureDetector(
              onTap: copyFromPrevious,
              child: Padding(
                padding: const EdgeInsets.only(left: 94, top: 4),
                child: Text(
                  previousHintText(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
