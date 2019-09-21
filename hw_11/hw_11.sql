/*Тема 9 “Оптимизация запросов”
Тема 10 “NoSQL”
Практическое задание тема №9
1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах
users, catalogs и products в таблицу logs помещается время и дата создания записи, 
название таблицы, идентификатор первичного ключа и содержимое поля name.*/

-- вероятно, здесь надо использовать триггеры. Триггер будет отслеживать
-- создание записей в таблицах и должен применяться ПОСЛЕ действий

-- начнём с создания таблицы logs
CREATE TABLE IF NOT EXISTS logs (
   date_time DATETIME DEFAULT CURRENT_TIMESTAMP,
   tab_name VARCHAR(100) NOT NULL,
   prim_key VARCHAR(100) NOT NULL,
   text_name VARCHAR(100) NOT NULL
 ) ENGINE=Archive;

DELIMITER //
DROP TRIGGER IF EXISTS add_log1//
CREATE TRIGGER add_log1 AFTER INSERT ON products
FOR EACH ROW	
BEGIN
	IF NEW.name IS NOT NULL
		THEN
			INSERT INTO logs(tab_name, prim_key, text_name)
				VALUES ('products', NEW.id, NEW.name); 
	END IF;
END//

-- проверка:
INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Cooler ATX-300', 'Description', 1000.00, 10)//

SELECT * FROM logs//
/* всё работает!
+---------------------+----------+----------+----------------+
| date_time           | tab_name | prim_key | text_name      |
+---------------------+----------+----------+----------------+
| 2019-09-20 17:31:54 | products | 13       | Cooler ATX-300 |
+---------------------+----------+----------+----------------+*/

-- создадим триггеры на остальные таблицы
DROP TRIGGER IF EXISTS add_log2//
CREATE TRIGGER add_log2 AFTER INSERT ON catalogs
FOR EACH ROW	
BEGIN
	IF NEW.name IS NOT NULL
		THEN
			INSERT INTO logs(tab_name, prim_key, text_name)
				VALUES ('catalogs', NEW.id, NEW.name); 
	END IF;
END//

DROP TRIGGER IF EXISTS add_log3//
CREATE TRIGGER add_log3 AFTER INSERT ON users
FOR EACH ROW	
BEGIN
	IF NEW.name IS NOT NULL
		THEN
			INSERT INTO logs(tab_name, prim_key, text_name)
				VALUES ('users', NEW.id, NEW.name); 
	END IF;
END//


/*2. Создайте SQL-запрос, который помещает в таблицу users миллион 
записей.*/

-- вероятно, нужен цикл? В чате, однако, прозвучало, что надо обойтись без процедур,
-- однако, не сказано, что надо обойтись без триггеров. В таком случае, нужно создать
-- триггер, в котором будут вставляться строки по циклу

-- сначала создадим таблицу, в которую будем добавлять данные
CREATE TABLE IF NOT EXISTS million_rows (
   id INT NOT NULL);

-- пусть он будет срабатывать при вставке новой строки в любую таблицу, например, products

DELIMITER //
DROP TRIGGER IF EXISTS x//
CREATE TRIGGER x AFTER INSERT ON products
FOR EACH ROW
BEGIN
	DECLARE counter INT DEFAULT 1;
		WHILE counter <= 1000000 DO
			INSERT INTO million_rows(id)
				VALUES (counter);
			SET counter = counter + 1;
		END WHILE;
END//
-- вот такой триггер принят системой, по команде SHOW TRIGGERS доступен для просмотра

-- 
INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Trigger', 'Description', 2000.00, 11)//

-- проверка:
SELECT * FROM million_rows LIMIT 20//
/*
+----+
| id |
+----+
|  1 |
|  2 |
|  3 |
|  4 |
|  5 |
|  6 |
|  7 |
|  8 |
|  9 |
| 10 |
| 11 |
| 12 |
| 13 |
| 14 |
| 15 |
| 16 |
| 17 |
| 18 |
| 19 |
| 20 |*/
+----+

SELECT * FROM million_rows WHERE id = 1000000//
/*
+---------+
| id      |
+---------+
| 1000000 |
+---------+*/

/*Практическое задание тема №10
1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных 
IP-адресов.*/

-- вообще пока не понятно, зачем здесь нужна коллекция, если всё можно сделать проще:
MSET 207.180.240.231 7 46.4.96.137 2 176.9.119.170 5 188.225.9.121 1 87.103.234.116 9

