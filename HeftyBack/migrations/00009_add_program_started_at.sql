-- +goose Up
ALTER TABLE programs ADD COLUMN started_at TIMESTAMP;

-- +goose Down
ALTER TABLE programs DROP COLUMN started_at;
