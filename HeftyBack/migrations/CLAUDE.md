# Migrations

Goose format. Create new migrations with `make migrate-create name=descriptive_name`.

## Format

```sql
-- +goose Up
-- +goose StatementBegin
CREATE TABLE foo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS foo;
-- +goose StatementEnd
```

## Rules

- UUIDs for primary keys: `DEFAULT gen_random_uuid()`
- User-scoped tables: `user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE`
- Always include `-- +goose Down` for rollback
- Wrap complex statements in `StatementBegin` / `StatementEnd`
- Unique constraints for user-scoped uniqueness: `UNIQUE(user_id, other_field)`
- Timestamps default to `CURRENT_TIMESTAMP`

## Commands

```bash
make migrate-create name=xxx   # Create new migration file
make migrate-up                # Apply all pending
make migrate-down              # Rollback last
make migrate-status            # Check status
```
