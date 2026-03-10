# Coding Conventions

**Analysis Date:** 2026-03-10

## Naming Patterns

### Go Backend

**Files:**
- Service handlers: `{service_name}_handler.go` (e.g., `user.go`, `workout.go`)
- Repository implementations: `{entity_name}.go` (e.g., `user.go`, `session.go`)
- Test files: `{file_name}_test.go` (e.g., `user_test.go`) or `handlers_test.go` for packages
- Middleware: `{middleware_name}.go` (e.g., `auth.go`, `logging.go`)

**Functions & Methods:**
- PascalCase for exported functions: `NewUserHandler()`, `GetProfile()`, `UpdateSettings()`
- camelCase for unexported functions: `isUserFKViolation()`, `handleDBError()`
- Constructor functions: `New{TypeName}()` (e.g., `NewUserRepository()`, `NewAuthHandler()`)
- Interface methods: descriptive action names (e.g., `GetByID()`, `UpdateProfile()`, `DeleteWorkout()`)

**Types:**
- PascalCase for struct names: `User`, `UserHandler`, `UserRepository`, `WorkoutSession`
- Interface suffix with `Interface`: `UserRepositoryInterface`, `ExerciseRepositoryInterface`
- Immutable domain types (repositories): Simple names like `User`, `Workout`, `Program`

**Variables:**
- camelCase: `userID`, `workoutTemplateID`, `isSuperset`, `emailRegex`, `jwtSecret`
- Receiver names: Single letter matching type (e.g., `r *UserRepository`, `h *UserHandler`)
- Input parameters: Descriptive names using camelCase

**Constants:**
- PascalCase for exported: `DefaultRestTimer`
- camelCase for unexported: `tokenExpiry`, `userIDKey`

**Packages:**
- Lowercase, no underscores: `handlers`, `repository`, `middleware`, `auth`, `testutil`
- Grouped by layer: `internal/handlers/`, `internal/repository/`, `internal/middleware/`, `internal/auth/`

### Dart/Flutter Frontend

**Files:**
- Feature screens: `{feature}_screen.dart` (e.g., `home_screen.dart`, `tracker_screen.dart`)
- Provider files: `{feature}_providers.dart` (e.g., `auth_providers.dart`, `session_providers.dart`)
- Widget components: `{widget_name}.dart` (e.g., `exercise_card.dart`, `set_row.dart`)
- Model classes: `{model_name}.dart` (e.g., `session_models.dart`)
- Test files: `{target}_test.dart` (e.g., `auth_provider_test.dart`, `tracker_screen_test.dart`)

**Functions & Methods:**
- camelCase: `getProfile()`, `updateSettings()`, `startSession()`, `syncSession()`
- Constructor named methods: `fromProto()` for converting from protobuf messages
- Getter methods: Property-style (e.g., `isAuthenticated` as getter)

**Types & Classes:**
- PascalCase for classes: `SessionModel`, `WorkoutBuilderState`, `SessionExerciseModel`
- Sealed classes with freezed: `@freezed sealed class SessionModel`
- State classes: `{FeatureName}State` (e.g., `AuthState`, `WorkoutBuilderState`)
- Provider notifiers: `@riverpod class {Feature} extends _${Feature}` pattern

**Variables:**
- camelCase: `userID`, `workoutId`, `supersetId`, `isLoading`, `emailRegex`
- Constants: camelCase with leading underscore for private: `_tokenKey`, `_userIdKey`
- State properties: camelCase in freezed models

**Enums & Constants:**
- PascalCase class constants: `const _uuid = Uuid()`
- Enum values from protobuf: UPPER_SNAKE_CASE (e.g., `ExerciseType.EXERCISE_TYPE_WEIGHT_REPS`)

**Packages & Imports:**
- Feature folder structure uses snake_case: `workout_builder`, `progress_tracker`
- Import organization: See "Import Organization" section

## Code Style

### Go Backend

**Formatting:**
- Standard Go formatting (use `gofmt`)
- Line length: No hard limit, but keep reasonable (most lines < 100 chars)
- Tab indentation (4 spaces default in Go)
- Brace style: Allman-style opening brace on same line (Go enforces this)

**Receiver Declaration:**
- Use pointer receiver for all handler methods: `func (h *UserHandler) GetProfile(...)`
- Use value receiver for utility functions when appropriate

**Blank Lines:**
- One blank line between top-level type definitions
- One blank line between method groups
- No trailing blank lines in files

**Linting:**
- Proto files: `make lint` runs `buf lint`
- No formal Go linter configured, follows standard Go practices
- Unused imports are an error (Go compiler enforces)

### Dart/Flutter Frontend

**Formatting:**
- Dart's standard formatter (run via `dart format` or IDE)
- Line length: 80 characters (default Dart standard)
- 2-space indentation
- Trailing commas in multi-line structures for better diffs

