-- скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы)


/* в таблице бронирований в строках хранятся только фактические бронирования (чем и хороша
реляционная модель, что можно хранить только то, что надо хранить), поэтому базовым подзапросом
будет определение отелей, занятых на указанный диапазон дат и, наоборот, свободных */

-- например, нам нужны все несвободные номера с 2019-09-25 10:00:00 по 2019-09-29 13:00:00
SELECT room_id FROM bookings
	WHERE DATE(check_in_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00'
			OR DATE(check_out_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00';

	
-- теперь получим все свободные номера на указанные даты
SELECT * FROM rooms
	WHERE id NOT IN
		(SELECT room_id FROM bookings
			WHERE DATE(check_in_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00'
			OR DATE(check_out_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00');

				
-- теперь получим все свободные номера на указанные даты для 3х человек:
SELECT * FROM rooms
	WHERE max_persons_qty>=3
	AND id NOT IN
		(SELECT room_id FROM bookings
			WHERE DATE(check_in_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00'
			OR DATE(check_out_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00');


-- теперь свяжем таблицы hotels, rooms, adress_details, cities:
SELECT 	r.id as room,
		h.name as hotel_name,
		a.country_id as country_id,
		c.name as city_name
	FROM rooms as r
		JOIN hotels as h
			ON r.hotel_id = h.id
		JOIN adress_details as a
			ON h.id = a.hotel_id
		JOIN cities as c
			ON c.id = a.city_id
		WHERE c.name = "Moscow";
-- показывает все номера города Moscow


-- теперь получим все свободные номера на указанные даты для 3х человек для города Москва
SELECT * FROM
	(SELECT r.id as room,
		h.name as hotel_name,
		a.country_id as country_id,
		c.name as city_name
	FROM rooms as r
		JOIN hotels as h
			ON r.hotel_id = h.id
		JOIN adress_details as a
			ON h.id = a.hotel_id
		JOIN cities as c
			ON c.id = a.city_id
		WHERE c.name = "Moscow"
		AND r.max_persons_qty>=3
		AND r.id NOT IN
		(SELECT room_id FROM bookings
			WHERE DATE(check_in_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00'
			OR DATE(check_out_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00')) as nomera;

-- получим 5 самых дешёвых предложений для нас на указанные даты в городе Москва для 3х человек:
SELECT * FROM
	(SELECT r.id as room,
		h.name as hotel_name,
		c.name as city_name,
		r.price_per_day as price
	FROM rooms as r
		JOIN hotels as h
			ON r.hotel_id = h.id
		JOIN adress_details as a
			ON h.id = a.hotel_id
		JOIN cities as c
			ON c.id = a.city_id
		WHERE c.name = "Moscow"
		AND r.max_persons_qty>=3
		AND r.id NOT IN
		(SELECT room_id FROM bookings
			WHERE DATE(check_in_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00'
			OR DATE(check_out_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00')) as nomera
		ORDER BY price
		LIMIT 5;

-- во сколько всего нам обойдётся весь отдых в самом дешёвом отеле (номере) в Москве для троих
-- на выбранные даты
SELECT * FROM
	(SELECT
		h.name as hotel_name,
		c.name as city_name,
		r.price_per_day *
			(SELECT CEILING(TIMEDIFF('2019-09-29 13:00:00','2019-09-25 10:00:00')/240000))
				as price -- вычисляем кол-во дней бронирования с округление в большую сторону
	FROM rooms as r
		JOIN hotels as h
			ON r.hotel_id = h.id
		JOIN adress_details as a
			ON h.id = a.hotel_id
		JOIN cities as c
			ON c.id = a.city_id
		WHERE c.name = "Moscow"
		AND r.max_persons_qty>=3
		AND r.id NOT IN
		(SELECT room_id FROM bookings
			WHERE DATE(check_in_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00'
			OR DATE(check_out_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00')) as nomera
		ORDER BY price
		LIMIT 1;

-- в какую страну лучше всего полететь в отпуске, где самые низкие цены на размещение
-- на выбранные даты. Выведем 5 лучших направлений по ценам отелей
SELECT * FROM
	(SELECT
		co.name,
		r.price_per_day *
			(SELECT CEILING(TIMEDIFF('2019-09-29 13:00:00','2019-09-25 10:00:00')/240000))
				as price
	FROM rooms as r
		JOIN hotels as h
			ON r.hotel_id = h.id
		JOIN adress_details as a
			ON h.id = a.hotel_id
		JOIN countries as co
			ON co.id = a.country_id
		JOIN cities as c
			ON c.id = a.city_id
		WHERE r.max_persons_qty>=3
		AND r.id NOT IN
		(SELECT room_id FROM bookings
			WHERE DATE(check_in_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00'
			OR DATE(check_out_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00')) as nomera
		ORDER BY price
		LIMIT 5;

-- средняя цена за номер отелей города London для одного человека на выбранные даты
SELECT * FROM
	(SELECT
		h.name as hotel_name,
		c.name as city_name,
		AVG(r.price_per_day) as price
	FROM rooms as r
		JOIN hotels as h
			ON r.hotel_id = h.id
		JOIN adress_details as a
			ON h.id = a.hotel_id
		JOIN cities as c
			ON c.id = a.city_id
		WHERE c.name = "London"
		AND r.id NOT IN
		(SELECT room_id FROM bookings
			WHERE DATE(check_in_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00'
			OR DATE(check_out_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00')
		GROUP BY hotel_name) as nomera;


-- Получим на карте (координаты) все отели города Bangkok, в которых можно разместиться 3м человекам
-- на выбранные даты
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
			ON c.id = a.city_id
		WHERE r.max_persons_qty>=3
		AND c.name = "Bangkok"
		AND r.id NOT IN
		(SELECT room_id FROM bookings
			WHERE DATE(check_in_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00'
			OR DATE(check_out_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00')) as nomera;


-- Посмотреть все фотографии выбранного отеля:
SELECT * FROM photos WHERE hotel_id = 100;

-- найдём 10 самых активных пользователей сети, чтобы предложить им скидки. Будем определять
-- таких пользователей по кол-ву ПРОШЛЫХ бронирований
SELECT * FROM bookings WHERE check_out_at < NOW(); -- это прошлые бронирования до текущего дня

-- развитие запроса:
SELECT user_id, COUNT(room_id) as bookings_qty FROM
	(SELECT * FROM bookings WHERE check_out_at < NOW()) AS broni
		GROUP BY user_id
			ORDER BY bookings_qty DESC
				LIMIT 10;

-- Найти все номера, где есть кондиционеры, парковка и где можно разместиться 2 человекам
-- в выбранные даты в городе Saint-Petersburg

SELECT * FROM
	(SELECT
		r.id as room,
		h.id as hotel_id,
		h.name as hotel_name,
		c.name as city_name
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
			ON hd.hotel_detail_type_id = hdt.id
		WHERE r.max_persons_qty>=2
			AND c.name = "Saint-Petersburg"
			AND hdt.name = 'parking'
			AND rdt.name = 'conditioner'
			AND r.id NOT IN
		(SELECT room_id FROM bookings
			WHERE DATE(check_in_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00'
			OR DATE(check_out_at) BETWEEN
		'2019-09-25 10:00:00' AND '2019-09-29 13:00:00')) as nomera;
