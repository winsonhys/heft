-- +goose Up
ALTER TABLE workout_templates DROP COLUMN IF EXISTS total_sets;
ALTER TABLE workout_sessions DROP COLUMN IF EXISTS total_sets;

-- +goose Down
ALTER TABLE workout_templates ADD COLUMN total_sets INTEGER DEFAULT 0;
ALTER TABLE workout_sessions ADD COLUMN total_sets INTEGER DEFAULT 0;
