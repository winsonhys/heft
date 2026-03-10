# Frontend Reference

Detailed reference for hefty_chest. For quick rules, see `hefty_chest/CLAUDE.md`.

## Project Structure

```
hefty_chest/
├── lib/
│   ├── main.dart                         # App entry point
│   ├── app/
│   │   ├── app.dart                      # HeftyChestApp widget
│   │   ├── router.dart                   # Route definitions
│   │   └── router.g.dart                 # Generated router code
│   ├── core/
│   │   ├── client.dart                   # RPC client setup, auth interceptor
│   │   ├── config.dart                   # App configuration
│   │   ├── logging.dart                  # Logger definitions
│   │   └── session_storage.dart          # Local session backup
│   ├── features/                         # Feature modules (9 total)
│   │   ├── auth/providers/
│   │   ├── home/{screen, providers, widgets}
│   │   ├── calendar/
│   │   ├── progress/{screen, providers, widgets}
│   │   ├── profile/{screen, providers, widgets}
│   │   ├── tracker/{screen, models, providers, widgets}
│   │   ├── workout_builder/{screen, providers, widgets}
│   │   ├── program_builder/{screen, providers, widgets}
│   │   └── history/{screens, providers, widgets}
│   ├── shared/
│   │   ├── theme/
│   │   │   ├── app_colors.dart           # Color palette
│   │   │   └── heft_theme.dart           # Custom FTheme
│   │   └── widgets/                      # Reusable widgets
│   │       ├── floating_session_widget.dart
│   │       ├── bottom_nav_bar.dart
│   │       ├── confirm_dialog.dart
│   │       ├── duration_picker.dart
│   │       └── scaffold_with_nav_bar.dart
│   └── gen/                              # Generated proto code (never edit)
├── proto/*.proto                         # Proto definitions
├── test/
│   ├── widgets/                          # Widget unit tests
│   ├── test_utils/                       # Test setup and data helpers
│   └── integration/
│       ├── providers/                    # Provider integration tests
│       └── e2e/                          # End-to-end flow tests
├── pubspec.yaml
├── buf.yaml, buf.gen.yaml
└── analysis_options.yaml
```

## State Management (Riverpod 3.0)

### Provider Types

**Async Provider** — Data fetching:
```dart
@riverpod
Future<List<WorkoutSummary>> workoutList(Ref ref) async {
  final request = ListWorkoutsRequest();
  final response = await workoutClient.listWorkouts(request);
  return response.workouts;
}

// Usage: ref.watch(workoutListProvider).when(loading:, error:, data:)
```

**Notifier Provider** — Mutable state:
```dart
@riverpod
class WorkoutBuilder extends _$WorkoutBuilder {
  @override
  WorkoutBuilderState build() => const WorkoutBuilderState();

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  Future<void> save() async { /* API call */ }
}

// Usage:
// ref.watch(workoutBuilderProvider)
// ref.read(workoutBuilderProvider.notifier).updateName('Leg Day')
```

**Computed Provider** — Derived state:
```dart
@riverpod
List<Exercise> filteredExercises(Ref ref) {
  final exercises = ref.watch(exerciseListProvider).valueOrNull ?? [];
  final query = ref.watch(exerciseSearchQueryProvider);
  if (query.isEmpty) return exercises;
  return exercises.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();
}
```

### Session Models (Freezed)

The tracker uses freezed models for immutable session state:

| Model | Purpose |
|---|---|
| `SessionModel` | Main session with exercises, progress counts |
| `SessionExerciseModel` | Exercise with sets, includes `supersetId` |
| `SessionSetModel` | Individual set: weight, reps, completion |

Location: `lib/features/tracker/models/session_models.dart`

Provides `fromProto()` / `toProto()` for conversion and `copyWith()` for updates.

## Routing (go_router)

### Shell Route Pattern

`TypedStatefulShellRoute` for persistent bottom navigation with 5 branches:
Home, Calendar, Progress, History, Profile.

Each branch maintains its own navigation stack.

### Routes

| Route | Screen | Purpose |
|---|---|---|
| `/` | HomeScreen | Workout list, dashboard |
| `/profile` | ProfileScreen | User settings |
| `/progress` | ProgressScreen | Analytics, PRs |
| `/calendar` | CalendarScreen | Schedule view |
| `/session?workoutId=...` | TrackerScreen | Start new session |
| `/session/:sessionId` | TrackerScreen | Resume session |
| `/workout/builder` | WorkoutBuilderScreen | Create workout |
| `/workout/builder/:workoutId` | WorkoutBuilderScreen | Edit workout |
| `/program/builder` | ProgramBuilderScreen | Create program |
| `/program/builder/:programId` | ProgramBuilderScreen | Edit program |

