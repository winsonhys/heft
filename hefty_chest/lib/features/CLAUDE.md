# Features Layer

Each feature is a self-contained module. Never import from another feature.

## Structure

```
{feature}/
├── {feature}_screen.dart              # Main screen widget
├── providers/
│   └── {feature}_providers.dart       # @riverpod providers
├── models/                            # Optional: freezed models
│   └── {feature}_models.dart
└── widgets/
    └── {widget_name}.dart             # Feature-specific widgets
```

## Provider Rules

ALL providers use `@riverpod` annotation. Run `build_runner` after changes.

```dart
// Async data — generated name: myDataProvider
@riverpod
Future<List<Data>> myData(Ref ref) async {
  final response = await myClient.getData(MyRequest());
  return response.items;
}

// Mutable state — generated name: myNotifierProvider
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyState build() => const MyState();

  void update(String value) {
    state = state.copyWith(field: value);  // ALWAYS copyWith, never mutate
  }
}
```

## Screen Rules

- Use `HookConsumerWidget` when you need hooks (controllers, useState, useEffect)
- Use `ConsumerWidget` for simple data-binding screens
- Handle async: `ref.watch(provider).when(loading:, error:, data:)`
- Navigate: `context.goHome()`, `context.goNewSession(workoutId: id)`
- Colors: `AppColors.*` constants only. No hardcoded `Color(0xFF...)`
- Buttons: `FButton`, `FButton(style: FButtonStyle.ghost())`, `FButton(style: FButtonStyle.destructive())`

## Cross-Feature Invalidation

After mutations, invalidate dependent providers:
- Session changes → `ref.invalidate(progressStatsProvider)`, `ref.invalidate(weeklyActivityProvider)`
- Workout saves → `ref.invalidate(workoutListProvider)`
- Cleanup → `ref.onDispose(() => timer?.cancel())`

## Allowed Imports

- `lib/core/*` (clients, config, logging)
- `lib/shared/*` (theme, reusable widgets)
- `lib/gen/*` (proto types)
- NEVER import from another feature
