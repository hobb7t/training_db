require('dotenv').config();
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

const dbPath = "/Users/eratozogopoulou/Desktop/database/quiz_app.db";
const db = new sqlite3.Database(dbPath, sqlite3.OPEN_READWRITE, (err) => {
    if (err) {
        console.error('DB connection failed:', err.message);
        process.exit(1);
    }
});

// JWT Secret Key
const JWT_SECRET = "your_secret_key";

// Middleware: Auth Verification
const verifyToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(403).json({ error: "No token provided" });
    }
    const token = authHeader.split(" ")[1];
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) return res.status(401).json({ error: "Unauthorized" });
        req.user = decoded;
        next();
    });
};

const verifyAdmin = (req, res, next) => {
    if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({ error: "Admins only" });
    }
    next();
};

// ========================
// LOGIN (POST /api/login)
// ========================
app.post('/api/login', (req, res) => {
    const { username, password } = req.body;
    const sql = "SELECT * FROM users WHERE username = ?";
    db.get(sql, [username], (err, user) => {
        if (err) return res.status(500).json({ error: "Database error" });
        if (!user || password !== user.password) return res.status(401).json({ error: "Invalid login" });

        const token = jwt.sign(
            { id: user.id, username: user.username, role: user.role, department: user.department },
            JWT_SECRET,
            { expiresIn: "2h" }
        );

        res.json({ token, role: user.role, department: user.department });
    });
});

// ========================
// FETCH QUIZ QUESTIONS
// ========================
app.get('/api/quiz/:category_id', verifyToken, (req, res) => {
    const categoryId = req.params.category_id;
    const userDepartment = req.user.department;
    const userRole = req.user.role;

    console.log("Fetching quiz for category:", categoryId);
    console.log("User department:", userDepartment);
    console.log("User role:", userRole);

    let sql;
    let params;

    if (userRole === "admin") {
        sql = `
            SELECT q.id AS question_id, q.question_text, q.image_url AS question_image, 
                   a.id AS answer_id, a.answer_text, a.image_url AS answer_image, a.is_correct
            FROM questions q
            JOIN answers a ON q.id = a.question_id
            WHERE q.category_id = ? AND q.is_active = 1
        `;
        params = [categoryId];
    } else {
        sql = `
            SELECT q.id AS question_id, q.question_text, q.image_url AS question_image, 
                   a.id AS answer_id, a.answer_text, a.image_url AS answer_image, a.is_correct
            FROM questions q
            JOIN answers a ON q.id = a.question_id
            WHERE q.category_id = ? AND (q.department = ? OR q.department = 'ALL') AND q.is_active = 1
        `;
        params = [categoryId, userDepartment];
    }

    console.log("Executing SQL:", sql);
    console.log("Query Parameters:", params);

    db.all(sql, params, (err, rows) => {
        if (err) {
            console.error("Database error:", err.message);
            return res.status(500).json({ error: "Database error", details: err.message });
        }

        console.log("Query Results:", rows);
        res.json(rows.length > 0 ? rows : { message: "No questions found" });
    });
});


// ========================
// SUBMIT QUIZ SCORE
// ========================
app.post('/api/score', verifyToken, (req, res) => {
    const { category_id, answers } = req.body;
    const user_id = req.user.id;

    if (!category_id || !answers || !Array.isArray(answers)) {
        return res.status(400).json({ error: "Invalid request format" });
    }

    let correctAnswers = answers.filter(a => a.is_correct).length;
    let totalQuestions = answers.length;
    let score = correctAnswers * 100;
    let percentage = (correctAnswers / totalQuestions) * 100;

    const sql = "INSERT INTO scores (user_id, category_id, score, percentage) VALUES (?, ?, ?, ?)";
    db.run(sql, [user_id, category_id, score, percentage], function (err) {
        if (err) return res.status(500).json({ error: "Database error" });
        res.json({ message: "Score submitted successfully", score_id: this.lastID });
    });
});

// ========================
// GET LEADERBOARD (Excludes Admins)
// ========================
app.get('/api/leaderboard', verifyToken, (req, res) => {
    const sql = `
        SELECT users.username, IFNULL(SUM(scores.score), 0) AS total_score
        FROM users
        LEFT JOIN scores ON users.id = scores.user_id
        WHERE users.role = 'user'
        GROUP BY users.id
        ORDER BY total_score DESC
        LIMIT 10
    `;

    console.log("Executing SQL:", sql);

    db.all(sql, [], (err, rows) => {
        if (err) {
            console.error("Database error:", err.message);
            return res.status(500).json({ error: "Database error", details: err.message });
        }
        res.json(rows);
    });
});

