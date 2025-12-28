# Hefty Chest - Flutter Frontend

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.10.3+ |
| Language | Dart |
| State Management | Riverpod 3.0 + Flutter Hooks |
| Routing | go_router with code generation |
| UI Components | forui 0.17.0 (FButton, FTextField, FProgress, etc.) |
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
│   ├── features/                    # Feature modules (9 total)
│   │   ├── auth/
│   │   │   └── providers/
│   │   │       └── auth_providers.dart
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
│   │   │   ├── models/
│   │   │   │   └── session_models.dart   # Freezed models for session state
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
│   │   ├── program_builder/
│   │       ├── program_builder_screen.dart
│   │       ├── providers/
│   │       └── widgets/
│   │   └── history/
│   │       ├── history_screen.dart
│   │       ├── session_detail_screen.dart
│   │       ├── providers/
│   │       │   └── history_providers.dart
│   │       └── widgets/
│   ├── shared/
│   │   ├── theme/
│   │   │   ├── app_colors.dart      # Color palette
│   │   │   └── heft_theme.dart      # Custom FTheme with typography
│   │   └── widgets/                 # Reusable widgets
│   │       ├── floating_session_widget.dart  # Active session overlay
│   │       ├── bottom_nav_bar.dart  # Bottom navigation
│   │       ├── confirm_dialog.dart  # FDialog-based confirmation
│   │       ├── duration_picker.dart # Time picker widget
│   │       └── scaffold_with_nav_bar.dart  # Shell route scaffold
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
│   ├── widget_test.dart
│   ├── widgets/                      # Widget unit tests
│   │   ├── floating_session_widget_test.dart
│   │   └── workout_builder_screen_test.dart
│   ├── test_utils/
│   │   ├── test_setup.dart          # Integration test setup & auth
│   │   └── test_data.dart           # Test data helpers
│   └── integration/
│       ├── providers/               # Provider integration tests
│       │   ├── auth_provider_test.dart
│       │   ├── exercise_provider_test.dart
│       │   ├── workout_provider_test.dart
│       │   ├── session_provider_test.dart
│       │   ├── program_provider_test.dart
│       │   ├── progress_provider_test.dart
│       │   └── user_provider_test.dart
│       └── e2e/                     # End-to-end tests
│           ├── workout_flow_test.dart
│           └── session_flow_test.dart
├── scripts/
│   └── run_integration_tests.sh     # Integration test runner
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
│  │ ConsumerWidget  │  │ HookConsumerWidget              │   │
│  │ (stateless)     │  │ (stateful with hooks)           │   │
│  └────────┬────────┘  └────────────────┬────────────────┘   │
│           │ ref.watch                   │ ref.watch/read    │
└───────────┼─────────────────────────────┼───────────────────┘
            ▼                             ▼
┌─────────────────────────────────────────────────────────────┐
│                     Provider Layer (Riverpod)                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │ @riverpod       │  │ @riverpod class │  │ @riverpod   │  │
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
            ▼ Connect-RPC (HTTP/2 native, fetch on web)
┌─────────────────────────────────────────────────────────────┐
│                    Backend (HeftyBack)                       │
└─────────────────────────────────────────────────────────────┘
```

## State Management (Riverpod 3.0 + Code Generation)

All providers use `@riverpod` annotation for code generation. Run `flutter pub run build_runner build` after changes.

### Provider Types

**Async Provider** - Data fetching with `@riverpod`:
```dart
@riverpod
Future<List<WorkoutSummary>> workoutList(Ref ref) async {
  // User ID is extracted from JWT token by backend - no need to pass it
  final request = ListWorkoutsRequest();
  final response = await workoutClient.listWorkouts(request);
  return response.workouts;
}

