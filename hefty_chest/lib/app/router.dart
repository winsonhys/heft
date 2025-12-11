import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/tracker/tracker_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/workout_builder/workout_builder_screen.dart';
import '../features/program_builder/program_builder_screen.dart';

part 'router.g.dart';

// =============================================================================
// Type-Safe Route Definitions
// =============================================================================

/// Home route - main screen with workout list
@TypedGoRoute<HomeRoute>(path: '/')
@immutable
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}

/// Profile route - user settings and stats
@TypedGoRoute<ProfileRoute>(path: '/profile')
@immutable
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileScreen();
  }
}

/// Progress route - analytics dashboard
@TypedGoRoute<ProgressRoute>(path: '/progress')
@immutable
class ProgressRoute extends GoRouteData with $ProgressRoute {
  const ProgressRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProgressScreen();
  }
}

/// Calendar route - workout calendar view
@TypedGoRoute<CalendarRoute>(path: '/calendar')
@immutable
class CalendarRoute extends GoRouteData with $CalendarRoute {
  const CalendarRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CalendarScreen();
  }
}

/// New session route - start a new workout session
@TypedGoRoute<NewSessionRoute>(path: '/session')
@immutable
class NewSessionRoute extends GoRouteData with $NewSessionRoute {
  final String workoutId;

  const NewSessionRoute({required this.workoutId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return TrackerScreen(workoutTemplateId: workoutId);
  }
}

/// Resume session route - continue an existing session
@TypedGoRoute<ResumeSessionRoute>(path: '/session/:sessionId')
@immutable
class ResumeSessionRoute extends GoRouteData with $ResumeSessionRoute {
  final String sessionId;

  const ResumeSessionRoute({required this.sessionId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return TrackerScreen(sessionId: sessionId);
  }
}

/// Workout builder route - create new workout
@TypedGoRoute<WorkoutBuilderRoute>(path: '/workout/builder')
@immutable
class WorkoutBuilderRoute extends GoRouteData with $WorkoutBuilderRoute {
  const WorkoutBuilderRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WorkoutBuilderScreen();
  }
}

/// Edit workout route - edit existing workout
@TypedGoRoute<EditWorkoutRoute>(path: '/workout/builder/:workoutId')
@immutable
class EditWorkoutRoute extends GoRouteData with $EditWorkoutRoute {
  final String workoutId;

  const EditWorkoutRoute({required this.workoutId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WorkoutBuilderScreen(workoutId: workoutId);
  }
}

/// Program builder route - create new program
@TypedGoRoute<ProgramBuilderRoute>(path: '/program/builder')
@immutable
class ProgramBuilderRoute extends GoRouteData with $ProgramBuilderRoute {
  const ProgramBuilderRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProgramBuilderScreen();
  }
}

/// Edit program route - edit existing program
@TypedGoRoute<EditProgramRoute>(path: '/program/builder/:programId')
@immutable
class EditProgramRoute extends GoRouteData with $EditProgramRoute {
  final String programId;

  const EditProgramRoute({required this.programId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProgramBuilderScreen(programId: programId);
  }
}

// =============================================================================
// Router Configuration
// =============================================================================

/// App router configuration using generated type-safe routes
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: $appRoutes,
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);

// =============================================================================
// Navigation Extensions for BuildContext
// =============================================================================

/// Extension for type-safe navigation from BuildContext
extension NavigationExtension on BuildContext {
  /// Navigate to home screen
  void goHome() => const HomeRoute().go(this);

  /// Navigate to profile screen
  void goProfile() => const ProfileRoute().go(this);

  /// Navigate to progress screen
  void goProgress() => const ProgressRoute().go(this);

  /// Navigate to calendar screen
  void goCalendar() => const CalendarRoute().go(this);

  /// Start a new workout session
  void goNewSession({required String workoutId}) =>
      NewSessionRoute(workoutId: workoutId).go(this);

  /// Resume an existing workout session
  void goResumeSession({required String sessionId}) =>
      ResumeSessionRoute(sessionId: sessionId).go(this);

  /// Navigate to workout builder (create new)
  void goWorkoutBuilder() => const WorkoutBuilderRoute().go(this);

  /// Navigate to workout builder (edit existing)
  void goEditWorkout({required String workoutId}) =>
      EditWorkoutRoute(workoutId: workoutId).go(this);

  /// Navigate to program builder (create new)
  void goProgramBuilder() => const ProgramBuilderRoute().go(this);

  /// Navigate to program builder (edit existing)
  void goEditProgram({required String programId}) =>
      EditProgramRoute(programId: programId).go(this);
}
