/* 1. Составьте список пользователей users, которые осуществили
хотя бы один заказ orders в интернет магазине.*/

-- создаю и наполняю таблицы
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id)
) COMMENT = 'Заказы';

-- заполним таблицу orders, вставим id пользователей, делавших заказы в интернет-магазине
INSERT INTO orders (user_id) VALUES 
	(12), (17), (5), (15), (1), (23), (17), (6), (12), (15);

-- получим таблицу пользователей, хотя бы однажды сделавших заказ:
SELECT user_id FROM orders GROUP BY user_id;

-- или вот так, покороче:
SELECT DISTINCT user_id FROM orders;
/*
+---------+
| user_id |
+---------+
|       1 |
|       5 |
|       6 |
|      12 |
|      15 |
|      17 |
|      23 |
+---------+*/

-- теперь нужно к этой таблице подгрузить имена из таблицы users:
SELECT user_id, u.name as 'имя'
	FROM 
	(SELECT DISTINCT user_id FROM orders) as o
		INNER JOIN users as u ON u.id=o.user_id;
			
/* Ответ правильный, т.к. в моей таблице users заполнены имена только для id: 12, 15, 17	
+---------+------------------+
| user_id | имя              |
+---------+------------------+
|      12 | Геннадий         |
|      15 | Сергей           |
|      17 | Мария            |
+---------+------------------+
*/

-- через левый джоин по-прежнему можно видеть все user_id заказчиков, но не по всем будут имена
SELECT user_id, u.name as 'имя'
	FROM 
	(SELECT DISTINCT user_id FROM orders) as o
		LEFT JOIN users as u ON u.id=o.user_id;
/*
+---------+------------------+
| user_id | имя              |
+---------+------------------+
|       1 | NULL             |
|       5 | NULL             |
|       6 | NULL             |
|      12 | Геннадий         |
|      15 | Сергей           |
|      17 | Мария            |
|      23 | NULL             |
+---------+------------------+*/

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT p.name, c.name as 'категория'
	FROM products as p
	INNER JOIN catalogs as c ON c.id=p.catalog_id;
/*
+-------------------------+----------------------+
| name                    | категория            |
+-------------------------+----------------------+
| Intel Core i3-8100      | Процессоры           |
| Intel Core i5-7400      | Процессоры           |
| AMD FX-8320E            | Процессоры           |
| AMD FX-8320             | Процессоры           |
| ASUS ROG MAXIMUS X HERO | Мат.платы            |
| Gigabyte H310M S2H      | Мат.платы            |
| MSI B250M GAMING PRO    | Мат.платы            |
+-------------------------+----------------------+
*/

/* 3. Пусть имеется таблица рейсов flights (id, from, to) и 
таблица городов cities (label, name). Поля from, to и label содержат английские названия городов,
поле name — русское. Выведите список рейсов flights с русскими названиями городов*/

-- создаю таблицу полётов
CREATE TABLE flights (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`from` CHAR(50) NOT NULL,
	`to` CHAR(50) NOT NULL
);
	
-- наполняю таблицу полётов значениями
INSERT INTO flights (id, `from`, `to`) VALUES
	(DEFAULT, 'moscow', 'omsk'),
	(DEFAULT, 'novgorod', 'kazan'),
	(DEFAULT, 'irkutsk', 'moscow'),
	(DEFAULT, 'omsk', 'irkutsk'),
	(DEFAULT, 'moscow', 'kazan');

-- создаю таблицу городов
CREATE TABLE cities (
	label CHAR(50) NOT NULL,
	name CHAR(50) NOT NULL);

-- наполняю таблицу городов
INSERT INTO cities (label, name) VALUES
	('moscow', 'Москва'),
	('novgorod', 'Новгород'),
	('irkutsk', 'Иркутск'),
	('omsk', 'Омск'),
	('kazan', 'Казань');

