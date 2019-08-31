/*Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их
текущими датой и временем.*/


-- Создаём таблицу, содержащую поля 

CREATE DATABASE hw_01;
USE hw_01;
CREATE TABLE dates (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	created_at DATETIME,
	updated_at DATETIME
);

INSERT INTO dates SET created_at = CURRENT_TIMESTAMP; /*сформировался элемент под id 1, заполненным оказался только столбец created_at, а другой NULL */
INSERT INTO dates SET updated_at = CURRENT_TIMESTAMP; /*сформировался элемент под id 2, заполненным оказался только столбец updated_at, а другой NULL */

INSERT INTO dates (created_at, updated_at) VALUES (CURRENT_TIMESTAMP, CURRENT_TIMESTAMP); /*сформировался элемент под id 3, заполненным оказались оба столбца на этот раз */

-- всё-таки надо исправить ситуацию с NULL
UPDATE dates SET updated_at = CURRENT_TIMESTAMP WHERE id = 1; 
UPDATE dates SET created_at = CURRENT_TIMESTAMP WHERE id = 2; 

-- попробую вставить новый элемент
INSERT INTO dates SET id = 5;
UPDATE dates SET created_at = CURRENT_TIMESTAMP; -- применяю ко всему столбцу
UPDATE dates SET updated_at = CURRENT_TIMESTAMP; -- применяю ко всему столбцу
