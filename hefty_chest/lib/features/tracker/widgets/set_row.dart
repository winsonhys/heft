import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

import '../../../shared/theme/app_colors.dart';
import '../models/session_models.dart';

/// Individual set row with editable inputs
class SetRow extends HookWidget {
  final SessionSetModel set;
  final bool isTimeBased;
  final Function(String setId, double? weight, int? reps, int? timeSeconds) onComplete;
  final VoidCallback? onDelete;

  const SetRow({
    super.key,
    required this.set,
    this.isTimeBased = false,
    required this.onComplete,
    this.onDelete,
  });

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

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
        return _formatTime(set.targetTimeSeconds);
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
      text: set.timeSeconds > 0 ? _formatTime(set.timeSeconds) : '',
    );

    // Sync controllers when set.id changes (replaces didUpdateWidget)
    useEffect(() {
      weightController.text = set.weightKg > 0 ? set.weightKg.toStringAsFixed(0) : '';
      repsController.text = set.reps > 0 ? set.reps.toString() : '';
      timeController.text = set.timeSeconds > 0 ? _formatTime(set.timeSeconds) : '';
      return null;
    }, [set.id]);

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
                        color: Colors.white,
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
                if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
              itemBuilder: (context) => [
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