### Navigation

```dart
context.goHome();
context.goNewSession(workoutId: workout.id);
context.goWorkoutBuilder(workoutId: existingId);
```

## Authentication

### Flow

1. `authClient.login(email)` → JWT token + user ID
2. Token stored in SharedPreferences
3. Token provider set → all API calls include `Authorization: Bearer <token>`
4. Backend validates token, extracts user ID from claims

### Provider Usage

```dart
await ref.read(authProvider.notifier).login(email);
final isAuth = ref.watch(authProvider).isAuthenticated;
final userId = ref.watch(currentUserIdProvider);
await ref.read(authProvider.notifier).logout();
```

### Client Interceptor

```dart
// lib/core/client.dart
Interceptor authInterceptor = <I, O>(next) {
  return (req) async {
    final token = _tokenProvider?.call();
    if (token != null) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    return next(req);
  };
};
```

## RPC Clients

All clients defined in `lib/core/client.dart`:

```dart
final authClient = AuthServiceClient(_transport);
final userClient = UserServiceClient(_transport);
final exerciseClient = ExerciseServiceClient(_transport);
final workoutClient = WorkoutServiceClient(_transport);
final programClient = ProgramServiceClient(_transport);
final sessionClient = SessionServiceClient(_transport);
final progressClient = ProgressServiceClient(_transport);
```

## Styling

### Color Palette (`lib/shared/theme/app_colors.dart`)

```dart
// Backgrounds (dark theme)
bgPrimary    = Color(0xFF0A0E1A)   // Deep navy
bgSecondary  = Color(0xFF111827)   // Dark gray
bgCard       = Color(0xFF151C2C)   // Card background
bgCardInner  = Color(0xFF1A2235)   // Inner card

// Accents
accentBlue   = Color(0xFF4F5FFF)   // Primary
accentGreen  = Color(0xFF22C55E)   // Success
accentRed    = Color(0xFFEF4444)   // Error
accentOrange = Color(0xFFF59E0B)   // Warning
accentPurple = Color(0xFF8B5CF6)   // Purple
accentCyan   = Color(0xFF06B6D4)   // Cyan

// Text
textPrimary   = Color(0xFFFFFFFF)  // White
textSecondary = Color(0xFF9CA3AF)  // Gray
textMuted     = Color(0xFF5A6478)  // Muted

// Border
borderColor    = Color(0xFF2D3548)
supersetBorder = Color(0xFF8B5CF6) // Purple for superset grouping
```

### Theme (`lib/shared/theme/heft_theme.dart`)

Custom dark theme with typography scale (xs through xl8).

```dart
MaterialApp.router(
  builder: (context, child) => FTheme(
    data: heftDarkTheme,
    child: child!,
  ),
)
```

### forui Components

| Widget | Purpose |
|---|---|
| `FButton()` | Primary action |
| `FButton(style: FButtonStyle.ghost())` | Secondary action |
| `FButton(style: FButtonStyle.destructive())` | Danger action |
| `FTextField()` | Text input |
| `FTextField.email()` | Email input |
| `FProgress()` | Loading indicator |
| `FTheme()` | Theme provider |

## Widget Patterns

### ConsumerWidget (Stateless)

```dart
class WorkoutCard extends ConsumerWidget {
  final String workoutId;
  const WorkoutCard({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(workoutProvider(workoutId)).when(
      loading: () => const FProgress(),
      error: (e, st) => Text('Error: $e'),
      data: (data) => Card(child: Text(data.name)),
    );
  }
}
```

### HookConsumerWidget (Stateful)

```dart
class MyScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final isLoading = useState(false);

    useEffect(() {
      // Side effects, returns cleanup function
      return null;
    }, []);

    // Build UI...
  }
}
```

### Common Hooks

| Hook | Replaces | Purpose |
|---|---|---|
| `useTextEditingController()` | TextEditingController + dispose | Text input |
| `useState<T>(initial)` | setState | Local state |
| `useEffect(() => cleanup, [deps])` | initState + dispose | Side effects |
| `useFocusNode()` | FocusNode + dispose | Focus |
| `useMemoized(() => value, [deps])` | late final | Cached computation |

## Loggers

Pre-defined in `lib/core/logging.dart`:

| Logger | Feature |
|---|---|
| `logAuth` | Authentication |
| `logSession` | Workout tracker |
| `logWorkout` | Workout builder |
| `logProgram` | Program builder |
| `logProfile` | Profile/settings |
| `logProgress` | Analytics |
| `logCalendar` | Calendar |
| `logHistory` | Session history |
| `logHome` | Home screen |
| `logStorage` | Local backup |

Format: `[LEVEL] HH:MM:SS.mmm heft.feature: message`
