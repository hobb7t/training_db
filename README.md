# training_db

Gia initial install  

sudo apt install sqlite3   # Ubuntu / Debian 

brew install sqlite3       # macOS 

Cd sto directory kai kaneis npm install 

 

sqlite3 database/quiz_app.db < database/sql_build_script.sql  

sqlite3 database/quiz_app.db < database/populate_questions.sql 

node server.js 

 

 

An to katebaseis ws exei apo to fakelo sto office apla pas sto server.js kai allazeis ti grammi 

 

const dbPath = "/database/quiz_app.db"; 

 

Kai vazeis to absolute path sou 

 

 

 

 

 

API tests: 

 

 

POST http://localhost:3000/api/login 

Body.RAW.Json 

{ "username": "user1", "password": "test1" } 
 

 

ta idia panw exoume kai me admin1 test1 

 

to get the token, then go to HEADERS and add new key called "Authorization" and add the value "Bearer <yourkeyhere>" 

 

GET http://localhost:3000/api/quiz/1 

Body.none 
 

make sure that HEADERS are updated as said on top of this on all of the following endpoints, as authorization is expected 

 

POST http://localhost:3000/api/score 

Body.RAW.Json 

{ 

    "category_id": 1, 

    "answers": [ 

        { "answer_id": 12, "is_correct": true }, 

        { "answer_id": 13, "is_correct": false } 

    ] 

} 

 

 

GET http://localhost:3000/api/leaderboard 

Body.none 
 

 

 

 

PUT http://localhost:3000/api/admin/toggle-game/1   <to idio ginetai me toggle-question/:question_id 

Body.RAW.Json 

{ 

    "is_active": 0 

} 

 

 
 

GET http://localhost:3000/api/admin/user/:user_id/profile 
 

Body.none 
 

edw alazoume to user id me noumero 

 
