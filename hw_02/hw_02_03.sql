-- создал Базу Данных (см. скриншоты по 1му заданию)

-- открыл файл .my.cnf и вставил [client] вместо [mysql]

-- В терминале сохранил (сделал дамп) созданную на предыдущем этапе БД example 
mysqldump example > example_backup.sql

-- Зашёл в mysql
CREATE DATABASE sample;
USE sample;
SOURCE example_backup.sql;

-- проверил что новая таблица похожа на "старую", с которой сделан dump
SHOW TABLES;
DESCRIBE users;
SELECT * FROM users;

-- Попробовал другим способом развернуть БД из дампа, зашёл в mysql:
CREATE DATABASE sample2;

-- Затем в баше:
mysql sample2 < example_backup.sql

-- проверил что новая таблица похожа на "старую", с которой сделан dump
SHOW TABLES;
DESCRIBE users;
SELECT * FROM users;