/*
disable FK Support
*/
PRAGMA foreign_keys = OFF;
/*
-- Drop view first (due to deppendency errors)
*/
DROP VIEW IF EXISTS leaderboard;
/*
-- Drop tables in  order 
*/
DROP TABLE IF EXISTS scores;
DROP TABLE IF EXISTS answers;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS quiz_categories;
DROP TABLE IF EXISTS users;
/*
-- Re-enable FK Support
*/
PRAGMA foreign_keys = ON;

/*
-- Users Table
*/

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('user', 'admin')),
    department TEXT NOT NULL
);

/*
-- Quiz Cat Table
*/

CREATE TABLE quiz_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    is_active INTEGER DEFAULT 1 -- 1 = Active, 0 = Inactive
);

/*
-- Questions Table
*/

CREATE TABLE questions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_text TEXT NOT NULL,
    image_url TEXT DEFAULT NULL,
    category_id INTEGER NOT NULL,
    department TEXT NOT NULL, -- For department-based filtering
    is_active INTEGER DEFAULT 1, -- 1 = Active, 0 = Inactive
    FOREIGN KEY (category_id) REFERENCES quiz_categories(id) ON DELETE CASCADE
);

/*
-- Answers Table
*/

CREATE TABLE answers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL,
    answer_text TEXT DEFAULT NULL, -- Can be NULL for image-based answers
    image_url TEXT DEFAULT NULL, -- Can be NULL for text-based answers
    is_correct BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);
/*
-- Scores Table
*/
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

/*
-- Leaderboard View (Excludes Admins)
*/
CREATE VIEW leaderboard AS
SELECT 
    users.id AS user_id,
    users.username,
    SUM(scores.score) AS total_score
FROM scores
JOIN users ON scores.user_id = users.id
WHERE users.role = 'user' -- Exclude admins
GROUP BY users.id
ORDER BY total_score DESC;
/*
-- Enable FK Support
*/
PRAGMA foreign_keys = ON;