// Usage in widget (provider name is workoutListProvider)
ref.watch(workoutListProvider).when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
  data: (workouts) => ListView.builder(...),
);
```

**Notifier Provider** - Mutable state with `@riverpod class`:
```dart
@riverpod
class WorkoutBuilder extends _$WorkoutBuilder {
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

// Usage (provider name is workoutBuilderProvider)
ref.watch(workoutBuilderProvider);
ref.read(workoutBuilderProvider.notifier).updateName('Leg Day');
```

**Computed Provider** - Derived state:
```dart
@riverpod
List<Exercise> filteredExercises(Ref ref) {
  final exercises = ref.watch(exerciseListProvider).valueOrNull ?? [];
  final query = ref.watch(exerciseSearchQueryProvider);

  if (query.isEmpty) return exercises;
  return exercises.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();
}
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

### Session Models (Freezed)

The tracker feature uses freezed models for immutable session state:

| Model | Purpose |
|-------|---------|
| `SessionModel` | Main session with exercises, progress counts |
| `SessionExerciseModel` | Exercise within a session with sets, includes `supersetId` |
| `SessionSetModel` | Individual set with weight, reps, completion |

Location: `lib/features/tracker/models/session_models.dart`

**Superset Support:**
- `SessionExerciseModel.supersetId` - UUID grouping exercises in same superset
- Exercises with matching `supersetId` display superset badge in tracker UI
- Uses `AppColors.supersetBorder` for visual grouping

These models provide:
- Immutable state with `copyWith()` for updates
- `fromProto()` to convert from protobuf responses
- `toProto()` to convert back for sync operations

```dart
// Example: Update a set in the session
final updatedSession = session.copyWith(
  exercises: session.exercises.map((exercise) {
    if (exercise.id != targetExerciseId) return exercise;
    return exercise.copyWith(
      sets: exercise.sets.map((set) {
        if (set.id != targetSetId) return set;
        return set.copyWith(completedAt: DateTime.now());
      }).toList(),
    );
  }).toList(),
);
```

## Routing (go_router)

### Shell Route Pattern

The app uses `TypedStatefulShellRoute` for persistent bottom navigation with 5 branches:

```dart
// router.dart
@TypedStatefulShellRoute<MainShellRouteData>(
  branches: [
    TypedStatefulShellBranch<HomeBranchData>(routes: [...]),
    TypedStatefulShellBranch<CalendarBranchData>(routes: [...]),
    TypedStatefulShellBranch<ProgressBranchData>(routes: [...]),
    TypedStatefulShellBranch<HistoryBranchData>(routes: [...]),
    TypedStatefulShellBranch<ProfileBranchData>(routes: [...]),
  ],
)
class MainShellRouteData extends StatefulShellRouteData {
  const MainShellRouteData();

  @override
  Widget builder(context, state, navigationShell) =>
    ScaffoldWithNavBar(navigationShell: navigationShell);
}

// Each branch maintains its own navigation stack
class HomeBranchData extends StatefulShellBranchData {
  const HomeBranchData();
}
```

### Route Definitions

```dart
@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<TrackerRoute>(path: '/tracker')
class TrackerRoute extends GoRouteData {
  final String? workoutId;
  final String? sessionId;
  const TrackerRoute({this.workoutId, this.sessionId});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
    TrackerScreen(workoutId: workoutId, sessionId: sessionId);
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

## Authentication

The app uses JWT-based authentication. The backend validates tokens and extracts user ID from the JWT claims.

### Auth Flow

1. User logs in with email via `authClient.login()`
2. Backend returns JWT token and user ID
3. Token is stored in SharedPreferences
4. Token provider is set so all API calls include `Authorization: Bearer <token>`

### Auth Provider (`lib/features/auth/providers/auth_providers.dart`)

```dart
// Login
final success = await ref.read(authProvider.notifier).login(email);

// Check auth state
final state = ref.watch(authProvider);
if (state.isAuthenticated) {
  // User is logged in
}

// Get current user ID
final userId = ref.watch(currentUserIdProvider);

// Get auth token
final token = ref.watch(authTokenProvider);

// Logout
await ref.read(authProvider.notifier).logout();
```

### Client Auth Interceptor (`lib/core/client.dart`)

The auth interceptor automatically adds JWT token to all requests:

```dart
/// Token provider function - set by auth provider after login
typedef TokenProvider = String? Function();
TokenProvider? _tokenProvider;

void setTokenProvider(TokenProvider provider) {
  _tokenProvider = provider;
}

/// Auth interceptor adds Bearer token to requests
Interceptor authInterceptor = <I extends Object, O extends Object>(next) {
  return (req) async {
    final token = _tokenProvider?.call();
    if (token != null) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    return next(req);
  };
};
```

## API Integration

### Client Setup (lib/core/client.dart)

Uses conditional imports for platform-specific HTTP clients with auth interceptor:

```dart
import 'package:connectrpc/connect.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as protocol;

protocol.Transport createTransport() {
  return protocol.Transport(
    baseUrl: AppConfig.backendUrl,
    codec: const ProtoCodec(),
    httpClient: createHttpClient(),
    interceptors: [authInterceptor],  // Auth interceptor for JWT
  );
}

final _transport = createTransport();

// Service clients
final authClient = AuthServiceClient(_transport);
final userClient = UserServiceClient(_transport);
final exerciseClient = ExerciseServiceClient(_transport);
final workoutClient = WorkoutServiceClient(_transport);
final programClient = ProgramServiceClient(_transport);
final sessionClient = SessionServiceClient(_transport);
final progressClient = ProgressServiceClient(_transport);
```

### Platform-Specific HTTP Files

| File | Platform | HTTP Library |
|------|----------|--------------|
| `http.dart` | Stub | Throws UnimplementedError |
| `http_io.dart` | Native (iOS, Android, macOS) | `connectrpc/http2.dart` |
| `http_web.dart` | Web (Chrome, browsers) | `connectrpc/web.dart` |

### Making API Calls

```dart
// In a provider - user ID is extracted from JWT token by backend
@riverpod
Future<List<WorkoutSummary>> workoutList(Ref ref) async {
  final request = ListWorkoutsRequest()
    ..pagination = (PaginationRequest()..pageSize = 50);

  final response = await workoutClient.listWorkouts(request);
  return response.workouts;
}

// In a notifier - uses freezed SessionModel for immutable state
@riverpod
class ActiveSession extends _$ActiveSession {
  @override
  AsyncValue<SessionModel?> build() => const AsyncValue.data(null);

