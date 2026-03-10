# Workflows

Step-by-step recipes for common tasks.

## Add a New API Endpoint

1. **Define proto** in BOTH projects:

   `HeftyBack/proto/heft/v1/{service}.proto`:
   ```protobuf
   rpc NewMethod(NewMethodRequest) returns (NewMethodResponse);

   message NewMethodRequest {
       // No user_id — extracted from JWT
       string resource_id = 1;
   }

   message NewMethodResponse {
       // response fields
   }
   ```

   Copy the same changes to `hefty_chest/proto/{service}.proto`.

2. **Generate code** in both:
   ```bash
   cd HeftyBack && make generate
   cd hefty_chest && buf generate
   ```

3. **Add repository interface** in `internal/repository/interfaces.go`:
   ```go
   type FooRepositoryInterface interface {
       // existing methods...
       NewMethod(ctx context.Context, userID string, resourceID string) (*Result, error)
   }
   ```

4. **Implement repository** in `internal/repository/{service}.go`.

5. **Implement handler** in `internal/handlers/{service}.go`:
   ```go
   func (h *Handler) NewMethod(ctx context.Context, req *connect.Request[heftv1.NewMethodRequest]) (*connect.Response[heftv1.NewMethodResponse], error) {
       userID, ok := auth.UserIDFromContext(ctx)
       if !ok {
           return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("user not authenticated"))
       }
       // validate → repo call → handle errors → return response
   }
   ```

6. **Add tests** in `internal/handlers/{service}_test.go`.

7. **Create frontend provider** in feature's `providers/` folder.

8. **Update UI** to use the new provider.

## Add a New Feature Screen

1. Create feature folder:
   ```
   lib/features/{name}/
   ├── {name}_screen.dart
   ├── providers/
   │   └── {name}_providers.dart
   └── widgets/
   ```

2. Create screen widget:
   ```dart
   class NewFeatureScreen extends ConsumerWidget {
     const NewFeatureScreen({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return Scaffold(body: SafeArea(child: /* ... */));
     }
   }
   ```

3. Add providers with `@riverpod` annotation.

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

5. Regenerate router:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Add a Database Migration

```bash
cd HeftyBack
make migrate-create name=add_new_column
```

Edit the generated file in `migrations/`:

```sql
-- +goose Up
ALTER TABLE users ADD COLUMN new_column TEXT;

-- +goose Down
ALTER TABLE users DROP COLUMN new_column;
```

Apply:
```bash
make migrate-up        # Apply
make migrate-status    # Verify
make migrate-down      # Rollback if needed
```

## Make Proto Changes

Proto files define the API contract. **Changes must be made in BOTH projects.**

1. Edit `.proto` in `HeftyBack/proto/heft/v1/` AND `hefty_chest/proto/`
2. `cd HeftyBack && make generate`
3. `cd hefty_chest && buf generate`
4. Implement/update handler in backend
5. Update providers/UI in frontend

## Add a New Provider

```dart
// In lib/features/{name}/providers/{name}_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '{name}_providers.g.dart';

@riverpod
Future<MyData> myData(Ref ref) async {
  final response = await myClient.getData(MyRequest());
  return response.data;
}
```

Then regenerate:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Add Mock Methods

1. Add method to interface in `internal/repository/interfaces.go`
2. Add func field to mock in `internal/testutil/mocks.go`:
   ```go
   type MockFooRepository struct {
       NewMethodFunc func(ctx context.Context, ...) (*Result, error)
   }
   ```
3. Implement the interface method:
   ```go
   func (m *MockFooRepository) NewMethod(ctx context.Context, ...) (*Result, error) {
       return m.NewMethodFunc(ctx, ...)
   }
   ```
4. Maintain compile-time check:
   ```go
   var _ repository.FooRepositoryInterface = (*MockFooRepository)(nil)
   ```

## Run the Full Stack

```bash
# Terminal 1 — Backend
cd HeftyBack && docker compose up -d

# Terminal 2 — Frontend
cd hefty_chest && flutter run
```

Server runs on `:8080`, PostgreSQL on `:5433`.

## Docker Rebuild After Code Changes

```bash
cd HeftyBack
docker compose down && docker compose build --no-cache && docker compose up -d
```