-- Также, если бы впоследствии можно было бы применять агрегационные функции, то тогда
-- было бы достаточно просто журнала айпи-адресов, с которых осуществялся вход:
LPUSH ips 207.180.240.231 46.4.96.137 176.9.119.170 188.225.9.121 87.103.234.116 35.178.70.89 176.9.119.170 188.225.9.121 176.9.119.170 188.225.9.121 87.103.234.116 94.244.191.219 207.154.231.211 88.198.50.103 88.198.24.108
-- проверка:
LRANGE ips 0 -1
-- в таком варианте подсчёт повторяемости айпи-адреса можно было бы перенести в приложение
-- или, если redis допускает агрегационные запросы, применить их
-- тогда нужен тип "список", т.к. адреса будут и должны повторяться и только так их можно будет посчитать

-- тем не менее, лично для меня более понятна структура хэш-таблиц, где допускается
-- несколько ключей:

HMSET ip1 ip_adr 207.180.240.231 visits 1
HMSET ip2 ip_adr 46.4.96.137 visits 1
HMSET ip3 ip_adr 176.9.119.170 visits 3

-- пока не знаю, чем это чревато, но, вероятно, можно было сделать и такую структуру:
HMSET ips ip1 207.180.240.231 visits1 1 ip2 46.4.96.137 visits 3 ip3 176.9.119.170 visits 2

-- также есть идея создать отсортированное множество с индексами, где индексами сможет выступать
-- кол-во посещений:
ZADD ip_log 1 "207.180.240.231" 3 "46.4.96.137" 2 "176.9.119.170"
-- но в этом случае если несколоько айпи-адресов имеют одинаковое кол-во посещений,
-- то тогда нужно будет добавлять новые ай-пи в значение через пробел или другой разделитель:
ZADD ip_log 1 "207.180.240.231 188.225.9.121" 3 "46.4.96.137" 2 "176.9.119.170"

/*2. При помощи базы данных Redis решите задачу поиска имени пользователя по 
электронному адресу и наоборот, поиск электронного адреса пользователя по его имени.*/

сначала создадим данные:
MSET Andrew and@x.ru Tom tom@x.ru Diana dia@x.ru Julia jul@x.ru Alex alx@x.ru Michael mch@x.ru

127.0.0.1:6379[1]> GET Tom
"tom@x.ru"
-- мы можем получить значение по ключу, но не ключ по значению. Тогда 
-- наверное, нужен хэш-тип. В этом случае наименование 

HSET Natalie email "nat@x.ru" name 'Natalie'
-- в этом случае доступ к электронной почте будет такой:
HGET Natalie email
-- но опять нет доступа по содержанию поля к ключу

-- опять есть идея использовать сортированное множество, надо разместить данные в двух
-- сортированных множествах с одинаковыми индексами

ZADD user_names 1 Andrew 2 Tom 3 Diana 4 Julia 5 Alex
ZADD user_emails 1 and@x.ru 2 tom@x.ru 3 dia@x.ru 4 jul@x.ru 5 alx@x.ru
-- В этом случае весь сценарий будет таким: сначала выясняем индекс:
ZSCORE user_names Tom
-- получаем индекс "2", теперь по этому индексу обращаемся к множеству, где хранятся имейлы:
ZRANGE user_emails 1 1 -- т.к. с нуля начинаются индексы, то указывая 1, мы берём 2й элемент
-- при поиске имени по имейлу делаем всё наоборот:
ZSCORE user_emails dia@x.ru
ZRANGE user_names 2 2

/*3. Организуйте хранение категорий и товарных позиций учебной базы данных 
shop в СУБД MongoDB.*/

-- так как это не реляционная БД, то, вероятно, имеет смысл сделать всё в одной таблице: и продукты, и их категории
db.shop.insert({id: '1', name:'Intel Core i3-8100', description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', price: '7890.00', category: '1'}) 
db.shop.insert({id: '2', name:'Intel Core i5-7400', description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', price: '12700.00', category: '1'}) 
db.shop.insert({id: '3', name:'AMD FX-8320E', description: 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', price: '4780.00', category: '1'}) 
db.shop.insert({id: '4', name:'AMD FX-8320', description: 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', price: '7120.00', category: '1'}) 
db.shop.insert({id: '5', name:'ASUS ROG MAXIMUS X HERO', description: 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', price: '19310.00', category: '2'}) 
db.shop.insert({id: '6', name:'Gigabyte H310M S2H', description: 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', price: '4790.00', category: '2'}) 
db.shop.insert({id: '7', name:'MSI B250M GAMING PRO', description: 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', price: '5060.00', category: '2'}) 

-- Это похоже на таблицу EXCEL, на которую можно выставлять фильтры на столбцы:
db.shop.find({category:'2'}) -- показывает все товары 2й категории
db.shop.find({price: '5060.00'}) -- показывает товары с ценой 5060.00

