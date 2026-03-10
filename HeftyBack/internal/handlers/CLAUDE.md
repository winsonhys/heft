# Handlers Layer

Every handler method MUST follow this exact sequence:

```go
func (h *Handler) Method(ctx context.Context, req *connect.Request[...]) (*connect.Response[...], error) {
    // 1. Auth — ALWAYS first
    userID, ok := auth.UserIDFromContext(ctx)
    if !ok {
        return nil, connect.NewError(connect.CodeUnauthenticated, errors.New("user not authenticated"))
    }

    // 2. Validate — check required fields
    if req.Msg.Field == "" {
        return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("field is required"))
    }

    // 3. Business logic — call repository (via interface, never pgx directly)
    result, err := h.repo.DoSomething(ctx, userID, req.Msg.Field)
    if err != nil {
        return nil, handleDBError(err)  // converts FK violations → 403
    }

    // 4. Not found check — repository returns nil, nil for missing records
    if result == nil {
        return nil, connect.NewError(connect.CodeNotFound, errors.New("resource not found"))
    }

    // 5. Return — convert to proto, wrap in response
    return connect.NewResponse(&proto.Response{...}), nil
}
```

## Rules

- Import repositories via interface only. Never import `pgx` or `repository` implementations.
- Use `handleDBError()` from `errors.go` for ALL database errors.
- Convert repo types to proto using helper functions (e.g., `sessionToProto()`).
- Handle optional fields: `if s.Field != nil { proto.Field = *s.Field }`
- Type conversions: `int` ↔ `int32`, `time.Time` → `*timestamppb.Timestamp`
- Tests go in `{service}_test.go` next to the handler file.
