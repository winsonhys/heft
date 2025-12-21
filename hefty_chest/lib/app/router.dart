import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/auth/providers/auth_providers.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/tracker/tracker_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/history/history_screen.dart';
import '../features/history/session_detail_screen.dart';
import '../features/workout_builder/workout_builder_screen.dart';
import '../features/program_builder/program_builder_screen.dart';
import '../shared/widgets/scaffold_with_nav_bar.dart';

part 'router.g.dart';

// =============================================================================
// Global Navigator Keys
// =============================================================================

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// =============================================================================
// Shell Route (Bottom Navigation with State Preservation)
// =============================================================================

@TypedStatefulShellRoute<MainShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [TypedGoRoute<HomeRoute>(path: '/')],
    ),
    TypedStatefulShellBranch<HistoryBranch>(
      routes: [TypedGoRoute<HistoryRoute>(path: '/history')],
    ),
    TypedStatefulShellBranch<ProgressBranch>(
      routes: [TypedGoRoute<ProgressRoute>(path: '/progress')],
    ),
    TypedStatefulShellBranch<CalendarBranch>(
      routes: [TypedGoRoute<CalendarRoute>(path: '/calendar')],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [TypedGoRoute<ProfileRoute>(path: '/profile')],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return ScaffoldWithNavBar(navigationShell: navigationShell);
  }
}

// Shell Branches
class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class HistoryBranch extends StatefulShellBranchData {
  const HistoryBranch();
}

class ProgressBranch extends StatefulShellBranchData {
  const ProgressBranch();
}

class CalendarBranch extends StatefulShellBranchData {
  const CalendarBranch();
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}

// =============================================================================
// Tab Routes (Inside Shell)
// =============================================================================

/// Home route - main screen with workout list
@immutable
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}

/// History route - completed workout history
@immutable
class HistoryRoute extends GoRouteData with $HistoryRoute {
  const HistoryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HistoryScreen();
  }
}

/// Progress route - analytics dashboard
@immutable
class ProgressRoute extends GoRouteData with $ProgressRoute {
  const ProgressRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProgressScreen();
  }
}

/// Calendar route - workout calendar view
@immutable
class CalendarRoute extends GoRouteData with $CalendarRoute {
  const CalendarRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const CalendarScreen();
  }
}

/// Profile route - user settings and stats
@immutable
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileScreen();
  }
}

// =============================================================================
// Non-Shell Routes (Full Screen, No Bottom Nav)
// =============================================================================

/// Auth route - login screen
@TypedGoRoute<AuthRoute>(path: '/auth')
@immutable
class AuthRoute extends GoRouteData with $AuthRoute {
  const AuthRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AuthScreen();
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

/// History detail route - view completed session details
@TypedGoRoute<HistoryDetailRoute>(path: '/history/:sessionId')
@immutable
class HistoryDetailRoute extends GoRouteData with $HistoryDetailRoute {
  final String sessionId;

  const HistoryDetailRoute({required this.sessionId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SessionDetailScreen(sessionId: sessionId);
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

/// Creates the app router with auth-aware redirect
GoRouter createAppRouter(WidgetRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: $appRoutes,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthPage = state.matchedLocation == '/auth';

      // Still loading auth state - show nothing or a loading indicator
      if (authState.isLoading) {
        return null;
      }

      // Not authenticated and not on auth page -> redirect to auth
      if (!isAuthenticated && !isOnAuthPage) {
        return '/auth';
      }

      // Authenticated and on auth page -> redirect to home
      if (isAuthenticated && isOnAuthPage) {
        return '/';
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}

// =============================================================================
// Navigation Extensions for BuildContext
// =============================================================================

/// Extension for type-safe navigation from BuildContext
extension NavigationExtension on BuildContext {
  /// Navigate to home screen
  void goHome() => const HomeRoute().go(this);

  /// Navigate to history screen
  void goHistory() => const HistoryRoute().go(this);

  /// Navigate to history detail screen
  void goHistoryDetail({required String sessionId}) =>
      HistoryDetailRoute(sessionId: sessionId).push(this);

  /// Navigate to profile screen
  void goProfile() => const ProfileRoute().go(this);

  /// Navigate to progress screen
  void goProgress() => const ProgressRoute().go(this);

  /// Navigate to calendar screen
  void goCalendar() => const CalendarRoute().go(this);

  /// Start a new workout session
  void goNewSession({required String workoutId}) =>
      NewSessionRoute(workoutId: workoutId).push(this);

  /// Resume an existing workout session
  void goResumeSession({required String sessionId}) =>
      ResumeSessionRoute(sessionId: sessionId).push(this);

  /// Navigate to workout builder (create new)
  void goWorkoutBuilder() => const WorkoutBuilderRoute().push(this);

  /// Navigate to workout builder (edit existing)
  void goEditWorkout({required String workoutId}) =>
      EditWorkoutRoute(workoutId: workoutId).push(this);

  /// Navigate to program builder (create new)
  void goProgramBuilder() => const ProgramBuilderRoute().push(this);

  /// Navigate to program builder (edit existing)
  void goEditProgram({required String programId}) =>
      EditProgramRoute(programId: programId).push(this);
}