**Code Style:**
- Linting: `flutter_lints` package with minimal customization
- Analysis config: `analysis_options.yaml` with excluded generated code
- No use of `print()` in production code — use logging package instead
- Single quotes for strings when possible (not enforced, but preferred in Flutter)

**Widget Declaration:**
- Const constructors for immutable widgets: `const WorkoutCard({super.key, ...})`
- Named parameters for all widget constructors
- Use `HookConsumerWidget` for stateful widgets, `ConsumerWidget` for stateless

## Import Organization

### Go Backend

**Order (4 groups separated by blank lines):**

1. **Standard library:** `context`, `errors`, `time`, `fmt`, etc.
2. **Third-party packages:** `connectrpc.com/connect`, `google.golang.org/protobuf`, database drivers
3. **Internal packages:** `github.com/heftyback/gen/`, `github.com/heftyback/internal/`
4. **Aliased imports:** Named imports when package name conflicts (e.g., `heftv1 "github.com/heftyback/gen/heft/v1"`)

**Example:**
```go
import (
    "context"
    "errors"
    "time"

    "connectrpc.com/connect"
    "google.golang.org/protobuf/types/known/timestamppb"

    heftv1 "github.com/heftyback/gen/heft/v1"
    "github.com/heftyback/internal/auth"
    "github.com/heftyback/internal/repository"
)
```

### Dart/Flutter Frontend

**Order (3 groups separated by blank lines):**

1. **Dart imports:** `dart:*` (e.g., `dart:async`, `dart:io`)
2. **Package imports:** `package:*` (e.g., `package:flutter`, `package:riverpod_annotation`)
3. **Relative imports:** `'../'` paths to local files, organized by layer (core, features, shared)

**Example:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/client.dart';
import '../../../core/logging.dart';
import '../../home/providers/home_providers.dart';

part 'auth_providers.g.dart';
```

**Relative Path Aliases:**
- Avoid path aliases in current codebase
- Use relative imports: `import '../../../core/client.dart'`

## Error Handling

### Go Backend

**Pattern - Repository methods return (result, error):**
- Not found: Return `(nil, nil)` — absence of data is not an error
- Database errors: Return `(nil, err)` with underlying database error
- Validation errors: Return `(nil, err)` with descriptive message

**Pattern - Handler methods convert to Connect errors:**
```go
func (h *UserHandler) GetProfile(ctx context.Context, req *connect.Request[...]) (*connect.Response[...], error) {
    // Validation
    userID, ok := auth.UserIDFromContext(ctx)
    if !ok {
        return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("not authenticated"))
    }

    // Call repository
    user, err := h.repo.GetByID(ctx, userID)
    if err != nil {
        return nil, handleDBError(err)  // Converts DB errors to appropriate codes
    }
    if user == nil {
        return nil, connect.NewError(connect.CodeNotFound, errors.New("user not found"))
    }

    return connect.NewResponse(...), nil
}
```

**Error Code Mapping (from `internal/handlers/errors.go`):**
- `CodeUnauthenticated` (401) - Missing or invalid JWT token
- `CodePermissionDenied` (403) - User FK violation (user doesn't exist in DB)
- `CodeInvalidArgument` (400) - Missing required fields or validation errors
- `CodeNotFound` (404) - Resource doesn't exist
- `CodeAlreadyExists` (409) - Resource already exists (e.g., active session exists)
- `CodeInternal` (500) - Unexpected database errors

**Helper Function:**
- `handleDBError(err)` - Converts database errors: Returns 403 for user FK violations, 500 for others
- Located in `internal/handlers/errors.go`

### Dart/Flutter Frontend

**Pattern - Try/catch with logging:**
```dart
try {
    final result = await operation();
    logFeature.info('Operation succeeded: $result');
    return result;
} catch (e, st) {
    logFeature.severe('Operation failed', e, st);
    state = state.copyWith(error: e.toString(), isLoading: false);
    return null;
}
```

**Pattern - Provider async/when:**
```dart
ref.watch(futureProvider).when(
    loading: () => const LoadingWidget(),
    error: (error, stackTrace) => ErrorWidget(error: error.toString()),
    data: (data) => DisplayWidget(data: data),
);
```

**Error Presentation:**
- Store error as nullable string in state: `String? error`
- Display via error widgets or snackbars
- Never silently catch exceptions
- Always log SEVERE level for actual errors

## Logging

### Go Backend

**Framework:** Standard library `log` package (implicit via `fmt.Println` for debugging)
- No structured logging library currently used
- Middleware logs HTTP requests with duration and status

**Patterns:**
- Print errors to stderr during development
- Integration tests use test-specific logging
- Production logging handled at middleware level

### Dart/Flutter Frontend

**Framework:** `logging` package v1.3.0

**Available Loggers:**
```dart
final logAuth = Logger('heft.auth');           // Authentication
final logSession = Logger('heft.session');     // Workout session tracking
final logWorkout = Logger('heft.workout');     // Workout builder
final logProgram = Logger('heft.program');     // Program builder
final logProfile = Logger('heft.profile');     // User profile
final logProgress = Logger('heft.progress');   // Progress/stats
final logCalendar = Logger('heft.calendar');   // Calendar
final logHistory = Logger('heft.history');     // Session history
final logHome = Logger('heft.home');           // Home screen
final logStorage = Logger('heft.storage');     // Local storage
```

**Log Levels:**
- **SEVERE:** Errors that break functionality (include stack trace)
- **WARNING:** Recoverable issues, fallbacks being used
- **INFO:** Important operations (login, session start, save)
- **FINE:** Debug details (field updates, provider state changes)

**Usage:**
```dart
logSession.info('Session started: $sessionId');
logSession.severe('Sync failed for session', error, stackTrace);
logWorkout.fine('Saving workout: $workoutId');
logProfile.warning('Using local backup due to network error');
```

**Security:**
- Never log auth tokens or passwords
- Mask email addresses: `email.replaceRange(3, email.indexOf('@'), '***')`
- Never log PII without masking

**Initialization:**
```dart
// In main.dart before runApp()
initializeLogging();
```

## Comments

### Go Backend

**Package-level comments:**
```go
// UserHandler implements the UserService RPC handler
type UserHandler struct { ... }
```

**Function/method comments:**
- Must start with function name: `// GetProfile retrieves a user's profile`
- One sentence describing what it does
- Located immediately above function signature

