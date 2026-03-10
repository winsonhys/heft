# Core Layer

Infrastructure: RPC clients, configuration, logging, storage. Foundation for everything above.

## Rules

- Never import from `lib/features/` or `lib/shared/`. Core is the base layer.
- Never hand-edit `lib/gen/`. Regenerate with `buf generate`.

## client.dart

All 7 RPC service clients are defined and re-exported here as globals.

```dart
final authClient = AuthServiceClient(_transport);
final userClient = UserServiceClient(_transport);
// ... etc
```

- Auth interceptor adds `Authorization: Bearer <token>` to every request
- Token provider set via `setTokenProvider()` after login
- Platform-specific HTTP: `http_io.dart` (native) / `http_web.dart` (browser)

## config.dart

Static constants only. Uses `kReleaseMode` for environment detection.

```dart
static const String backendUrl = 'http://localhost:8080';
```

## logging.dart

Pre-defined loggers per feature. Call `initializeLogging()` in `main()`.

```dart
logAuth.info('Login successful');
logSession.severe('Sync failed', error, stackTrace);
```

## session_storage.dart

Local session backup using protobuf serialization. Offline-first pattern.

## Allowed Imports

- `lib/gen/*` (proto types)
- Dart/Flutter SDK, pub packages
- NEVER import from `lib/features/*` or `lib/shared/*`
