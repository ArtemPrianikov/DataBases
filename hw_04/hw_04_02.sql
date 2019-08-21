-- "маленькую" таблицу лайков, решил заполнить вручную командами CRUD
USE vk;
CREATE TABLE like_types;
INSERT INTO like_types VALUES (1, "media"), (DEFAULT, "user"), (DEFAULT, "post"), (DEFAULT, "newsline");
SELECT * FROM like_types; -- проверка, вставились ли данные

-- Для заполнения "большой" таблицы использовал сервис filldb, сохранил в дамп и импортировал заполненную таблицу в БД:
SOURCE likes_.sql;
SELECT * FROM likes; -- проверка, есть ли в таблице данные