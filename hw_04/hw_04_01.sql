-- Таблица Лайков
CREATE TABLE likes (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	item_id INT UNSIGNED NOT NULL,
	likes_type_id INT UNSIGNED NOT NULL,
	user_id INT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица типов лайков
CREATE TABLE like_types (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE
);

-- "маленькую" таблицу лайков, решил заполнить вручную командами CRUD
USE vk;
CREATE TABLE like_types;
INSERT INTO like_types VALUES (1, "media"), (DEFAULT, "user"), (DEFAULT, "post"), (DEFAULT, "newsline");
SELECT * FROM like_types; -- проверка, вставились ли данные

-- Для заполнения "большой" таблицы использовал сервис filldb, сохранил в дамп и импортировал заполненную таблицу в БД:
SOURCE likes_.sql;
SELECT * FROM likes; -- проверка, есть ли в таблице данные

 





