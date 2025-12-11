-- +goose Up
-- +goose StatementBegin

-- Create test user for integration testing
-- Password hash is bcrypt hash of 'testpassword123'
INSERT INTO users (id, email, password_hash, display_name, use_pounds, rest_timer_seconds, member_since) VALUES
    ('00000000-0000-0000-0000-000000000001', 'test@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Test User', FALSE, 90, NOW());

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DELETE FROM users WHERE id = '00000000-0000-0000-0000-000000000001';

-- +goose StatementEnd
