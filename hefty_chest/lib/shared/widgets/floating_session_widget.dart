import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/tracker/providers/session_providers.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

part 'floating_session_widget.g.dart';

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

  void hide() => state = false;
  void show() => state = true;
}

/// Floating widget showing active session progress
class FloatingSessionWidget extends StatefulHookConsumerWidget {
  final GoRouter router;

  const FloatingSessionWidget({super.key, required this.router});

  @override
  ConsumerState<FloatingSessionWidget> createState() => _FloatingSessionWidgetState();
}

class _FloatingSessionWidgetState extends ConsumerState<FloatingSessionWidget> {
  final GlobalKey _widgetKey = GlobalKey();
  bool _hasSetInitialPosition = false;

  @override
  void initState() {
    super.initState();
    // Listen to route changes to rebuild when navigating to/from session screen
    widget.router.routerDelegate.addListener(_onRouteChange);
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChange);
    super.dispose();
  }

  void _onRouteChange() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check visibility (hidden when on tracker screen)
    final isVisible = ref.watch(floatingWidgetVisibleProvider);
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    // Watch activeSessionProvider for live updates (sets completing in real-time)
    final activeSession = ref.watch(activeSessionProvider);
    // Fallback to hasActiveSessionProvider for initial session load
    final fallbackSession = ref.watch(hasActiveSessionProvider);

    // Use active session if available, otherwise use fallback
    final session = activeSession.value ?? fallbackSession.value;

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
                const Icon(Icons.fitness_center, color: Colors.white, size: 20),
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
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDuration(elapsedSeconds.value),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${session.completedSets}/${session.totalSets} sets',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
