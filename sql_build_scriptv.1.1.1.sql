const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, 'database', 'quiz_app.db');
const db = new sqlite3.Database(dbPath, sqlite3.OPEN_READWRITE, (err) => {
    if (err) {
        console.error('DB connection failed:', err.message);
        process.exit(1);
    } else {
        console.log(`Connected to SQLite database at ${dbPath}`);
    }
});

db.serialize(() => {
    /*
    disable FK Support
    */
    db.run("PRAGMA foreign_keys = OFF;");
    
    /*
    Drop view first (due to dependency errors)
    */
    db.run("DROP VIEW IF EXISTS leaderboard;");
    
    /*
    -- Drop tables in order 
    */
    db.run("DROP TABLE IF EXISTS scores;");
    db.run("DROP TABLE IF EXISTS answers;");
    db.run("DROP TABLE IF EXISTS questions;");
    db.run("DROP TABLE IF EXISTS quiz_categories;");
    db.run("DROP TABLE IF EXISTS users;");
    
    /*
    Re-enable FK Support
    */
    db.run("PRAGMA foreign_keys = ON;");

    /*
    Users Table
    */
    db.run(`
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL CHECK (role IN ('user', 'admin')),
            department TEXT NOT NULL
        );
    `);

    /*
    Quiz Cat Table
    */
    db.run(`
        CREATE TABLE quiz_categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            is_active INTEGER DEFAULT 1 -- 1 = Active, 0 = Inactive
        );
    `);

    /*
    Questions Table
    */
    db.run(`
        CREATE TABLE questions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question_text TEXT NOT NULL,
            image_url TEXT DEFAULT NULL,
            category_id INTEGER NOT NULL,
            department TEXT NOT NULL, -- For department-based filtering
            is_active INTEGER DEFAULT 1, -- 1 = Active, 0 = Inactive
            FOREIGN KEY (category_id) REFERENCES quiz_categories(id) ON DELETE CASCADE
        );
    `);

    /*
    Answers Table
    */
    db.run(`
        CREATE TABLE answers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question_id INTEGER NOT NULL,
            answer_text TEXT DEFAULT NULL, -- Can be NULL for image-based answers
            image_url TEXT DEFAULT NULL, -- Can be NULL for text-based answers
            is_correct BOOLEAN NOT NULL DEFAULT 0,
            FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
        );
    `);

    /*
    Scores Table
    */
    db.run(`
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
    `);

    /*
    Leaderboard View (Excludes Admins)
    */
    db.run(`
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
    `);

    /*
    Enable FK Support
    */
    db.run("PRAGMA foreign_keys = ON;");
});

db.close(() => {
    console.log("Database setup complete.");
});