-- сначала научимся доставать хотя бы часть данных
SELECT `from`, (SELECT name FROM cities WHERE label=`from`) as 'ОТКУДА' FROM flights;
/* 
+----------+------------------+
| from     | ОТКУДА           |
+----------+------------------+
| moscow   | Москва           |
| novgorod | Новгород         |
| irkutsk  | Иркутск          |
| omsk     | Омск             |
| moscow   | Москва           |
+----------+------------------+
*/

-- Теперь нужно подгрузить также и данные для поля "куда", и убрать англоязычные названия
SELECT
	(SELECT name FROM cities WHERE label=`from`) as 'ОТКУДА',
	(SELECT name FROM cities WHERE label=`to`) as 'КУДА'
		FROM flights;

/* результат:
+------------------+----------------+
| ОТКУДА           | КУДА           |
+------------------+----------------+
| Москва           | Омск           |
| Новгород         | Казань         |
| Иркутск          | Москва         |
| Омск             | Иркутск        |
| Москва           | Казань         |
+------------------+----------------+
*/

-- Теперь с JOIN:
-- сначала по отдельности
SELECT f.from, c.name as 'откуда'
	FROM flights as f
		INNER JOIN 
			cities as c
				ON c.label=f.from;
/* Выводится перевод одного столбца
+----------+------------------+
| from     | откуда           |
+----------+------------------+
| moscow   | Москва           |
| moscow   | Москва           |
| novgorod | Новгород         |
| irkutsk  | Иркутск          |
| omsk     | Омск             |
+----------+------------------+
*/

SELECT f.to, c.name as 'куда'
	FROM flights as f
		INNER JOIN cities as c
			ON c.label=f.to;

/*	Выводится перевод одного столбца
+---------+----------------+
| to      | куда           |
+---------+----------------+
| moscow  | Москва         |
| irkutsk | Иркутск        |
| omsk    | Омск           |
| kazan   | Казань         |
| kazan   | Казань         |
+---------+----------------+
*/

/* теперь надо оба столбца вместе, оставив только русскоязычные, но вот тут у меня что-то не получается объединить
вывод по аналогии со сложными запросами. я планировал только заменить вложенные запросы 
в уже сработавшем у меня варианте (см. выше) на запросы с JOIN, но это не сработало */
SELECT
(SELECT f.from, c.name as 'откуда'
	FROM flights as f
		INNER JOIN cities as c
			ON c.label=f.from) as city_from,
(SELECT f.to, c.name as 'куда'
	FROM flights as f
		INNER JOIN cities as c
			ON c.label=f.to) as city_to;
-- этот вариант не сработал

/* объединил данные в одну большую таблицу, в которой таблица label-name повторялась бы дважды в каждой строке*/
SELECT * FROM
	flights
	JOIN cities AS city_from 
	JOIN cities AS city_to

/* Теперь из этой таблицы можно фильтровать значения как для города отправления, так и назначения
+----+----------+---------+----------+------------------+----------+------------------+
| id | from     | to      | label    | name             | label    | name             |
+----+----------+---------+----------+------------------+----------+------------------+
|  1 | moscow   | omsk    | moscow   | Москва           | moscow   | Москва           |
|  2 | novgorod | kazan   | moscow   | Москва           | moscow   | Москва           |
|  3 | irkutsk  | moscow  | moscow   | Москва           | moscow   | Москва           |
|  4 | omsk     | irkutsk | moscow   | Москва           | moscow   | Москва           |
|  5 | moscow   | kazan   | moscow   | Москва           | moscow   | Москва           |
|  1 | moscow   | omsk    | novgorod | Новгород         | moscow   | Москва           |	*/

SELECT 
	city_from.name AS `ОТКУДА`,
	city_to.name AS `КУДА` 
	FROM flights
	JOIN cities AS city_from 
	JOIN cities AS city_to
    ON city_from.label = flights.from AND city_to.label = flights.to;





