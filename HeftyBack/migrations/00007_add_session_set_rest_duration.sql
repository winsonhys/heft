-- +goose Up
-- +goose StatementBegin
ALTER TABLE session_sets ADD COLUMN rest_duration_seconds INTEGER;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE session_sets DROP COLUMN rest_duration_seconds;
-- +goose StatementEnd
