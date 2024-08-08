-- init.sql

-- Create the user_profile table if it does not exist
CREATE TABLE IF NOT EXISTS user_profile (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE user_profile REPLICA IDENTITY FULL;

-- Insert sample data into the user_profile table
INSERT INTO user_profile (name, email) VALUES ('Alice', 'alice@example.com');
INSERT INTO user_profile (name, email) VALUES ('Bob', 'bob@example.com');
INSERT INTO user_profile (name, email) VALUES ('Charlie', 'charlie@example.com');
INSERT INTO user_profile (name, email) VALUES ('David', 'david@example.com');
INSERT INTO user_profile (name, email) VALUES ('Eve', 'eve@example.com');