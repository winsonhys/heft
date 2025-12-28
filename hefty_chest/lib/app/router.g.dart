// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $mainShellRoute,
  $authRoute,
  $newSessionRoute,
  $resumeSessionRoute,
  $emptySessionRoute,
  $historyDetailRoute,
  $workoutBuilderRoute,
  $editWorkoutRoute,
  $programBuilderRoute,
  $editProgramRoute,
];

RouteBase get $mainShellRoute => StatefulShellRouteData.$route(
  factory: $MainShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [GoRouteData.$route(path: '/', factory: $HomeRoute._fromState)],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(path: '/history', factory: $HistoryRoute._fromState),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/progress',
          factory: $ProgressRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/calendar',
          factory: $CalendarRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(path: '/profile', factory: $ProfileRoute._fromState),
      ],
    ),
  ],
);

extension $MainShellRouteExtension on MainShellRoute {
  static MainShellRoute _fromState(GoRouterState state) =>
      const MainShellRoute();
}

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $HistoryRoute on GoRouteData {
  static HistoryRoute _fromState(GoRouterState state) => const HistoryRoute();

  @override
  String get location => GoRouteData.$location('/history');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProgressRoute on GoRouteData {
  static ProgressRoute _fromState(GoRouterState state) => const ProgressRoute();

  @override
  String get location => GoRouteData.$location('/progress');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CalendarRoute on GoRouteData {
  static CalendarRoute _fromState(GoRouterState state) => const CalendarRoute();

  @override
  String get location => GoRouteData.$location('/calendar');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $authRoute =>
    GoRouteData.$route(path: '/auth', factory: $AuthRoute._fromState);

mixin $AuthRoute on GoRouteData {
  static AuthRoute _fromState(GoRouterState state) => const AuthRoute();

  @override
  String get location => GoRouteData.$location('/auth');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $newSessionRoute =>
    GoRouteData.$route(path: '/session', factory: $NewSessionRoute._fromState);

mixin $NewSessionRoute on GoRouteData {
  static NewSessionRoute _fromState(GoRouterState state) =>
      NewSessionRoute(workoutId: state.uri.queryParameters['workout-id']!);

  NewSessionRoute get _self => this as NewSessionRoute;

  @override
  String get location => GoRouteData.$location(
    '/session',
    queryParams: {'workout-id': _self.workoutId},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $resumeSessionRoute => GoRouteData.$route(
  path: '/session/:sessionId',
  factory: $ResumeSessionRoute._fromState,
);

mixin $ResumeSessionRoute on GoRouteData {
  static ResumeSessionRoute _fromState(GoRouterState state) =>
      ResumeSessionRoute(sessionId: state.pathParameters['sessionId']!);

  ResumeSessionRoute get _self => this as ResumeSessionRoute;

  @override
  String get location =>
      GoRouteData.$location('/session/${Uri.encodeComponent(_self.sessionId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $emptySessionRoute => GoRouteData.$route(
  path: '/session/empty',
  factory: $EmptySessionRoute._fromState,
);

mixin $EmptySessionRoute on GoRouteData {
  static EmptySessionRoute _fromState(GoRouterState state) =>
      const EmptySessionRoute();

  @override
  String get location => GoRouteData.$location('/session/empty');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $historyDetailRoute => GoRouteData.$route(
  path: '/history/:sessionId',
  factory: $HistoryDetailRoute._fromState,
);

mixin $HistoryDetailRoute on GoRouteData {
  static HistoryDetailRoute _fromState(GoRouterState state) =>
      HistoryDetailRoute(sessionId: state.pathParameters['sessionId']!);

  HistoryDetailRoute get _self => this as HistoryDetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/history/${Uri.encodeComponent(_self.sessionId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $workoutBuilderRoute => GoRouteData.$route(
  path: '/workout/builder',
  factory: $WorkoutBuilderRoute._fromState,
);

mixin $WorkoutBuilderRoute on GoRouteData {
  static WorkoutBuilderRoute _fromState(GoRouterState state) =>
      const WorkoutBuilderRoute();

  @override
  String get location => GoRouteData.$location('/workout/builder');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $editWorkoutRoute => GoRouteData.$route(
  path: '/workout/builder/:workoutId',
  factory: $EditWorkoutRoute._fromState,
);

mixin $EditWorkoutRoute on GoRouteData {
  static EditWorkoutRoute _fromState(GoRouterState state) =>
      EditWorkoutRoute(workoutId: state.pathParameters['workoutId']!);

  EditWorkoutRoute get _self => this as EditWorkoutRoute;

  @override
  String get location => GoRouteData.$location(
    '/workout/builder/${Uri.encodeComponent(_self.workoutId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $programBuilderRoute => GoRouteData.$route(
  path: '/program/builder',
  factory: $ProgramBuilderRoute._fromState,
);

mixin $ProgramBuilderRoute on GoRouteData {
  static ProgramBuilderRoute _fromState(GoRouterState state) =>
      const ProgramBuilderRoute();

  @override
  String get location => GoRouteData.$location('/program/builder');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $editProgramRoute => GoRouteData.$route(
  path: '/program/builder/:programId',
  factory: $EditProgramRoute._fromState,
);

mixin $EditProgramRoute on GoRouteData {
  static EditProgramRoute _fromState(GoRouterState state) =>
      EditProgramRoute(programId: state.pathParameters['programId']!);

  EditProgramRoute get _self => this as EditProgramRoute;

  @override
  String get location => GoRouteData.$location(
    '/program/builder/${Uri.encodeComponent(_self.programId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
