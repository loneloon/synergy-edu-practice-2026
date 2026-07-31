DROP table if EXISTS user_session;
DROP table if EXISTS activity;
DROP table if EXISTS activity_group;
DROP table if EXISTS app_user;

-- ----------------------------------------
CREATE TABLE app_user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(254) NOT NULL,
    secret VARCHAR(255) NOT NULL,

    CONSTRAINT uq_app_user_username
        UNIQUE (username),

    CONSTRAINT uq_app_user_email
        UNIQUE (email)
);

-- ----------------------------------------
CREATE TABLE activity_group (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- ----------------------------------------
CREATE TABLE activity (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    start_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_ts TIMESTAMP,
    name VARCHAR(100) NOT NULL,
    group_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,

    CONSTRAINT fk_activity_group
        FOREIGN KEY (group_id)
        REFERENCES activity_group(id),

    CONSTRAINT fk_activity_user
        FOREIGN KEY (user_id)
        REFERENCES app_user(id)
);

-- ----------------------------------------
CREATE TABLE user_session (
    id BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID(), 1)),
    user_id BIGINT NOT NULL,

    PRIMARY KEY (id),

    CONSTRAINT fk_user_session
        FOREIGN KEY (user_id)
        REFERENCES app_user(id),
    
    CONSTRAINT uq_app_user_session
        UNIQUE (user_id)
);
