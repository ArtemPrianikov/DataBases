/*1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать
фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".*/

-- сначала проверим время произвольными значениями:
SELECT CURTIME()>'10:00'//
/*
+-------------------+
| CURTIME()>'10:00' |
+-------------------+
|                 0 |
+-------------------+*/
SELECT CURTIME()>'07:43:17'//
/*
+----------------------+
| CURTIME()>'07:43:17' |
+----------------------+
|                    1 |
+----------------------+*/

-- не смог побороть проблемы синтаксиса, но, вероятно, моя функция должна быть примерно такой:

DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT NOT DETERMINISTIC
BEGIN
	CASE (CURTIME())
		WHEN (CURTIME()>='06:00:00') AND (CURTIME()<'12:00:00') THEN
			RETURN 'Доброе утро';
		WHEN (CURTIME()>='12:00:00') AND (CURTIME()<'18:00:00') THEN
			RETURN 'Добрый день';
		WHEN (CURTIME()>='18:00:00') AND (CURTIME()<'00:00:00') THEN
			RETURN 'Добрый вечер';
		WHEN (CURTIME()>='00:00:00') AND (CURTIME()<'06:00:00') THEN
			RETURN 'Доброй ночи';
	END CASE;
END//

-- приведённый код не работает, но конкретно из-за чего - пока не разобрался, т.к. не работают и более простые конструкции:
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT NOT DETERMINISTIC
BEGIN
	RETURN 'MORNING';
END//

-- ошибка на not determenistic, я пробую убрать NOT, и тогда работает:
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT DETERMINISTIC
BEGIN
	RETURN 'MORNING';
END//

-- попробуем тогда и "главную" функцию:
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT DETERMINISTIC
BEGIN
	CASE (CURTIME())
		WHEN (CURTIME()>='06:00:00') AND (CURTIME()<'12:00:00') THEN
			RETURN 'Доброе утро';
		WHEN (CURTIME()>='12:00:00') AND (CURTIME()<'18:00:00') THEN
			RETURN 'Добрый день';
		WHEN (CURTIME()>='18:00:00') AND (CURTIME()<'00:00:00') THEN
			RETURN 'Добрый вечер';
		WHEN (CURTIME()>='00:00:00') AND (CURTIME()<'06:00:00') THEN
			RETURN 'Доброй ночи';
	END CASE;
END//
-- функция принята! ввод прошёл удачно, однако вызов - нет:

SELECT hello()//
-- ERROR 1339 (20000): Case not found for CASE statement
-- не подходит ни одно из предложенных условий? Проверим, вставив ELSE:
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT DETERMINISTIC
BEGIN
	CASE (CURTIME())
		WHEN (CURTIME()>='06:00:00') AND (CURTIME()<'12:00:00') THEN
			RETURN 'Доброе утро';
		WHEN (CURTIME()>='12:00:00') AND (CURTIME()<'18:00:00') THEN
			RETURN 'Добрый день';
		WHEN (CURTIME()>='18:00:00') AND (CURTIME()<'00:00:00') THEN
			RETURN 'Добрый вечер';
		WHEN (CURTIME()>='00:00:00') AND (CURTIME()<'06:00:00') THEN
			RETURN 'Доброй ночи';
		ELSE RETURN "ничего не найдено";
	END CASE;
END//
-- Так и есть! Условия не работают

-- проверим варианты
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT DETERMINISTIC
BEGIN
	CASE (CURTIME())
		WHEN (CURTIME()>='06:00:00') THEN
			RETURN 'Доброе утро';
		ELSE RETURN "ничего не найдено";
	END CASE;
END//

-- не работает конструкция CASE. Тогда сделаю выбор IF
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT DETERMINISTIC
BEGIN
	IF (CURTIME()>='06:00:00') THEN
			RETURN 'Доброе утро';
	END IF;
END//

