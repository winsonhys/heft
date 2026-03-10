# Code Conventions

## Error Handling

### Backend Error Code Mapping

| Connect Code | HTTP | When to Use |
|---|---|---|
| `CodeUnauthenticated` | 401 | Missing or invalid JWT token |
| `CodePermissionDenied` | 403 | User doesn't exist in DB (FK violation) |
| `CodeInvalidArgument` | 400 | Missing required fields, invalid input |
| `CodeNotFound` | 404 | Resource not found |
| `CodeAlreadyExists` | 409 | Duplicate (e.g., user has active session) |
| `CodeInternal` | 500 | Other database/server errors |

### Backend Error Pattern

Every handler follows this exact sequence:

```go
func (h *Handler) Method(ctx context.Context, req *connect.Request[...]) (*connect.Response[...], error) {
    // 1. Extract user ID from JWT
    userID, ok := auth.UserIDFromContext(ctx)
    if !ok {
        return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("user not authenticated"))
    }

    // 2. Validate input
    if req.Msg.RequiredField == "" {
        return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("required_field is required"))
    }

    // 3. Call repository
    result, err := h.repo.DoSomething(ctx, userID, req.Msg.Field)
    if err != nil {
        return nil, handleDBError(err)  // Handles FK violations → 403
    }

    // 4. Check not found
    if result == nil {
        return nil, connect.NewError(connect.CodeNotFound, errors.New("resource not found"))
    }

    // 5. Return success
    return connect.NewResponse(&proto.Response{...}), nil
}
```

### Frontend Error Handling

```dart
// In providers — let Riverpod handle errors via AsyncValue
@riverpod
Future<Data> myData(Ref ref) async {
  final response = await client.method(request);  // Throws on error
  return response.data;
}

// In widgets — use .when() pattern
ref.watch(myDataProvider).when(
  loading: () => const FProgress(),
  error: (e, st) => Text('Error: $e'),
  data: (data) => /* build UI */,
);
```

## Naming Conventions

### Backend (Go)

| What | Convention | Example |
|---|---|---|
| Files | snake_case | `workout_service.go` |
| Packages | lowercase single word | `handlers`, `repository` |
| Exported types | PascalCase | `UserHandler`, `WorkoutRepository` |
| Interface names | PascalCase + Interface suffix | `UserRepositoryInterface` |
| Handler constructors | `NewXxxHandler(repo)` | `NewUserHandler(userRepo)` |
| Repository constructors | `NewXxxRepository(pool)` | `NewUserRepository(pool)` |
| Test functions | `TestType_Method` | `TestUserHandler_GetProfile` |
| Proto files | snake_case.proto | `workout.proto` |

### Frontend (Dart)

| What | Convention | Example |
|---|---|---|
| Files | snake_case | `workout_builder_screen.dart` |
| Classes | PascalCase | `WorkoutBuilderScreen` |
| Providers (generated) | camelCase + Provider | `workoutListProvider` |
| Notifiers (generated) | camelCase + Provider | `workoutBuilderProvider` |
| Feature folders | snake_case | `lib/features/workout_builder/` |
| Screen widgets | `{Feature}Screen` | `TrackerScreen` |
| Route classes | `{Name}Route` | `TrackerRoute` |
| State classes | `{Feature}State` | `WorkoutBuilderState` |
| Loggers | `log{Feature}` | `logSession`, `logWorkout` |

## Security Rules

1. **User scoping:** Every SQL query on user data includes `WHERE user_id = $N`
2. **JWT only:** User ID from `auth.UserIDFromContext(ctx)`, never from request body
3. **No secrets in code:** Use environment variables for keys, URLs, credentials
4. **No PII in logs:** Mask emails, never log tokens or passwords
5. **FK validation:** `handleDBError()` converts FK violations to 403 (user doesn't exist)

## Code Patterns

### Repository: Not-Found Convention

```go
// Not found returns (nil, nil) — NOT an error
if errors.Is(err, pgx.ErrNoRows) {
    return nil, nil
}
```

Handler checks nil and returns `CodeNotFound`:
```go
if result == nil {
    return nil, connect.NewError(connect.CodeNotFound, errors.New("not found"))
}
```

### Repository: Compile-Time Interface Check

```go
var _ UserRepositoryInterface = (*UserRepository)(nil)
```

Every repository implementation must include this line.

### Frontend: Immutable State with copyWith

```dart
class MyState {
  final String name;
  final bool isLoading;

  const MyState({this.name = '', this.isLoading = false});

  MyState copyWith({String? name, bool? isLoading}) {
    return MyState(
      name: name ?? this.name,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
```

### Frontend: Auto-Dispose Provider Testing

When testing `@riverpod` providers (auto-dispose by default), keep alive during async:

```dart
test('async provider test', () async {
  final subscription = container.listen(myProvider, (_, __) {});
  try {
    final notifier = container.read(myProvider.notifier);
    await notifier.someAsyncMethod();
    // assertions...
  } finally {
    subscription.close();
  }
});
```

### Frontend: Platform-Specific HTTP

| File | Platform | Library |
|---|---|---|
| `http.dart` | Stub | Throws UnimplementedError |
| `http_io.dart` | Native (iOS, Android, macOS) | `connectrpc/http2.dart` |
| `http_web.dart` | Web (Chrome) | `connectrpc/web.dart` |

### Proto: Message Design

```protobuf
// User ID is NEVER in request messages — extracted from JWT
message ListWorkoutsRequest {
    PaginationRequest pagination = 1;
}

// Use oneof for polymorphic fields
message SyncSetInput {
    oneof set_identifier {
        string existing_set_id = 1;
        NewSetInput new_set = 2;
    }
}
```

## Logging

### Frontend Logger Usage

```dart
import '../core/logging.dart';

logAuth.info('Login successful');
logSession.severe('Sync failed', error, stackTrace);
logWorkout.fine('Saving workout');
```

| Level | When |
|---|---|
| SEVERE | All errors, include stack trace |
| WARNING | Recoverable issues, fallbacks |
| INFO | Important operations (start, complete) |
| FINE | Debug details |
