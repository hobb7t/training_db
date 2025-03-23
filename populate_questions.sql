-- Insert Admin
INSERT INTO users (username, password, role, department) VALUES
('admin1', 'test1', 'admin', 'Management');

-- Insert Test Users (Each department)
INSERT INTO users (username, password, role, department) VALUES
('user1', 'test1', 'user', 'Warehouse'),
('user2', 'test1', 'user', 'Cyber Security'),
('user3', 'test1', 'user', 'Office'),
('user4', 'test1', 'user', 'Logistics');


INSERT INTO quiz_categories (name, is_active) VALUES
('Manual Handling', 1),
('Working at Height', 1),
('Hazard Perception', 1),
('Unsafe Acts', 1),
('Cyber Awareness', 1);

INSERT INTO questions (question_text, image_url, category_id, department, is_active) VALUES
('Is lifting with your back straight and knees bent the safest way to lift heavy objects?', NULL, 1, 'ALL', 1),
('Should you maintain three points of contact when climbing a ladder?', NULL, 2, 'ALL', 1),
('Are blocked Emergency Exits considered a safety hazard?', NULL, 3, 'ALL', 1),
('Taking shortcuts often lead to workplace accidents?', NULL, 4, 'ALL', 1),
('Can weak passwords be easily guessed or cracked by hackers?', NULL, 5, 'ALL', 1);

-- Answers for "Is lifting with your back straight and knees bent the safest way to lift heavy objects?"
INSERT INTO answers (question_id, answer_text, image_url, is_correct) VALUES
(1, 'True', NULL, 1),
(1, 'False', NULL, 0);

-- Answers for "Should you maintain three points of contact when climbing a ladder?"
INSERT INTO answers (question_id, answer_text, image_url, is_correct) VALUES
(2, 'True', NULL, 1),
(2, 'False', NULL, 0);

-- Answers for "Which fire extinguisher should you use on an electrical fire?"
INSERT INTO answers (question_id, answer_text, image_url, is_correct) VALUES
(6, 'CO2', NULL, 1),
(6, 'Water', NULL, 0);

-- Image-based Question: "Which is the appropriate way to pick an object from the ground?"
INSERT INTO answers (question_id, answer_text, image_url, is_correct) VALUES
(10, NULL, 'https://example.com/image1.jpg', 1),
(10, NULL, 'https://example.com/image2.jpg', 0);
