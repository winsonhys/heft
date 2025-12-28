-- +goose Up
ALTER TABLE session_exercises ADD COLUMN superset_id TEXT;

-- +goose Down
ALTER TABLE session_exercises DROP COLUMN IF EXISTS superset_id;
