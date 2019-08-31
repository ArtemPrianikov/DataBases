/*Из таблицы users необходимо извлечь пользователей, родившихся в августе и
мае. Месяцы заданы в виде списка английских названий ('may', 'august')*/

-- создаём таблицу пользователей с возрастами
CREATE TABLE users2 (
	name VARCHAR(100) NOT NULL PRIMARY KEY,
	birth_month VARCHAR(20) NOT NULL
);

-- вставляем значения
INSERT INTO users2 (name, birth_month) VALUES
	('Tom', "june"),
	('Julia', "july"),
	('Diana', "september"),
	('Alex', "august"),
	('Elizabeth', "may")
;

/* необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы в виде списка английских названий ('may', 'august')
*/
-- первый способ
SELECT * FROM users2 WHERE birth_month IN ("august", "may");

-- ВТОРОЙ способ
SELECT * FROM users2 WHERE birth_month = "august" OR birth_month = "may";