  Future<SessionModel?> startSession({required String workoutTemplateId}) async {
    state = const AsyncValue.loading();
    try {
      final request = StartSessionRequest()
        ..workoutTemplateId = workoutTemplateId;

      final response = await sessionClient.startSession(request);
      final sessionModel = SessionModel.fromProto(response.session);
      state = AsyncValue.data(sessionModel);
      return sessionModel;
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
  static const accentBlueHover = Color(0xFF6B7AFF); // Blue hover state
  static const accentGreen = Color(0xFF22C55E);    // Success green
  static const accentRed = Color(0xFFEF4444);      // Error red
  static const accentOrange = Color(0xFFF59E0B);   // Warning orange
  static const accentPurple = Color(0xFF8B5CF6);   // Purple accent
  static const accentCyan = Color(0xFF06B6D4);     // Cyan accent

  // Text
  static const textPrimary = Color(0xFFFFFFFF);    // White
  static const textSecondary = Color(0xFF9CA3AF);  // Gray
  static const textMuted = Color(0xFF5A6478);      // Muted gray

  // Border
  static const borderColor = Color(0xFF2D3548);    // Subtle border
  static const supersetBorder = Color(0xFF8B5CF6); // Purple for superset grouping
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

### Custom Theme (`heft_theme.dart`)

Custom dark theme with typography system:

```dart
// lib/shared/theme/heft_theme.dart
final heftDarkTheme = FThemeData(
  colorScheme: FThemes.zinc.dark.colorScheme,
  typography: FTypography(
    xs: TextStyle(fontSize: 12, ...),   // Smallest
    sm: TextStyle(fontSize: 14, ...),   // Small
    base: TextStyle(fontSize: 16, ...),  // Default
    lg: TextStyle(fontSize: 18, ...),   // Large
    xl: TextStyle(fontSize: 20, ...),   // Extra large
    xl2: TextStyle(fontSize: 24, ...),  // 2XL
    // ... up to xl8
  ),
);
```

### forui Components

forui provides a consistent design system for the app. Set up the theme in app.dart:

```dart
import 'package:forui/forui.dart';
import 'package:hefty_chest/shared/theme/heft_theme.dart';

// Theme setup in app.dart
MaterialApp.router(
  builder: (context, child) => FTheme(
    data: heftDarkTheme,  // Custom dark theme
    child: child!,
  ),
  routerConfig: _router,
)
```

**Button Styles:**
```dart
// Primary button (default)
FButton(
  onPress: () => startWorkout(),
  child: const Text('Start Workout'),
)

// Ghost button (transparent background)
FButton(
  style: FButtonStyle.ghost(),
  onPress: () => Navigator.pop(context),
  child: const Text('Cancel'),
)

// Destructive button (red, for delete actions)
FButton(
  style: FButtonStyle.destructive(),
  onPress: () => deleteWorkout(),
  child: const Text('Delete'),
)
```

**Text Fields:**
```dart
// Email input with validation
FTextField.email(
  controller: emailController,
  label: const Text('Email'),
  hint: 'Enter your email',
)

// Standard text field
FTextField(
  controller: nameController,
  label: const Text('Workout Name'),
)
```

**Progress Indicator:**
```dart
// Loading spinner
FProgress()

// Usage in async data
workoutsAsync.when(
  loading: () => const Center(child: FProgress()),
  error: (error, _) => Text('Error: $error'),
  data: (workouts) => ListView.builder(...),
)
```

**Common forui Widgets:**

| Widget | Purpose | Example Usage |
|--------|---------|---------------|
| `FButton` | Primary actions | Start workout, Submit form |
| `FButton.ghost()` | Secondary actions | Cancel, Back |
| `FButton.destructive()` | Dangerous actions | Delete, Remove |
| `FTextField` | Text input | Names, descriptions |
| `FTextField.email()` | Email input | Login, registration |
| `FProgress` | Loading indicator | Async operations |
| `FTheme` | Theme provider | App-wide theming |

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

# Test (unit tests only)
flutter test

# Analyze
flutter analyze

# Integration tests (requires Docker)
./scripts/run_integration_tests.sh
```

## Testing

### Integration Tests

Integration tests run against a real backend in TEST_MODE. The test script handles:
1. Starting PostgreSQL and backend via Docker Compose
2. Waiting for services to be healthy
3. Running tests with authentication
4. Cleaning up containers

```bash
# Run all integration tests
./scripts/run_integration_tests.sh
```

### Test Setup (`test/test_utils/test_setup.dart`)

```dart
// In setUpAll() of integration tests:
setUpAll(() async {
  await IntegrationTestSetup.waitForBackend();
  await IntegrationTestSetup.resetDatabase();
  await IntegrationTestSetup.authenticateTestUser();
});

// Create test container
final container = IntegrationTestSetup.createContainer();

// Get authenticated test user ID
final userId = IntegrationTestSetup.testUserId;
```

### Test Data Helpers (`test/test_utils/test_data.dart`)

```dart
// Create test workout
final workoutId = await TestData.createTestWorkout(name: 'Test Workout');

// Create workout with exercise
final workoutId = await TestData.createWorkoutWithExercise();

// Start session
final sessionId = await TestData.startSession(workoutTemplateId: workoutId);

// Clean up
await TestData.deleteWorkout(workoutId);
await TestData.abandonSession(sessionId);
```

### Test Structure

```
test/
├── test_utils/
│   ├── test_setup.dart     # Backend setup, auth helpers
│   └── test_data.dart      # Data creation/cleanup helpers
└── integration/
    ├── providers/          # Test each provider against real API
    │   ├── auth_provider_test.dart
    │   ├── exercise_provider_test.dart
    │   ├── workout_provider_test.dart
    │   ├── session_provider_test.dart
    │   ├── program_provider_test.dart
    │   ├── progress_provider_test.dart
    │   └── user_provider_test.dart
    └── e2e/                # Full user flow tests
        ├── workout_flow_test.dart
        └── session_flow_test.dart
```

## Configuration (lib/core/config.dart)

```dart
class AppConfig {
  AppConfig._();

  /// Backend API base URL
  static const String backendUrl = 'http://localhost:8080';

  /// Default rest timer duration in seconds
  static const int defaultRestTimerSeconds = 90;
}
```

Note: User ID is no longer hardcoded. The backend extracts user ID from the JWT token on each request.

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

Use `@riverpod` annotation (requires `part` directive and code generation):

```dart
// In feature_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'feature_providers.g.dart';

// Simple async data - user ID extracted from JWT by backend
@riverpod
Future<MyData> myData(Ref ref) async {
  final response = await myClient.getData(MyRequest());
  return response.data;
}

// Complex mutable state
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyState build() => const MyState();

  void doSomething() {
    state = state.copyWith(/* changes */);
  }
}
```

Then run: `flutter pub run build_runner build --delete-conflicting-outputs`

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

### HookConsumerWidget (Stateful with Hooks)

Uses `flutter_hooks` for cleaner state management - no `dispose()` needed:

```dart
class WorkoutBuilderScreen extends HookConsumerWidget {
  final String? workoutId;

  const WorkoutBuilderScreen({super.key, this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks auto-dispose resources
    final nameController = useTextEditingController();
    final isLoading = useState(false);
    final state = ref.watch(workoutBuilderProvider);

    // useEffect replaces initState
    useEffect(() {
      if (workoutId != null) {
        isLoading.value = true;
        ref.read(workoutBuilderProvider.notifier).loadWorkout(workoutId!).then((_) {
          nameController.text = ref.read(workoutBuilderProvider).name;
          isLoading.value = false;
        });
      }
      return null;
    }, [workoutId]);

    // Build UI...
  }
}
```

### Common Hooks

| Hook | Replaces | Purpose |
|------|----------|---------|
| `useTextEditingController()` | `TextEditingController` + `dispose()` | Text input controller |
| `useState<T>(initial)` | `setState()` | Local state |
| `useEffect(() => cleanup, [deps])` | `initState()` + `dispose()` | Side effects |
| `useFocusNode()` | `FocusNode` + `dispose()` | Focus management |
| `useMemoized(() => value, [deps])` | `late final` | Cached computation |

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
