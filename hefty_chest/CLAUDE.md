# Hefty Chest - Flutter Frontend

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.10.3+ |
| Language | Dart |
| State Management | Riverpod 3.0 + Flutter Hooks |
| Routing | go_router with code generation |
| UI Components | shadcn_flutter |
| API Client | Connect-RPC |
| Charts | fl_chart |

## Project Structure

```
hefty_chest/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app/
│   │   ├── app.dart                 # HeftyChestApp widget
│   │   ├── router.dart              # Route definitions
│   │   └── router.g.dart            # Generated router code
│   ├── core/
│   │   ├── client.dart              # RPC client setup & exports
│   │   └── config.dart              # App configuration
│   ├── features/                    # Feature modules (7 total)
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── providers/
│   │   │   │   └── home_providers.dart
│   │   │   └── widgets/
│   │   │       ├── workout_card.dart
│   │   │       └── quick_stats_row.dart
│   │   ├── calendar/
│   │   │   └── calendar_screen.dart
│   │   ├── progress/
│   │   │   ├── progress_screen.dart
│   │   │   ├── providers/
│   │   │   └── widgets/
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   ├── providers/
│   │   │   └── widgets/
│   │   ├── tracker/
│   │   │   ├── tracker_screen.dart
│   │   │   ├── providers/
│   │   │   │   └── session_providers.dart
│   │   │   └── widgets/
│   │   │       ├── exercise_card.dart
│   │   │       ├── set_row.dart
│   │   │       ├── rest_timer_sheet.dart
│   │   │       └── progress_header.dart
│   │   ├── workout_builder/
│   │   │   ├── workout_builder_screen.dart
│   │   │   ├── providers/
│   │   │   │   └── workout_builder_providers.dart
│   │   │   └── widgets/
│   │   │       ├── section_card.dart
│   │   │       ├── exercise_item.dart
│   │   │       ├── set_row_editor.dart
│   │   │       └── exercise_search_modal.dart
│   │   └── program_builder/
│   │       ├── program_builder_screen.dart
│   │       ├── providers/
│   │       └── widgets/
│   ├── shared/
│   │   ├── theme/
│   │   │   └── app_colors.dart      # Color palette
│   │   └── widgets/                 # Reusable widgets
│   └── gen/                         # Generated proto code
│       ├── *.pb.dart               # Message types
│       ├── *.pbenum.dart           # Enums
│       └── *.connect.client.dart   # RPC clients
├── proto/                           # Proto definitions
│   ├── common.proto
│   ├── user.proto
│   ├── exercise.proto
│   ├── workout.proto
│   ├── program.proto
│   ├── session.proto
│   └── progress.proto
├── test/
│   └── widget_test.dart
├── pubspec.yaml
├── buf.yaml
├── buf.gen.yaml
└── analysis_options.yaml
```

## Architecture

### Feature-First Modular Architecture

Each feature is self-contained:
```
feature_name/
├── feature_screen.dart      # Main screen widget
├── providers/               # State management
│   └── feature_providers.dart
└── widgets/                 # Feature-specific widgets
    ├── widget_a.dart
    └── widget_b.dart
```

### Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
│  ┌─────────────────┐  ┌─────────────────────────────────┐   │
│  │ ConsumerWidget  │  │ ConsumerStatefulWidget          │   │
│  │ (stateless)     │  │ (stateful)                      │   │
│  └────────┬────────┘  └────────────────┬────────────────┘   │
│           │ ref.watch                   │ ref.watch/read    │
└───────────┼─────────────────────────────┼───────────────────┘
            ▼                             ▼
┌─────────────────────────────────────────────────────────────┐
│                     Provider Layer (Riverpod)                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │ FutureProvider  │  │ NotifierProvider│  │  Provider   │  │
│  │ (async data)    │  │ (mutable state) │  │ (computed)  │  │
│  └────────┬────────┘  └────────┬────────┘  └─────────────┘  │
│           │                     │                            │
└───────────┼─────────────────────┼────────────────────────────┘
            ▼                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Layer (Connect-RPC)                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  userClient │ exerciseClient │ workoutClient │ ...   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
            │
            ▼ HTTP/2 + Protobuf
┌─────────────────────────────────────────────────────────────┐
│                    Backend (HeftyBack)                       │
└─────────────────────────────────────────────────────────────┘
```

## State Management (Riverpod 3.0)

### Provider Types

**FutureProvider** - Async data fetching:
```dart
final workoutListProvider = FutureProvider<List<WorkoutSummary>>((ref) async {
  final request = ListWorkoutsRequest()..userId = AppConfig.hardcodedUserId;
  final response = await workoutClient.listWorkouts(request);
  return response.workouts;
});

// Usage in widget
ref.watch(workoutListProvider).when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
  data: (workouts) => ListView.builder(...),
);
```

**NotifierProvider** - Mutable state with business logic:
```dart
class WorkoutBuilderNotifier extends Notifier<WorkoutBuilderState> {
  @override
  WorkoutBuilderState build() => const WorkoutBuilderState();

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void addSection() {
    final newSection = BuilderSection(id: const Uuid().v4(), name: 'New Section');
    state = state.copyWith(sections: [...state.sections, newSection]);
  }

