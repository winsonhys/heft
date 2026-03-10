# App Layer

Router configuration and app widget. Top of the dependency tree.

## Router (router.dart)

Uses `go_router` with `TypedGoRoute` code generation.

```dart
@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}
```

After any route changes: `flutter pub run build_runner build --delete-conflicting-outputs`

## Shell Route

`StatefulShellRoute` for bottom navigation. 5 branches: Home, Calendar, Progress, History, Profile. Each branch preserves its navigation stack.

## Auth Redirect

`createAppRouter()` checks `authProvider` and redirects unauthenticated users.

## Navigation Extensions

Type-safe navigation via BuildContext extensions:

```dart
context.goHome();
context.goNewSession(workoutId: id);
context.goWorkoutBuilder(workoutId: existingId);
```

## Rules

- Route classes go in `router.dart`, not in feature files
- Always regenerate `router.g.dart` after changes
- Never hand-edit `router.g.dart`
- Import feature screens for route `build()` methods — this is the only layer that imports features
