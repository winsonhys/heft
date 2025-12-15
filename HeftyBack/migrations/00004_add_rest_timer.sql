-- +goose Up
-- +goose StatementBegin
ALTER TABLE exercise_target_sets ADD COLUMN rest_duration_seconds INTEGER;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE exercise_target_sets DROP COLUMN rest_duration_seconds;
-- +goose StatementEnd
