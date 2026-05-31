CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    avatar_url VARCHAR(500),
    last_global_onlie TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
)

CREATE TABLE groups (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    avatar_url VARCHAR(500),
    created_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    is_direct_message BOOLEAN,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
)

CREATE TABLE group_members (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT REFERENCES groups(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'MEMBER',
    last_seen_at TIMESTAMP DEFAULT NOW(),
    joined_at TIMESTAMP DEFAULT NOW()
)

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT REFERENCES groups(id) ON DELETE CASCADE,
    sender_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'TEXT',
    created_at TIMESTAMP DEFAULT NOW()
)

CREATE INDEX idx_messages_group_created ON messages(group_id, created_at);
CREATE INDEX idx_messages_sender ON messages(sender_id);

CREATE TABLE ai_analyses (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT REFERENCES groups(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    summary TEXT,
    sentiment_label VARCHAR(50),
    sentiment_score FLOAT,
    sentiment_detail TEXT,
    from_message_id BIGINT REFERENCES messages(id) ON DELETE CASCADE,
    to_message_id BIGINT REFERENCES messages(id) ON DELETE CASCADE,
    message_count INTEGER,
    analyzed_at TIMESTAMP DEFAULT NOW()
)

CREATE INDEX idx_ai_analyses_group_user ON ai_analyses(group_id, user_id);

