import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../gen/session.pb.dart';

/// Individual set row with editable inputs
class SetRow extends StatefulWidget {
  final SessionSet set;
  final bool isTimeBased;
  final Function(String setId, double? weight, int? reps, int? timeSeconds) onComplete;

  const SetRow({
    super.key,
    required this.set,
    this.isTimeBased = false,
    required this.onComplete,
  });

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weightKg > 0 ? widget.set.weightKg.toStringAsFixed(0) : '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps > 0 ? widget.set.reps.toString() : '',
    );
    _timeController = TextEditingController(
      text: widget.set.timeSeconds > 0 ? _formatTime(widget.set.timeSeconds) : '',
    );
  }

  @override
  void didUpdateWidget(SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.set.id != widget.set.id) {
      _weightController.text = widget.set.weightKg > 0 ? widget.set.weightKg.toStringAsFixed(0) : '';
      _repsController.text = widget.set.reps > 0 ? widget.set.reps.toString() : '';
      _timeController.text = widget.set.timeSeconds > 0 ? _formatTime(widget.set.timeSeconds) : '';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

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
    if (widget.isTimeBased) {
      if (widget.set.targetTimeSeconds > 0) {
        return _formatTime(widget.set.targetTimeSeconds);
      }
      return '-';
    }
    final weight = widget.set.targetWeightKg > 0 ? widget.set.targetWeightKg.toStringAsFixed(0) : '-';
    final reps = widget.set.targetReps > 0 ? widget.set.targetReps.toString() : '-';
    if (widget.set.isBodyweight) {
      return 'BW x $reps';
    }
    return '$weight x $reps';
  }

  void _handleComplete() {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);
    final time = _parseTime(_timeController.text);

    widget.onComplete(
      widget.set.id,
      widget.isTimeBased ? null : weight,
      widget.isTimeBased ? null : reps,
      widget.isTimeBased ? time : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.set.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0x0D22D3EE) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 36,
            child: Text(
              widget.set.setNumber.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCompleted ? const Color(0xFF22D3EE) : AppColors.textPrimary,
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
          if (widget.isTimeBased)
            // Time-based: single wide input
            Expanded(
              flex: 2,
              child: _buildInput(
                controller: _timeController,
                placeholder: '0:00',
                isCompleted: isCompleted,
              ),
            )
          else ...[
            // Weight input
            SizedBox(
              width: 52,
              child: _buildInput(
                controller: _weightController,
                placeholder: '-',
                isCompleted: isCompleted,
              ),
            ),
            const SizedBox(width: 6),
            // Reps input
            SizedBox(
              width: 52,
              child: _buildInput(
                controller: _repsController,
                placeholder: '-',
                isCompleted: isCompleted,
              ),
            ),
          ],
          const SizedBox(width: 6),
          // Complete button
          SizedBox(
            width: 32,
            child: GestureDetector(
              onTap: isCompleted ? null : _handleComplete,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.accentGreen : Colors.transparent,
                  border: Border.all(
                    color: isCompleted ? AppColors.accentGreen : AppColors.textMuted,
                    width: 2,
                  ),
                ),
                child: isCompleted
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
            child: GestureDetector(
              onTap: () {
                // TODO: Show context menu
              },
              child: const Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String placeholder,
    required bool isCompleted,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: isCompleted ? const Color(0xFF22D3EE) : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
      ],
    );
  }
}
