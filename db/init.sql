CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    avatar_url VARCHAR(500),
    last_global_online TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE groups (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    avatar_url VARCHAR(500),
    created_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    is_direct_message BOOLEAN,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE group_members (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT REFERENCES groups(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'MEMBER',
    last_seen_at TIMESTAMP DEFAULT NOW(),
    joined_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    group_id BIGINT REFERENCES groups(id) ON DELETE CASCADE,
    sender_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'TEXT',
    created_at TIMESTAMP DEFAULT NOW()
);

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
);

CREATE INDEX idx_ai_analyses_group_user ON ai_analyses(group_id, user_id);

-- =============================================
-- SEED DATA MẪU (Dữ liệu thử nghiệm)
-- =============================================

-- 1. Nạp dữ liệu bảng users (Mật khẩu mặc định là 'password' đã được hash BCrypt)
INSERT INTO users (id, username, email, password_hash, display_name, avatar_url, last_global_online) VALUES
(1, 'quangminh', 'minh@example.com', '$2a$10$dXJ3SWI9NTMwOTE5OTk5NeS07h.Z5JdlyOsh.9w3o3P.sS1a3Rkm.', 'Quảng Minh', 'https://api.dicebear.com/7.x/adventurer/svg?seed=minh', NOW() - INTERVAL '1 hour'),
(2, 'alice', 'alice@example.com', '$2a$10$dXJ3SWI9NTMwOTE5OTk5NeS07h.Z5JdlyOsh.9w3o3P.sS1a3Rkm.', 'Alice Nguyen', 'https://api.dicebear.com/7.x/adventurer/svg?seed=alice', NOW() - INTERVAL '30 minutes'),
(3, 'bob', 'bob@example.com', '$2a$10$dXJ3SWI9NTMwOTE5OTk5NeS07h.Z5JdlyOsh.9w3o3P.sS1a3Rkm.', 'Bob Tran', 'https://api.dicebear.com/7.x/adventurer/svg?seed=bob', NOW() - INTERVAL '15 minutes'),
(4, 'charlie', 'charlie@example.com', '$2a$10$dXJ3SWI9NTMwOTE5OTk5NeS07h.Z5JdlyOsh.9w3o3P.sS1a3Rkm.', 'Charlie Le', 'https://api.dicebear.com/7.x/adventurer/svg?seed=charlie', NOW());

-- Reset sequence cho cột tự tăng của bảng users (để tránh lỗi trùng ID khi tạo tài khoản mới)
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

-- 2. Nạp dữ liệu bảng groups (Nhóm chat)
INSERT INTO groups (id, name, description, avatar_url, created_by, is_direct_message) VALUES
(1, 'Lập Trình Spring Boot & AI', 'Nhóm thảo luận về đồ án tốt nghiệp tích hợp AI', 'https://api.dicebear.com/7.x/identicon/svg?seed=springboot', 1, FALSE),
(2, 'Nghiên Cứu Gemini API', 'Kênh chia sẻ kiến thức sử dụng Google Gemini', 'https://api.dicebear.com/7.x/identicon/svg?seed=gemini', 2, FALSE);

-- Reset sequence cho cột tự tăng của bảng groups
SELECT setval('groups_id_seq', (SELECT MAX(id) FROM groups));

-- 3. Nạp dữ liệu bảng group_members (Thành viên nhóm)
INSERT INTO group_members (id, group_id, user_id, role, last_seen_at, joined_at) VALUES
(1, 1, 1, 'ADMIN', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '5 days'),
(2, 1, 2, 'MEMBER', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '5 days'),
(3, 1, 3, 'MEMBER', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '4 days'),
(4, 1, 4, 'MEMBER', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '3 days'),
(5, 2, 1, 'MEMBER', NOW(), NOW() - INTERVAL '2 days'),
(6, 2, 2, 'ADMIN', NOW(), NOW() - INTERVAL '2 days');

-- Reset sequence cho cột tự tăng của bảng group_members
SELECT setval('group_members_id_seq', (SELECT MAX(id) FROM group_members));

-- 4. Nạp dữ liệu bảng messages (Tin nhắn mẫu mô phỏng cuộc trò chuyện thực tế theo kịch bản trong docs)
INSERT INTO messages (id, group_id, sender_id, content, message_type, created_at) VALUES
(1, 1, 2, 'Chào mọi người! Deadline đồ án ngày mai rồi, tiến độ thế nào rồi ạ?', 'TEXT', NOW() - INTERVAL '45 minutes'),
(2, 1, 3, 'Mình vẫn chưa xong phần API backend, đang bị kẹt tí ở chỗ phân quyền Security 😢', 'TEXT', NOW() - INTERVAL '40 minutes'),
(3, 1, 2, 'Cố lên Bob! Team mình nhất định làm được, có gì khó cứ hú nhé!', 'TEXT', NOW() - INTERVAL '35 minutes'),
(4, 1, 4, 'Mọi người ơi, mình đã hoàn thành và push xong code phần giao diện frontend lên GitHub rồi nha 🎉', 'TEXT', NOW() - INTERVAL '30 minutes'),
(5, 1, 3, 'Tuyệt quá Charlie! Ok mình sẽ cố gắng hoàn thành phần backend trong tối nay để ghép code.', 'TEXT', NOW() - INTERVAL '25 minutes'),
(6, 1, 1, 'Chào cả nhà, mình vừa online. Thấy mọi người trao đổi tích cực quá, cố lên nhé sắp về đích rồi!', 'TEXT', NOW() - INTERVAL '20 minutes');

-- Reset sequence cho cột tự tăng của bảng messages
SELECT setval('messages_id_seq', (SELECT MAX(id) FROM messages));

-- 5. Nạp dữ liệu bảng ai_analyses (Kết quả phân tích AI mẫu được cache lại cho User 1 - Quảng Minh)
INSERT INTO ai_analyses (id, group_id, user_id, summary, sentiment_label, sentiment_score, sentiment_detail, from_message_id, to_message_id, message_count, analyzed_at) VALUES
(1, 1, 1, 'Nhóm đang thảo luận về deadline đồ án ngày mai. Charlie đã hoàn thành và push code frontend. Bob đang gặp khó khăn nhỏ ở phần backend Security nhưng đang nỗ lực hoàn thành trong tối nay. Các thành viên có tinh thần hỗ trợ nhau rất cao.', 'POSITIVE', 0.85, 'Cuộc trò chuyện có tông giọng tích cực, các thành viên cổ vũ động viên lẫn nhau vượt qua áp lực deadline.', 1, 5, 5, NOW() - INTERVAL '19 minutes');

-- Reset sequence cho cột tự tăng của bảng ai_analyses
SELECT setval('ai_analyses_id_seq', (SELECT MAX(id) FROM ai_analyses));