  Future<void> save() async {
    // API call to save workout
  }
}

final workoutBuilderProvider = NotifierProvider<WorkoutBuilderNotifier, WorkoutBuilderState>(
  () => WorkoutBuilderNotifier(),
);
```

**Provider** - Computed/derived state:
```dart
final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final exercises = ref.watch(exerciseListProvider).valueOrNull ?? [];
  final query = ref.watch(exerciseSearchQueryProvider);

  if (query.isEmpty) return exercises;
  return exercises.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();
});
```

### Immutable State Pattern

```dart
class WorkoutBuilderState {
  final String? id;
  final String name;
  final String description;
  final List<BuilderSection> sections;
  final bool isLoading;

  const WorkoutBuilderState({
    this.id,
    this.name = '',
    this.description = '',
    this.sections = const [],
    this.isLoading = false,
  });

  WorkoutBuilderState copyWith({
    String? id,
    String? name,
    String? description,
    List<BuilderSection>? sections,
    bool? isLoading,
  }) {
    return WorkoutBuilderState(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sections: sections ?? this.sections,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
```

## Routing (go_router)

### Route Definitions

```dart
// router.dart
@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ProfileScreen();
}

@TypedGoRoute<NewSessionRoute>(path: '/session')
class NewSessionRoute extends GoRouteData {
  final String workoutId;
  const NewSessionRoute({required this.workoutId});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
    TrackerScreen(workoutId: workoutId);
}

@TypedGoRoute<ResumeSessionRoute>(path: '/session/:sessionId')
class ResumeSessionRoute extends GoRouteData {
  final String sessionId;
  const ResumeSessionRoute({required this.sessionId});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
    TrackerScreen(sessionId: sessionId);
}
```

### Routes Overview

| Route | Screen | Purpose |
|-------|--------|---------|
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

### Navigation Extensions

```dart
extension NavigationExtension on BuildContext {
  void goHome() => const HomeRoute().go(this);
  void goProfile() => const ProfileRoute().go(this);
  void goProgress() => const ProgressRoute().go(this);
  void goCalendar() => const CalendarRoute().go(this);
  void goNewSession({required String workoutId}) =>
    NewSessionRoute(workoutId: workoutId).go(this);
  void goResumeSession({required String sessionId}) =>
    ResumeSessionRoute(sessionId: sessionId).go(this);
  void goWorkoutBuilder({String? workoutId}) =>
    workoutId != null
      ? EditWorkoutRoute(workoutId: workoutId).go(this)
      : const NewWorkoutRoute().go(this);
}

// Usage
ElevatedButton(
  onPressed: () => context.goNewSession(workoutId: workout.id),
  child: Text('Start Workout'),
)
```

## API Integration

### Client Setup (lib/core/client.dart)

```dart
import 'package:connectrpc/connect.dart' as protocol;
import 'package:connectrpc/protobuf.dart';
import '../gen/user.connect.client.dart';
import '../gen/exercise.connect.client.dart';
// ...

protocol.Transport createTransport() {
  return protocol.Transport(
    baseUrl: AppConfig.backendUrl,  // http://localhost:8080
    codec: const ProtoCodec(),
    httpClient: createHttpClient(),
  );
}

final _transport = createTransport();

// Service clients
final userClient = UserServiceClient(_transport);
final exerciseClient = ExerciseServiceClient(_transport);
final workoutClient = WorkoutServiceClient(_transport);
final programClient = ProgramServiceClient(_transport);
final sessionClient = SessionServiceClient(_transport);
final progressClient = ProgressServiceClient(_transport);

// Re-export common types for convenience
export '../gen/user.pb.dart';
export '../gen/exercise.pb.dart';
export '../gen/workout.pb.dart';
// ...
```

### Making API Calls

```dart
// In a provider
final workoutListProvider = FutureProvider<List<WorkoutSummary>>((ref) async {
  final request = ListWorkoutsRequest()
    ..userId = AppConfig.hardcodedUserId
    ..pagination = (PaginationRequest()..pageSize = 50);

  final response = await workoutClient.listWorkouts(request);
  return response.workouts;
});

// In a notifier
class ActiveSessionNotifier extends Notifier<AsyncValue<Session?>> {
  Future<Session?> startSession({required String workoutTemplateId}) async {
    state = const AsyncValue.loading();
    try {
      final request = StartSessionRequest()
        ..userId = AppConfig.hardcodedUserId
        ..workoutTemplateId = workoutTemplateId;

      final response = await sessionClient.startSession(request);
      state = AsyncValue.data(response.session);
      return response.session;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}
```

## Styling

### Color Palette (lib/shared/theme/app_colors.dart)

```dart
class AppColors {
  // Backgrounds (dark theme)
  static const bgPrimary = Color(0xFF0A0E1A);      // Deep navy
  static const bgSecondary = Color(0xFF111827);    // Dark gray
  static const bgCard = Color(0xFF151C2C);         // Card background
  static const bgCardInner = Color(0xFF1A2235);    // Inner card

  // Accents
  static const accentBlue = Color(0xFF4F5FFF);     // Primary blue
  static const accentGreen = Color(0xFF22C55E);    // Success green
  static const accentRed = Color(0xFFEF4444);      // Error red
  static const accentOrange = Color(0xFFF59E0B);   // Warning orange

  // Text
  static const textPrimary = Color(0xFFFFFFFF);    // White
  static const textSecondary = Color(0xFF9CA3AF);  // Gray
  static const textMuted = Color(0xFF5A6478);      // Muted gray

  // Border
  static const borderColor = Color(0xFF2D3548);    // Subtle border
}
```

### Usage in Widgets

```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.bgCard,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.borderColor),
  ),
  child: Text(
    'Workout Name',
    style: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

### shadcn_flutter Components

```dart
import 'package:shadcn_flutter/shadcn_flutter.dart';

// Buttons
PrimaryButton(
  onPressed: () {},
  child: Text('Start Workout'),
)

// Cards
Card(
  child: Column(
    children: [
      CardHeader(title: Text('My Workout')),
      CardContent(child: ...),
    ],
  ),
)

// Inputs
TextField(
  placeholder: Text('Enter workout name'),
  onChanged: (value) => ref.read(workoutBuilderProvider.notifier).updateName(value),
)
```

## Commands

```bash
# Install dependencies
flutter pub get

# Generate proto code
buf generate

# Generate router code (after changing routes)
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run                    # Default device
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run -d ios             # iOS simulator

# Build
flutter build apk              # Android APK
flutter build appbundle        # Android App Bundle
flutter build ios              # iOS
flutter build web              # Web
flutter build macos            # macOS

# Test
flutter test

# Analyze
flutter analyze
```

## Configuration (lib/core/config.dart)

```dart
class AppConfig {
  AppConfig._();

  /// Backend API base URL
  static const String backendUrl = 'http://localhost:8080';

  /// Hardcoded user ID for MVP (matches seed data)
  static const String hardcodedUserId = '00000000-0000-0000-0000-000000000001';

  /// Default rest timer duration in seconds
  static const int defaultRestTimerSeconds = 90;
}
```

## Common Tasks

### Add New Feature Screen

1. Create feature folder:
```
lib/features/new_feature/
├── new_feature_screen.dart
├── providers/
│   └── new_feature_providers.dart
└── widgets/
    └── (feature-specific widgets)
```

2. Create screen widget:
```dart
class NewFeatureScreen extends ConsumerWidget {
  const NewFeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: // ...
      ),
    );
  }
}
```

3. Create providers:
```dart
final newFeatureDataProvider = FutureProvider<Data>((ref) async {
  // Fetch data
});
```

4. Add route in `lib/app/router.dart`:
```dart
@TypedGoRoute<NewFeatureRoute>(path: '/new-feature')
class NewFeatureRoute extends GoRouteData {
  const NewFeatureRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
    const NewFeatureScreen();
}
```

5. Regenerate router: `flutter pub run build_runner build --delete-conflicting-outputs`

### Add New Provider

```dart
// Simple async data
final myDataProvider = FutureProvider<MyData>((ref) async {
  final response = await myClient.getData(MyRequest()..userId = AppConfig.hardcodedUserId);
  return response.data;
});

// Complex mutable state
class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => const MyState();

  void doSomething() {
    state = state.copyWith(/* changes */);
  }
}

final myProvider = NotifierProvider<MyNotifier, MyState>(() => MyNotifier());
```

### Update Proto Schema

1. Edit `.proto` file in `proto/` folder
2. Run `buf generate`
3. Update providers/widgets to use new fields
4. Also update backend proto file and regenerate

## Widget Patterns

### ConsumerWidget (Stateless)

```dart
class WorkoutCard extends ConsumerWidget {
  final String workoutId;

  const WorkoutCard({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutProvider(workoutId));

    return workout.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text('Error: $e'),
      data: (data) => Card(
        child: Text(data.name),
      ),
    );
  }
}
```

### ConsumerStatefulWidget (Stateful)

```dart
class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  final String? workoutId;

  const WorkoutBuilderScreen({super.key, this.workoutId});

  @override
  ConsumerState<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.workoutId != null) {
      // Load existing workout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(workoutBuilderProvider.notifier).loadWorkout(widget.workoutId!);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutBuilderProvider);
    // ...
  }
}
```

### Modal Bottom Sheet

```dart
void showExerciseSearchModal(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => ExerciseSearchModal(
        scrollController: scrollController,
        onSelect: (exercise) {
          ref.read(workoutBuilderProvider.notifier).addExercise(exercise);
          Navigator.pop(context);
        },
      ),
    ),
  );
}
```
