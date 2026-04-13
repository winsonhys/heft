# Hefty Chest — Frontend Harness

Flutter mobile app. Riverpod state management, forui components, Connect-RPC client.

## Boundary Rules

Non-negotiable. Violations are bugs.

- **Features** (`lib/features/*/`) → Self-contained modules. Each owns its screen, providers, widgets. Never import from another feature.
- **Shared** (`lib/shared/`) → Reusable widgets and theme. Never import from features.
- **Core** (`lib/core/`) → RPC clients, config, logging. Never import from features or shared.
- **Generated code** (`lib/gen/`) → Never hand-edit. Regenerate: `buf generate`.
- **App** (`lib/app/`) → Router and app widget only. Imports from features for screen references.

Dependency flow: `gen → core → shared → features → app`

## File Map

| Need to... | Look at |
|---|---|
| Add a feature screen | `lib/features/{name}/{name}_screen.dart` |
| Add/modify providers | `lib/features/{name}/providers/{name}_providers.dart` |
| Add feature widgets | `lib/features/{name}/widgets/` |
| Add shared widgets | `lib/shared/widgets/` |
| Modify theme/colors | `lib/shared/theme/app_colors.dart`, `heft_theme.dart` |
| Add/modify routes | `lib/app/router.dart` → run `build_runner` |
| Change RPC clients | `lib/core/client.dart` |
| Change proto schema | `proto/*.proto` → `buf generate` |
| Modify app config | `lib/core/config.dart` |
| Add a logger | `lib/core/logging.dart` |

## State — Mechanical Rule

ALL state updates use `copyWith()`. Never mutate directly.

```dart
// CORRECT
state = state.copyWith(name: newName);

// WRONG — will not trigger rebuilds
state.name = newName;
```

## Providers — Mechanical Rule

ALL providers use `@riverpod` annotation with code generation.

```dart
// Async data
@riverpod
Future<List<Data>> myData(Ref ref) async {
  final response = await myClient.getData(MyRequest());
  return response.items;
}

// Mutable state
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyState build() => const MyState();

  void update(String value) {
    state = state.copyWith(field: value);
  }
}
```

After changes: `flutter pub run build_runner build --delete-conflicting-outputs`

## UI — Mechanical Rule

Use forui components. Use `AppColors` constants. No hardcoded colors.

```dart
// CORRECT
FButton(onPress: () => action(), child: const Text('Label'))
Container(color: AppColors.bgCard)

// WRONG
ElevatedButton(onPressed: ...)          // Don't use raw Material buttons
Container(color: Color(0xFF151C2C))     // Don't hardcode colors
```

Button styles: `FButton()` (primary) | `FButton(style: FButtonStyle.ghost())` (secondary) | `FButton(style: FButtonStyle.destructive())` (danger)

## Auth — Mechanical Rule

Never send user_id in requests. Backend extracts from JWT.

```dart
// CORRECT
final request = ListWorkoutsRequest()..pagination = pagination;

// WRONG
final request = ListWorkoutsRequest()..userId = currentUserId;
```

## Navigation After Async — Mechanical Rule

After an async save/create operation, use `context.go()` instead of `context.pop()`. GoRouter `pop()` can trigger route lifecycle assertions when the previous route's state has been invalidated by the async operation.

```dart
// CORRECT — explicit navigation avoids lifecycle issues
await saveWorkout();
if (context.mounted) context.go('/');

// WRONG — pop() hits route lifecycle assertion after async
await saveWorkout();
if (context.mounted) context.pop();
```

## Widget Patterns — Quick Reference

```dart
// Stateless with Riverpod
class MyWidget extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(myProvider).when(
      loading: () => const FProgress(),
      error: (e, st) => Text('Error: $e'),
      data: (data) => /* build UI */,
    );
  }
}

// Stateful with Hooks
class MyScreen extends HookConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final isLoading = useState(false);
    // ...
  }
}
```

## E2E Testing — Quick Reference

Keys: `workout_builder_save`, `program_builder_save`, `program_builder_start_date`, `program_builder_duration`, `program_builder_add_workout`, `workout_schedule_save`, `workout_schedule_weekday_{mon..sun}`, `workout_row_<i>`, `calendar_day_<YYYY-MM-DD>`, `tracker_discard`, `tracker_finish`, `tracker_back`, `workout_card_start`, `workout_card_edit`, `home_fab`, `calendar_add_program`

Test helpers: `test/test_utils/test_helpers.dart` — `safeTap()`, `tapByKey()`, `tapOffScreen()`, `waitForWidget()`

Rules: See `test/e2e/CLAUDE.md` for full harness engineering rules.

## Commands

```bash
flutter pub get                   # Install dependencies
buf generate                      # Regenerate proto code
flutter run                       # Run app
flutter run -d chrome             # Run on web
flutter test                      # Run tests
../run_e2e_tests.sh               # E2E tests (Docker + backend)
flutter analyze                   # Static analysis
flutter pub run build_runner build --delete-conflicting-outputs  # Regenerate providers/router
```

## Deep Reference

- Full frontend patterns, state management, routing, styling: `docs/frontend.md`
- Testing infrastructure and patterns: `docs/testing.md`
- Architecture layers and data flow: `docs/architecture.md`
- Code conventions: `docs/conventions.md`
