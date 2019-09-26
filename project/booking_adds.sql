/* Индексы, представления, процедуры/триггеры */

-- ---------------------------- ИНДЕКСЫ
-- исходя из практики запросов, наиболее частые обращения происходят к полю room_id таблицы rooms,
-- hotel_id таблицы hotels, user_id таблицы users, city_id таблицы cities, country_id таблицы countries
-- таким образом, можно будет ускорить большинство типичных запросов к подобной БД

-- 1. room_id таблицы rooms:
CREATE INDEX room_id_idx ON rooms(id);


-- 2. hotel_id таблицы hotels
CREATE INDEX hotel_id_idx ON hotels(id);


-- 3. user_id таблицы users
CREATE INDEX user_id_idx ON users(id);


-- 4. city_id таблицы cities
CREATE INDEX city_id_idx ON cities(id);


-- 5. country_id таблицы countries
CREATE INDEX country_id_idx ON countries(id);


-- 6. составной индекс на сочетание городов и стран, чтобы ускорить связывания в таких запросах:
CREATE INDEX country_id_city_id_idx ON cities(id,country_id);


-- 7. составной индекс координаты отеля, чтобы ускорить вывод на карту:
CREATE INDEX country_id_city_id_idx ON cities(id,country_id);

-- ---------------------------- ТРИГГЕРЫ

-- 1. Запрет добавлять в БД номер, в котором кол-во кроватей равно нулю. в номере может быть
-- от 0 до 2 односпальных кроватей и от 0 до 2 двуспальных кроватей. Но если обе кровати равно ноль
-- это неправильно, нужно защитить БД от подобного, таблица выглядит так:

CREATE TABLE rooms (
	id INT UNSIGNED NOT NULL PRIMARY KEY,
	hotel_id INT UNSIGNED NOT NULL,
	room_type_id INT UNSIGNED NOT NULL,
	room_level_id INT UNSIGNED NOT NULL,
	single_beds_qty INT UNSIGNED NOT NULL, -- сюда надо навесить триггер, который не позволит
	double_beds_qty INT UNSIGNED NOT NULL, -- добавлять кровати обе = 0
	max_persons_qty INT UNSIGNED NOT NULL -- по идее, это поле надо вычисляемым, а пока заполнено случайно
);

-- код триггера
DELIMITER //
DROP TRIGGER IF EXISTS beds//
CREATE TRIGGER beds BEFORE INSERT ON rooms
FOR EACH ROW	
BEGIN
	IF NEW.single_beds_qty = 0 AND
		NEW.double_beds_qty = 0
			THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Minimum one bed in the room!';
	END IF;
END//
DELIMITER ;

-- проверка триггера:
INSERT INTO `rooms` (`id`, `hotel_id`, `room_type_id`, `room_level_id`, `single_beds_qty`, `double_beds_qty`, `max_persons_qty`, `price_per_day`) VALUES (8008, 310, 2, 2, 0, 0, 3, 1000);


-- 2. Триггер для защиты таблицу room_details от создания характеристики номера, которая уже существует
DELIMITER //
DROP TRIGGER IF EXISTS room_detail_tr//
CREATE TRIGGER room_detail_tr BEFORE INSERT ON room_details
FOR EACH ROW	
BEGIN
	IF CONCAT(NEW.room_details_type_id, '-', NEW.room_id)
		IN
			(SELECT CONCAT(room_details_type_id, '-', room_id)
				FROM room_details)
			THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'already exists for this room!';
	END IF;
END//
DELIMITER ;

-- проверка:
INSERT INTO `room_details` (`room_id`, `room_details_type_id`) VALUES (7948, 7);
-- запланированная ошибка появляется



-- 3. Триггер для защиты таблицы hotel_details от создания характеристики отеля, которая уже существует
DELIMITER //
DROP TRIGGER IF EXISTS hotel_detail_tr//
CREATE TRIGGER hotel_detail_tr BEFORE INSERT ON hotel_details
FOR EACH ROW	
BEGIN
	IF CONCAT(NEW.hotel_detail_type_id, '-', NEW.hotel_id)
		IN
			(SELECT CONCAT(hotel_detail_type_id, '-', hotel_id)
				FROM hotel_details)
			THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'already exists for this hotel!';
	END IF;
END//
DELIMITER ;


-- проверка:
INSERT INTO `hotel_details` (`hotel_id`, `hotel_detail_type_id`) VALUES (1860, 8);
-- запланированная ошибка появляется



-- ---------------------------- ПРЕДСТАВЛЕНИЯ

-- 1. самые типичные представления - где надо "очеловечить" информацию, т.е. показать названия вместо
-- бездушных id индексов

CREATE VIEW hotels_cities_countries AS
SELECT 
	h.name as hotel_name, ci.name as city, co.name as country
	FROM
		hotels as h
	JOIN
		adress_details as a -- пробраться к городу и стране отеля можно только через эту таблицу
			ON h.id = a.hotel_id
	JOIN
		cities as ci
			ON ci.id = a.city_id
	JOIN
		countries as co
			ON co.id = a.country_id;



-- 2. представление для показа отелей на карте (координаты). Из этого представления впоследствии
-- удобно делать запросы с фильтром по городам
CREATE VIEW hotels_on_map AS
SELECT * FROM
	(SELECT DISTINCT
		h.name as hotel_name,
		a.latitude as latitude,
		a.longitude as longitude,
		c.name as city_name
	FROM rooms as r
		JOIN hotels as h
			ON r.hotel_id = h.id
		JOIN adress_details as a
			ON h.id = a.hotel_id
		JOIN cities as c
			ON c.id = a.city_id) as map;


-- 3. представление для запросов с множеством фильтров по характеристикам номера и отелей:
SELECT * FROM
	(SELECT
		r.id as room,
		h.id as hotel_id,
		h.name as hotel_name,
		c.name as city_name,
		
	FROM rooms as r
		JOIN hotels as h
			ON r.hotel_id = h.id
		JOIN adress_details as a
			ON h.id = a.hotel_id
		JOIN cities as c
			ON c.id = a.city_id
		JOIN room_details as rd
			ON rd.room_id = r.id
		JOIN room_details_types as rdt
			ON rdt.id = rd.room_details_type_id
		JOIN hotel_details as hd
			ON hd.hotel_id = h.id
		JOIN hotel_detail_types as hdt
			ON hd.hotel_detail_type_id = hdt.id) as all_info;
-- из него фильтрами на характеристики номеров, отелей можно доставать нужные выборки




-- ---------------------------- ПРОЦЕДУРЫ

-- лотерея среди пользователей сервиса. Случайным образом выбирается пользователь, который
-- что-то в будущем получит (скидки или привилегии обслуживания):

DELIMITER //
DROP PROCEDURE IF EXISTS lottery//
CREATE PROCEDURE lottery()
BEGIN
	SET @users_qty = (SELECT COUNT(*) FROM users);
	SET @winner = FLOOR(1 + (RAND() * @users_qty));
END//
DELIMITER ;	

SELECT @winner;

/*
+---------+
| @winner |
+---------+
|      49 |
+---------+*/