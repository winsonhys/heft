import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/modal_sheet.dart';
import '../models/session_models.dart';

/// Individual set row with editable inputs
class SetRow extends HookWidget {
  final SessionSetModel set;
  final bool isTimeBased;
  final Function(String setId, double? weight, int? reps, int? timeSeconds) onComplete;
  final VoidCallback? onDelete;
  final Function(String setId, String notes)? onNotesChanged;

  const SetRow({
    super.key,
    required this.set,
    this.isTimeBased = false,
    required this.onComplete,
    this.onDelete,
    this.onNotesChanged,
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

  @override
  Widget build(BuildContext context) {
    final weightController = useTextEditingController(
      text: set.weightKg > 0 ? set.weightKg.toStringAsFixed(0) : '',
    );
    final repsController = useTextEditingController(
      text: set.reps > 0 ? set.reps.toString() : '',
    );
    final timeController = useTextEditingController(
      text: set.timeSeconds > 0 ? formatDuration(set.timeSeconds) : '',
    );

    // Sync controllers when set.id changes (replaces didUpdateWidget)
    useEffect(() {
      weightController.text = set.weightKg > 0 ? set.weightKg.toStringAsFixed(0) : '';
      repsController.text = set.reps > 0 ? set.reps.toString() : '';
      timeController.text = set.timeSeconds > 0 ? formatDuration(set.timeSeconds) : '';
      return null;
    }, [set.id]);

    // Optimistic local state - updates INSTANTLY on tap
    final isCompleted = useState(set.isCompleted);

    // Sync with prop when provider eventually updates
    useEffect(() {
      isCompleted.value = set.isCompleted;
      return null;
    }, [set.isCompleted]);

    void showNoteSheet(BuildContext ctx) {
      final noteController = TextEditingController(text: set.notes);
      showHeftModalSheet(
        context: ctx,
        backgroundColor: AppColors.bgCard,
        builder: (sheetContext) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set Note',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              FTextField(
                control: .managed(controller: noteController),
                hint: 'Add a note...',
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 12),
              FButton(
                onPress: () {
                  onNotesChanged?.call(set.id, noteController.text);
                  Navigator.of(sheetContext).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ).whenComplete(noteController.dispose);
    }

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: isCompleted.value ? const Color(0x0D22D3EE) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 36,
            child: Text(
              set.setNumber.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCompleted.value ? const Color(0xFF22D3EE) : AppColors.textPrimary,
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
                control: .managed(controller: timeController),
                hint: '0:00',
                keyboardType: TextInputType.number,
              ),
            )
          else ...[
            // Weight input
            SizedBox(
              width: 52,
              child: FTextField(
                control: .managed(controller: weightController),
                hint: '-',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 6),
            // Reps input
            SizedBox(
              width: 52,
              child: FTextField(
                control: .managed(controller: repsController),
                hint: '-',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
          const SizedBox(width: 6),
          // Note indicator
          if (set.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => showNoteSheet(context),
                child: const Icon(
                  Icons.sticky_note_2_outlined,
                  size: 14,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
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
                if (value == 'note') {
                  showNoteSheet(context);
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'note',
                  child: Row(
                    children: [
                      const Icon(Icons.note_add_outlined, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(set.notes.isNotEmpty ? 'Edit Note' : 'Add Note'),
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
    );
  }
}