**Inline comments:**
- Use sparingly, only for non-obvious logic
- Explain "why", not "what" (code shows what)
- Use `//` for single-line, `/* */` for block comments (rare)

**Type comments:**
```go
// User represents a user in the database
type User struct { ... }
```

### Dart/Flutter Frontend

**Documentation comments (///):**
```dart
/// Session model for state management
/// Represents a single workout session with exercises and sets.
@freezed
sealed class SessionModel with _$SessionModel { ... }
```

**Method documentation:**
```dart
/// Convert from protobuf Session message
/// Returns a [SessionModel] with computed total sets.
factory SessionModel.fromProto(Session pb) { ... }
```

**Inline comments:**
- Use `//` for brief inline notes
- Explain assumptions or non-obvious logic
- Always explain "why", not "what"

**Parameter documentation:**
- Include in main doc comment if complex
- Use `@param` style sparingly, usually just describe in main comment

## Function Design

### Go Backend

**Size Guidelines:**
- Handler functions: 20-40 lines (input validation + repo call + response mapping)
- Repository functions: 10-30 lines (build query + execute + error handling)
- Keep functions focused on single responsibility

**Parameters:**
- Context always first: `func (r *Repo) GetUser(ctx context.Context, ...)`
- Input structs for multiple parameters (protobuf messages)
- Avoid variadic arguments

**Return Values:**
- Tuple returns with error: `(result, error)`
- Repository pattern: `(result, error)` where not found = `(nil, nil)`
- Handler pattern: `(*connect.Response[...], error)`

### Dart/Flutter Frontend

**Size Guidelines:**
- Provider functions: 5-15 lines
- Widget `build()` methods: 20-50 lines (split complex builds into helper widgets)
- Utility functions: 5-20 lines

**Parameters:**
- Named parameters for functions and constructors
- Default values for optional parameters
- Use `required` keyword for mandatory fields

**Return Values:**
- Use Future for async: `Future<T>`
- Use `AsyncValue<T>` for Riverpod providers
- Nullable returns: `T?` for optional results

## Module Design

### Go Backend

**Exports:**
- Uppercase names are exported, lowercase are private
- Only export what's part of the public interface
- Struct fields: export if needed by other packages, otherwise lowercase

**Organization:**
- `internal/` for all application code (not exposed as library)
- Grouping by concern: `handlers/`, `repository/`, `middleware/`, `auth/`
- One package per directory

**Repository Pattern:**
- Define interface in `repository/interfaces.go`
- Implement in separate file: `repository/user.go`
- Compile-time check: `var _ UserRepositoryInterface = (*UserRepository)(nil)`

### Dart/Flutter Frontend

**Exports:**
- Public exports at feature level
- Barrel exports in `providers/` folders when appropriate
- Use `part` for generated code (riverpod, freezed)

**Organization:**
- Feature-based structure: `features/{feature_name}/`
- Each feature has: `providers/`, `widgets/`, optional `models/`
- Shared utilities: `shared/` for cross-feature components

**Barrel Files:**
- Not consistently used; prefer explicit imports
- When used, in main feature folder for convenience

---

*Convention analysis: 2026-03-10*
