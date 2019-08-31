/*Подсчитайте средний возраст пользователей в таблице users*/


-- создаём таблицу пользователей с возрастами
CREATE TABLE users (
	name VARCHAR(100) NOT NULL PRIMARY KEY,
	age INT UNSIGNED NOT NULL
);

-- вставляем значения
INSERT INTO users (name,age) VALUES
	('Tom', 39),
	('Julia', 38),
	('Diana', 4),
	('Alex', 35),
	('Elizabeth', 7)
;

-- выводим среднее по столбцу
SELECT AVG (age) FROM users;

/* ответ:
+-----------+
| AVG (age) |
+-----------+
|   24.6000 |
+-----------+*/