// ========================
// ADMIN ENDPOINTS
// ========================
app.post('/api/admin/questions', verifyToken, verifyAdmin, (req, res) => {
    const { question_text, image_url, category_id, department, answers } = req.body;

    if (!question_text || !category_id || !answers || !Array.isArray(answers)) {
        return res.status(400).json({ error: "Invalid request format" });
    }

    const sql = "INSERT INTO questions (question_text, image_url, category_id, department, is_active) VALUES (?, ?, ?, ?, 1)";
    db.run(sql, [question_text, image_url, category_id, department], function (err) {
        if (err) {
            console.error("Database error:", err.message);
            return res.status(500).json({ error: "Database error", details: err.message });
        }

        const questionId = this.lastID;
        const answerSql = "INSERT INTO answers (question_id, answer_text, image_url, is_correct) VALUES (?, ?, ?, ?)";

        answers.forEach(answer => {
            db.run(answerSql, [questionId, answer.answer_text || null, answer.answer_image || null, answer.is_correct], err => {
                if (err) console.error("Error inserting answer:", err.message);
            });
        });

        res.json({ message: "Question added successfully", question_id: questionId });
    });
});

app.put('/api/admin/questions/:question_id', verifyToken, verifyAdmin, (req, res) => {
    const questionId = req.params.question_id;
    const { question_text, image_url, category_id, department, answers } = req.body;

    if (!question_text || !category_id || !answers || !Array.isArray(answers)) {
        return res.status(400).json({ error: "Invalid request format" });
    }

    const sql = "UPDATE questions SET question_text = ?, image_url = ?, category_id = ?, department = ? WHERE id = ?";
    db.run(sql, [question_text, image_url, category_id, department, questionId], function (err) {
        if (err) {
            return res.status(500).json({ error: "Database error", details: err.message });
        }

        db.run("DELETE FROM answers WHERE question_id = ?", [questionId], (err) => {
            if (err) console.error("Error deleting old answers:", err.message);
            
            const answerSql = "INSERT INTO answers (question_id, answer_text, image_url, is_correct) VALUES (?, ?, ?, ?)";
            answers.forEach(answer => {
                db.run(answerSql, [questionId, answer.answer_text || null, answer.answer_image || null, answer.is_correct], err => {
                    if (err) console.error("Error inserting answer:", err.message);
                });
            });

            res.json({ message: "Question updated successfully" });
        });
    });
});

app.put('/api/admin/toggle-game/:category_id', verifyToken, verifyAdmin, (req, res) => {
    const categoryId = req.params.category_id;
    const { is_active } = req.body;

    console.log("Updating game ID:", categoryId, "New is_active value:", is_active);

    const sql = "UPDATE quiz_categories SET is_active = ? WHERE id = ?";
    db.run(sql, [is_active, categoryId], function (err) {
        if (err) {
            console.error("Database error:", err.message);
            return res.status(500).json({ error: "Database error", details: err.message });
        }
        res.json({ message: "Game status updated successfully" });
    });
});
app.put('/api/admin/toggle-question/:question_id', verifyToken, verifyAdmin, (req, res) => {
    const questionId = req.params.question_id;
    const { is_active } = req.body;

    console.log("Updating question ID:", questionId, "New is_active value:", is_active);

    const sql = "UPDATE questions SET is_active = ? WHERE id = ?";
    db.run(sql, [is_active, questionId], function (err) {
        if (err) {
            return res.status(500).json({ error: "Database error", details: err.message });
        }
        res.json({ message: "Question status updated successfully" });
    });
});

app.get('/api/admin/user/:user_id/profile', verifyToken, verifyAdmin, (req, res) => {
    const userId = req.params.user_id;

    console.log("Fetching user performance data for ID:", userId);

    const sql = `
        SELECT q.name AS category, 
               IFNULL(SUM(s.score), 0) AS total_score, 
               IFNULL(AVG(s.percentage), 0) AS avg_percentage
        FROM scores s
        JOIN quiz_categories q ON s.category_id = q.id
        WHERE s.user_id = ?
        GROUP BY q.name
        ORDER BY avg_percentage ASC
    `;

    db.all(sql, [userId], (err, rows) => {
        if (err) {
            console.error("Database error:", err.message);
            return res.status(500).json({ error: "Database error", details: err.message });
        }

        res.json(rows.length > 0 ? rows : { message: "No performance data found" });
    });
});



const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
