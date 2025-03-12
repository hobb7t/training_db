-- Enable Foreign Key Support
PRAGMA foreign_keys = OFF;

-- Drop Existing View First (It Depends on Other Tables)
DROP VIEW IF EXISTS leaderboard;

-- Drop Tables in Correct Order to Prevent Dependency Errors
DROP TABLE IF EXISTS scores;
DROP TABLE IF EXISTS answers;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS quiz_categories;
DROP TABLE IF EXISTS users;

-- Re-enable Foreign Key Support
PRAGMA foreign_keys = ON;

-- Create Users Table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('user', 'admin')),
    department TEXT NOT NULL
);

-- Create Quiz Categories Table
CREATE TABLE quiz_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

-- Create Questions Table
CREATE TABLE questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_text TEXT NOT NULL,
    image_url TEXT,
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES quiz_categories(id) ON DELETE CASCADE
);

-- Create Answers Table
CREATE TABLE answers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL,
    answer_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- Create Scores Table
CREATE TABLE scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    score INTEGER NOT NULL,
    percentage DECIMAL(4,2) NOT NULL DEFAULT 0.00,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES quiz_categories(id) ON DELETE CASCADE
);

-- Create Leaderboard View (Read-Only Aggregation)
CREATE VIEW leaderboard AS
SELECT 
    users.id AS user_id,
    users.username,
    SUM(scores.score) AS total_score
FROM scores
JOIN users ON scores.user_id = users.id
GROUP BY users.id
ORDER BY total_score DESC;
-- Enable Foreign Key Support (Important for SQLite)
PRAGMA foreign_keys = ON;

-- Drop Existing Tables to Avoid Conflicts
DROP VIEW IF EXISTS leaderboard;
DROP TABLE IF EXISTS scores;
DROP TABLE IF EXISTS answers;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS quiz_categories;
DROP TABLE IF EXISTS users;

-- Create Users Table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('user', 'admin')),
    department TEXT NOT NULL
);

-- Create Quiz Categories Table
CREATE TABLE quiz_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

-- Create Questions Table
-- Enable Foreign Key Support (Important for SQLite)
PRAGMA foreign_keys = ON;

-- Drop Existing Tables to Avoid Conflicts
DROP VIEW IF EXISTS leaderboard;
DROP TABLE IF EXISTS scores;
DROP TABLE IF EXISTS answers;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS quiz_categories;
DROP TABLE IF EXISTS users;

-- Create Users Table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('user', 'admin')),
    department TEXT NOT NULL
);

-- Create Quiz Categories Table
CREATE TABLE quiz_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

-- Create Questions Table
CREATE TABLE questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_text TEXT NOT NULL,
    image_url TEXT,
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES quiz_categories(id) ON DELETE CASCADE
);

-- Create Answers Table
CREATE TABLE answers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL,
    answer_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- Create Scores Table
CREATE TABLE scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    score INTEGER NOT NULL,
    percentage DECIMAL(4,2) NOT NULL DEFAULT 0.00,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES quiz_categories(id) ON DELETE CASCADE
);

-- Create Leaderboard View (Read-Only Aggregation)
CREATE VIEW leaderboard AS
SELECT 
    users.id AS user_id,
    users.username,
    SUM(scores.score) AS total_score
FROM scores
JOIN users ON scores.user_id = users.id
GROUP BY users.id
ORDER BY total_score DESC;
CREATE TABLE questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_text TEXT NOT NULL,
    image_url TEXT,
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES quiz_categories(id) ON DELETE CASCADE
);

-- Create Answers Table
CREATE TABLE answers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL,
    answer_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- Create Scores Table
CREATE TABLE scores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    score INTEGER NOT NULL,
    percentage DECIMAL(4,2) NOT NULL DEFAULT 0.00,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES quiz_categories(id) ON DELETE CASCADE
);

-- Create Leaderboard View (Read-Only Aggregation)
CREATE VIEW leaderboard AS
SELECT 
    users.id AS user_id,
    users.username,
    SUM(scores.score) AS total_score
FROM scores
JOIN users ON scores.user_id = users.id
GROUP BY users.id
ORDER BY total_score DESC;