-- ага, вот так работает, поэтому пока сделаю через множественные IF:
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT DETERMINISTIC
BEGIN
	IF (CURTIME()>='06:00:00') AND (CURTIME()<'12:00:00') THEN
			RETURN 'Доброе утро';
	END IF;
	IF (CURTIME()>='12:00:00') AND (CURTIME()<'18:00:00') THEN
			RETURN 'Добрый день';
	END IF;
	IF (CURTIME()>='18:00:00') AND (CURTIME()<'00:00:00') THEN
			RETURN 'Добрый вечер';
	END IF;
	IF (CURTIME()>='00:00:00') AND (CURTIME()<'06:00:00') THEN
			RETURN 'Доброй ночи';
	END IF;
END//
-- всё! Работает! Но через CASE было бы изящнее, если время останется, вернусь для усовершенствования


/*2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение 
NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
При попытке присвоить полям NULL-значение необходимо отменить операцию.*/

-- судя по условиям задачи,  нужно сделать запрет при операциях UPDATE, INSERT
/* надо посмотреть, какие ограничения на значения поля выставлены сейчас: SHOW CREATE TABLE products:
CREATE TABLE `products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Название',
  `description` text COLLATE utf8mb4_general_ci COMMENT 'Описание',
  `price` decimal(11,2) DEFAULT NULL COMMENT 'Цена',
  `catalog_id` int(10) unsigned DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `index_of_catalog_id` (`catalog_id`) */
  
-- попробуем вставим значения NULL в поле имени и описания
INSERT INTO products VALUES(DEFAULT, NULL, NULL, 2000, 5, DEFAULT, DEFAULT)//

-- Значения NULL успешно вставились, теперь будем их запрещать, создадим шаблон
DROP TRIGGER IF EXISTS nonull//
CREATE TRIGGER nonull BEFORE INSERT ON products
FOR EACH ROW	
BEGIN
END//
-- шаблон "принят", значит, в синтаксисе всё хорошо

-- Теперь пропишем запрет поля name = NULL и description = NULL при вставке:
DROP TRIGGER IF EXISTS nonull//
CREATE TRIGGER nonull BEFORE INSERT ON products
FOR EACH ROW	
BEGIN
	IF NEW.name IS NULL AND
		NEW.description IS NULL
			THEN
				SET @x = 100;
	END IF;
END//
-- пока поставил пустую заглушку: присвоение переменной какого-нибудь значения, 

-- теперь нужно поднять ошибку с предупреждением:
DROP TRIGGER IF EXISTS nonull//
CREATE TRIGGER nonull BEFORE INSERT ON products
FOR EACH ROW	
BEGIN
	IF NEW.name IS NULL AND
		NEW.description IS NULL
			THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NULL for both name and description are not allowed!';
	END IF;
END//

-- теперь попробуем вставить два NULL:
INSERT INTO products VALUES(DEFAULT, NULL, NULL, 5000, 5, DEFAULT, DEFAULT)//

/* получил "свою" ошибку ERROR 1644 (45000): NULL for both name and description are not allowed! строка со значениями не
добавилась. Попробую вставить строку, где будет только один NULL: */
INSERT INTO products VALUES(DEFAULT, 'название1', NULL, 5000, 5, DEFAULT, DEFAULT)//
-- такое значение вставилось

-- Теперь запретим UPDATE:
DROP TRIGGER IF EXISTS nonull_update//
CREATE TRIGGER nonull_update BEFORE UPDATE ON products
FOR EACH ROW	
BEGIN
	IF NEW.name IS NULL AND
		NEW.description IS NULL
			THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NULL for both name and description are not allowed!';
	END IF;
END//

-- проверим
UPDATE products SET name = NULL WHERE id = 10;
/* получил "свою" ошибку ERROR 1644 (45000): NULL for both name and description are not allowed! Значения не поменялись

создано два триггера, но должно быть какое-то универсальное решение, более изящное, чтобы в одном триггере всё объединить.
Конструкция CREATE TRIGGER nonull_update BEFORE UPDATE, INSERT ON products приводит к ошибке */

 