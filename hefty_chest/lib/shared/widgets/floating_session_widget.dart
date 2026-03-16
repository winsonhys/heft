import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

part 'floating_session_widget.g.dart';

/// Lightweight data for the floating session widget (no feature imports)
class FloatingSessionData {
  final String id;
  final String name;
  final int completedSets;
  final int totalSets;
  final DateTime? startedAt;

  const FloatingSessionData({
    required this.id,
    required this.name,
    required this.completedSets,
    required this.totalSets,
    this.startedAt,
  });
}

/// Stores the floating widget's position (persists across route changes)
@riverpod
class FloatingSessionPosition extends _$FloatingSessionPosition {
  @override
  Offset build() {
    // Default position: bottom-left area (will be adjusted on first layout)
    return const Offset(16, 600);
  }

  void updatePosition(Offset delta, Size screenSize, Size widgetSize) {
    final newX = (state.dx + delta.dx).clamp(0.0, screenSize.width - widgetSize.width);
    final newY = (state.dy + delta.dy).clamp(0.0, screenSize.height - widgetSize.height - 100);
    state = Offset(newX, newY);
  }

  void setInitialPosition(Size screenSize) {
    // Position at bottom-left, above the bottom nav bar
    state = Offset(16, screenSize.height - 180);
  }
}

/// Controls floating widget visibility (hidden on tracker screen)
@riverpod
class FloatingWidgetVisible extends _$FloatingWidgetVisible {
  @override
  bool build() => true;

  void hide() {
    if (!ref.mounted) return;
    state = false;
  }

  void show() {
    if (!ref.mounted) return;
    state = true;
  }
}

/// Floating widget showing active session progress.
/// Pure UI: session data passed via constructor, no feature imports.
class FloatingSessionWidget extends StatefulHookConsumerWidget {
  final GoRouter router;
  final FloatingSessionData? session;

  const FloatingSessionWidget({
    super.key,
    required this.router,
    this.session,
  });

  @override
  ConsumerState<FloatingSessionWidget> createState() => _FloatingSessionWidgetState();
}

class _FloatingSessionWidgetState extends ConsumerState<FloatingSessionWidget> {
  final GlobalKey _widgetKey = GlobalKey();
  bool _hasSetInitialPosition = false;

  @override
  Widget build(BuildContext context) {
    // Check visibility (hidden when on tracker screen)
    final isVisible = ref.watch(floatingWidgetVisibleProvider);
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final session = widget.session;
    final position = ref.watch(floatingSessionPositionProvider);

    // Capture screen size before callback to avoid context issues
    final screenSize = MediaQuery.of(context).size;

    // Set initial position on first build
    // Capture notifier before callback to avoid accessing ref after widget deactivation
    if (!_hasSetInitialPosition) {
      final notifier = ref.read(floatingSessionPositionProvider.notifier);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasSetInitialPosition) {
          notifier.setInitialPosition(screenSize);
          _hasSetInitialPosition = true;
        }
      });
    }

    // Return early if no session
    if (session == null) {
      return const SizedBox.shrink();
    }

    // Elapsed time timer using hooks
    final elapsedSeconds = useState(0);

    // Timer effect - update elapsed time every second
    useEffect(() {
      // Calculate initial elapsed time
      if (session.startedAt != null) {
        final startedAt = session.startedAt!;
        elapsedSeconds.value = DateTime.now().difference(startedAt).inSeconds;
      }

      // Set up periodic timer
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (session.startedAt != null) {
          final startedAt = session.startedAt!;
          elapsedSeconds.value = DateTime.now().difference(startedAt).inSeconds;
        }
      });

      return timer.cancel;
    }, [session.id]);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          final widgetSize = _widgetKey.currentContext?.size ?? const Size(200, 60);
          ref.read(floatingSessionPositionProvider.notifier)
              .updatePosition(details.delta, screenSize, widgetSize);
        },
        onTap: () {
          widget.router.push('/session/${session.id}');
        },
        child: Material(
          key: _widgetKey,
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: AppColors.accentBlue,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fitness_center, color: AppColors.textPrimary, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          session.name.isNotEmpty ? session.name : 'Workout',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDuration(elapsedSeconds.value),
                          style: const TextStyle(
                            color: AppColors.textPrimaryMuted,
                            fontSize: 12,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${session.completedSets}/${session.totalSets} sets',
                      style: const TextStyle(
                        color: AppColors.textPrimaryMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.textPrimaryMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
