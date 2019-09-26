-- Создание таблиц и наполнение их данными

CREATE DATABASE booking;
USE booking;


-- 1. Создаём таблицу для основной сущности - отели
CREATE TABLE hotels (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    hotel_type_id INT UNSIGNED NOT NULL,
    name VARCHAR(50), -- разрешим отелям не указывать своё имя, если они думают, что так они привлекут больше народа
    stars INT UNSIGNED, -- звёзды существуют не для всех отелей, и не для любых, поэтому NULL разрешён
    description TEXT NOT NULL
); -- описание отеля
    

-- заполняю таблицу значениями c помощью сервиса filldb, вставил 2000 строк, т.е. будет 2000 отелей
INSERT INTO hotels
	(id, hotel_type_id, name, stars, description)
VALUES
	INSERT INTO `hotels` (`id`, `hotel_type_id`, `name`, `stars`, `description`) VALUES (1, 5, 'inventore', 5, 'Sunt voluptatem mollitia velit temporibus consequatur. Natus voluptates voluptatem quidem quisquam. Accusamus aut dicta maxime.');
	INSERT INTO `hotels` (`id`, `hotel_type_id`, `name`, `stars`, `description`) VALUES (2, 4, 'neque', 3, 'Nobis corporis quisquam commodi velit nihil. Aliquid modi nemo sint corporis. Porro quis in odio consectetur molestias. Ut provident dolores impedit iusto sequi sed temporibus.');
	INSERT INTO `hotels` (`id`, `hotel_type_id`, `name`, `stars`, `description`) VALUES (3, 5, 'dolores', 1, 'Quae placeat quidem ab ut aut rem ea. Voluptatem dolore est aut. Ex dolorem quia et.');
 -- всего 2 тыс. строк, см. дамп booking.sql */ 

 
 
    
-- 2. таблица описания типов отельных сущностей
CREATE TABLE hotel_types (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
); -- (hotel, motel, hostel, appartment, villa, chalet, and etc.)  

-- вставляем значения в таблицу типов отельных сущностей
INSERT INTO hotel_types
  (id, name)
VALUES
  (1, 'hotel'),
  (2, 'motel'),
  (3, 'hostel'),
  (4, 'appartment'),
  (5, 'villa'),
  (6, 'chalet')
;



-- 3. таблица для хранения стран
CREATE TABLE countries (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE
);	

-- скрипт наполнения таблицы стран:
INSERT INTO `countries` (`id`, `name`) VALUES (2, 'Albania');
INSERT INTO `countries` (`id`, `name`) VALUES (20, 'Andorra');
INSERT INTO `countries` (`id`, `name`) VALUES (3, 'Antigua and Barbuda');
-- ... и т.д.
-- отдельно хочу установить несколько стран: Russian Federation, USA, Thailand, France,
-- Germany, Italy, Spain, Ukraine, Finland, они не попали при генерации на filldb
INSERT INTO countries
  (id, name)
VALUES
  (46, 'Russian Federation'),
  (47, 'China'),
  (48, 'Thailand'),
  (49, 'France'),
  (50, 'Germany'),
  (51, 'Italy'),
  (52, 'Spain'),
  (53, 'Ukraine'),
  (54, 'England')
;




-- 4. таблица для хранения городов
CREATE TABLE cities (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	country_id INT UNSIGNED NOT NULL,
	name VARCHAR(50) NOT NULL
);

-- проверка, сколько городов в каждой стране
SELECT co.name as country_name, COUNT(ci.id) as cities_qty
	FROM
		countries as co
	JOIN
		cities as ci
	ON ci.country_id = co.id
GROUP by country_name;	

-- пожалуй, вручную добавлю ещё известные города, чтобы было легче тестировать
INSERT INTO cities
  (id, country_id, name)
VALUES
  (201, 47, 'Moscow'),
  (202, 47, 'Saint-Petersburg'),
  (203, 47, 'Sochi'),
  (204, 47, 'Novosibirsk'),
  (205, 47, 'Ekaterinburg'),
  (206, 48, 'Bangkok'),
  (207, 48, 'Koh Samui'),
  (208, 48, 'Chiang Mai'),
  (209, 48, 'Pattaya'),
  (210, 54, 'London'),
  (211, 54, 'Boston'),
  (212, 54, 'Birmingham'),
  (213, 50, 'Berlin'),
  (214, 50, 'Bonn'),
  (215, 50, 'Munchen'),
  (216, 33, 'New York'),
  (217, 33, 'Los Angeles'),
  (218, 33, 'Washington'),
  (219, 51, 'Rome'),
  (220, 51, 'Milan'),
  (221,	47, 'Beijing'),
  (222, 47, 'Shanghai')
;




-- 5. таблица адресов отелей    
CREATE TABLE adress_details (
    hotel_id INT UNSIGNED NOT NULL PRIMARY KEY,
    region VARCHAR(50),
    street VARCHAR(100),
    building INT UNSIGNED NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL, -- для сервисов геолокации координаты
    longitude DECIMAL(11, 8) NOT NULL -- для сервисов геолокации координаты
);
-- заполнял эту таблицу через filldb:
INSERT INTO `adress_details` (`hotel_id`, `region`, `street`, `building`, `latitude`, `longitude`) VALUES (1, 'Colorado', 'Joshua Park', 613, '44.16699200', '74.48775600');
INSERT INTO `adress_details` (`hotel_id`, `region`, `street`, `building`, `latitude`, `longitude`) VALUES (2, 'Maine', 'Sawayn Passage', 9708, '-80.09179500', '114.13889500');
INSERT INTO `adress_details` (`hotel_id`, `region`, `street`, `building`, `latitude`, `longitude`) VALUES (3, 'Maryland', 'Stella Manors', 4696, '-35.23422600', '69.28608300');
-- .... и т.д всего 10 тысяч записей (по кол-ву отелей) см. дамп booking.sql

-- позднее вставил столбцы country_id, city_id:
ALTER TABLE `adress_details`
	ADD 
    country_id INT UNSIGNED NOT NULL;
    
ALTER TABLE `adress_details`
	ADD     
    city_id INT UNSIGNED NOT NULL;
    
-- итого код таблицы выглядит вот так
CREATE TABLE adress_details (
    hotel_id INT UNSIGNED NOT NULL PRIMARY KEY,
    country_id INT UNSIGNED NOT NULL,
    city_id INT UNSIGNED NOT NULL,
    region VARCHAR(50),
    street VARCHAR(100),
    building INT UNSIGNED NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL, -- для сервисов геолокации координаты
    longitude DECIMAL(11, 8) NOT NULL -- для сервисов геолокации координаты
);
-- заполнил заново сервисом filldb:
INSERT INTO `adress_details` (`hotel_id`, `country_id`, `city_id`, `region`, `street`, `building`, `latitude`, `longitude`) VALUES (1, 16, 149, 'District of Columbia', 'Letha Light', 46014, '22.40478400', '172.81408500');
INSERT INTO `adress_details` (`hotel_id`, `country_id`, `city_id`, `region`, `street`, `building`, `latitude`, `longitude`) VALUES (2, 27, 47, 'Georgia', 'Jaskolski Motorway', 40397, '-88.94311700', '-127.48431600');
-- см. дамп booking.sql





-- 6. таблица для номеров
CREATE TABLE rooms (
	id INT UNSIGNED NOT NULL PRIMARY KEY,
	hotel_id INT UNSIGNED NOT NULL,
	room_type_id INT UNSIGNED NOT NULL,
	room_level_id INT UNSIGNED NOT NULL,
	single_beds_qty INT UNSIGNED NOT NULL, -- сюда надо навесить триггер, который не позволит
	double_beds_qty INT UNSIGNED NOT NULL, -- добавлять кровати обе = 0
	max_persons_qty INT UNSIGNED NOT NULL
);

-- заполнял сервисом filldb
INSERT INTO `rooms` (`id`, `hotel_id`, `room_type_id`, `room_level_id`, `single_beds_qty`, `double_beds_qty`, `max_persons_qty`) VALUES (1, 310, 2, 2, 1, 1, 3);
INSERT INTO `rooms` (`id`, `hotel_id`, `room_type_id`, `room_level_id`, `single_beds_qty`, `double_beds_qty`, `max_persons_qty`) VALUES (2, 85, 2, 3, 1, 1, 4);
INSERT INTO `rooms` (`id`, `hotel_id`, `room_type_id`, `room_level_id`, `single_beds_qty`, `double_beds_qty`, `max_persons_qty`) VALUES (3, 607, 3, 1, 1, 1, 1);
-- ... и т.д., всего 8000 записей

-- решил не создавать отдельную таблицу для скидок и цен номеров, а добавить ещё один столбец в таблицу
ALTER TABLE `rooms`
	ADD     
    price_per_day INT UNSIGNED NOT NULL;

-- заполняю этот столбец случайными данными:
UPDATE rooms SET price_per_day = FLOOR(1000 + (RAND() * 10000));



-- 7. теперь нужна таблица для хранения разных типов номеров
CREATE TABLE room_types (
	id INT UNSIGNED NOT NULL PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE  -- single, double, tripple, common
);

-- заполнял вручную:
INSERT INTO room_types
  (id, name)
VALUES
  (1, 'single'),
  (2, 'double'),
  (3, 'tripple'),
  (4, 'common');





-- 8. таблица хранения уровня номера
CREATE TABLE room_levels (
	id INT UNSIGNED NOT NULL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE -- Luxe, DeLuxe, VIP, 
);

INSERT INTO room_levels
  (id, name)
VALUES
  (1, 'basic'),
  (2, 'luxe'),
  (3, 'deluxe'),
  (4, 'vip');




-- 9. таблица для хранения характеристик номеров
CREATE TABLE room_details_types (
	id INT UNSIGNED NOT NULL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
); 

-- заполняем характеристики номеров вручную
INSERT INTO room_details_types
  (id, name)
VALUES
  (1, 'conditioner'),
  (2, 'wifi'),
  (3, 'shower'),
  (4, 'toilet'),
  (5, 'tv'),
  (6, 'boiler'),
  (7, 'frig'),
  (8, 'balcony'),
  (9, 'towels'),
  (10, 'gel_soap'),
  (11, 'smoking'),
  (12, 'table'),
  (13, 'chairs'),
  (14, 'wardrobe'),
  (15, 'iron'),
  (16, 'hair_dryer');



-- 10. как лучше хранить данные о характеристиках каждой комнаты? Я решил, что наиболее экономным способом
-- будет таблица, где будет указан только тот тип удобств, который есть в номере
-- если в номере этих удобств нет, то мы просто их не упонимаем в таблице:	

CREATE TABLE room_details (
	room_id INT UNSIGNED NOT NULL,
	room_details_type_id INT UNSIGNED NOT NULL
);

-- первичный ключ создам по комбинации номера комнаты + типа характеристики
-- заполняем на сервисе filldb:
INSERT INTO `room_details` (`room_id`, `room_details_type_id`) VALUES (7948, 7);
INSERT INTO `room_details` (`room_id`, `room_details_type_id`) VALUES (4953, 2);
INSERT INTO `room_details` (`room_id`, `room_details_type_id`) VALUES (7193, 16);
-- ... и т.д. всего 40 тыс. строк. 

-- создадим первичный ключ по сочетанию полей 
ALTER TABLE room_details ADD PRIMARY KEY(room_id, room_details_type_id);
  
  
  
-- 11. таблица типов контактов, чтобы в дальнейшем хранить их в одном поле дочерней таблицы
CREATE TABLE contact_types (
	id INT UNSIGNED NOT NULL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE);  -- skype, whatsapp, phone, email, facebook

-- заполнял вручную:
INSERT INTO contact_types
  (id, name)
VALUES
  (1, 'phone'),
  (2, 'email'),
  (3, 'whatsapp'),
  (4, 'skype'),
  (5, 'viber');




-- 12. таблица для хранения контактов, пока заполним всё номерами телефонов, потом поправим
CREATE TABLE contacts (
	hotel_id INT UNSIGNED NOT NULL,
	contact_type_id INT UNSIGNED NOT NULL,
	contact VARCHAR(50) NOT NULL
); -- skype, whatsapp, phone, email
-- заполнил сервисом filldb, пока везде стоят только номера телефонов, позднее надо поменять
-- там где скайп и имейл
-- создаём первичный ключ по комбинации полей, чтобы не плодить лишних данных
ALTER TABLE contacts ADD PRIMARY KEY(contact_type_id,contact);



-- 13. создаём таблицу для хранения данных о фотографиях.
CREATE TABLE photos (
	id INT UNSIGNED NOT NULL PRIMARY KEY,
	hotel_id INT UNSIGNED NOT NULL,
	filename VARCHAR(255) NOT NULL UNIQUE 
);

-- заполним таблицу на сайте filldb, пришлось заполняеть имя файла неуникальными значениями, т.к. сервис не даёт столько
INSERT INTO `photos` (`id`, `hotel_id`, `filename`) VALUES (1, 354, 'accusantium');
INSERT INTO `photos` (`id`, `hotel_id`, `filename`) VALUES (2, 1287, 'voluptatem');
-- и т.д, всего 75986



-- 15. теперь таблица пользователей сервиса
CREATE TABLE users (
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    country_id INT UNSIGNED NOT NULL,
    city_id INT UNSIGNED NOT NULL,
	street VARCHAR(100),
    building INT UNSIGNED NOT NULL,
    appartm INT UNSIGNED
);
-- заполнил сервисом filldb всего 200 значений
INSERT INTO `users` (`id`, `country_id`, `city_id`, `street`, `building`, `appartm`) VALUES (1, 28, 99, 'Billie Rapid', 73111, 43);
INSERT INTO `users` (`id`, `country_id`, `city_id`, `street`, `building`, `appartm`) VALUES (2, 51, 25, 'Cleve Plain', 2791, 45);
INSERT INTO `users` (`id`, `country_id`, `city_id`, `street`, `building`, `appartm`) VALUES (3, 29, 125, 'Yundt Rapid', 30269, 21);
-- и т.д.


-- чтобы не создавать громоздкие таблицы, часть информации решено вывести в отдельную таблицу    
CREATE TABLE user_profiles (
	user_id INT UNSIGNED NOT NULL PRIMARY KEY,
	firstname VARCHAR(100) NOT NULL,
	lastname VARCHAR(100) NOT NULL,
	sex CHAR(1),
	email VARCHAR(100) NOT NULL UNIQUE,
	phone VARCHAR(100) NOT NULL UNIQUE,
    birthday_at DATE,
    created_at DATETIME DEFAULT NOW(),
    language VARCHAR(100)
);
-- тут по-хорошему надо создавать и таблицы для языков, но пусть пока так
-- заполнил сервисом filldb всего 200 значений:
INSERT INTO `user_profiles` (`user_id`, `firstname`, `lastname`, `sex`, `email`, `phone`, `birthday_at`, `created_at`, `language`) VALUES (1, 'Kavon', 'Toy', 'm', 'dexter25@example.com', '1-776-921-8860x02130', '1989-01-29', '2012-12-28 01:35:00', 'nihil');
INSERT INTO `user_profiles` (`user_id`, `firstname`, `lastname`, `sex`, `email`, `phone`, `birthday_at`, `created_at`, `language`) VALUES (2, 'Keaton', 'McLaughlin', 'f', 'maegan.ortiz@example.net', '09148124272', '2004-09-05', '1992-01-14 01:41:14', 'vitae');
-- и т.д.


-- 16. одна из главных таблиц, в которой будут храниться бронирования. Т.к она будет обновляться
-- очень часто, возможно, в ней стоит оставить минимум столбцов 
CREATE TABLE bookings (
	id INT UNSIGNED NOT NULL PRIMARY KEY, -- придётся ввести индексный первичный ключ
	user_id INT UNSIGNED NOT NULL,
	room_id INT UNSIGNED NOT NULL,
	people_qty INT UNSIGNED NOT NULL,
	check_in_at DATETIME NOT NULL,
	check_out_at DATETIME NOT NULL
);
/* надо будет причесать эту таблицу, привести данные в более-менее логичный вид:
- данные о заезде должны частично относиться к прошлому (до 26 сентября 2019), частично к будущему,
чтобы можно было проверить работоспособность БД
- разные люди могут бронировать одну и ту же комнату, при случайном заполнении данных
такое може произойти. Это будет возможно только для отеля типа "хостел", и если не
-- превышается максимально возможное кол-во людей в комнате */


-- залил данные сервисом filldb всего 1000 строк:
INSERT INTO `bookings` (`id`, `user_id`, `room_id`, `people_qty`, `check_in_at`, `check_out_at`) VALUES (1, 192, 7714, 4, '2016-07-30 13:10:02', '2018-02-25 03:36:47');
INSERT INTO `bookings` (`id`, `user_id`, `room_id`, `people_qty`, `check_in_at`, `check_out_at`) VALUES (2, 34, 5903, 2, '1989-11-03 07:34:22', '1979-04-13 03:01:58');
INSERT INTO `bookings` (`id`, `user_id`, `room_id`, `people_qty`, `check_in_at`, `check_out_at`) VALUES (3, 156, 5334, 4, '1974-05-07 21:25:01', '2012-11-12 18:43:42');
-- см. файл дамп БД

-- обновлю даты на реалистичные, пусть в таблице содержится информация как о прошлых бронированиях, так и о будущих
UPDATE bookings SET check_in_at = DATE_ADD('2019-09-01 13:28:17', INTERVAL FLOOR(1 + (RAND() * 50)) DAY);
UPDATE bookings SET check_out_at = DATE_ADD(check_in_at, INTERVAL FLOOR(1 + (RAND() * 10)) DAY);



	
-- 17. таблица отзывов по отелям	    
CREATE TABLE reports (
	id INT UNSIGNED NOT NULL PRIMARY KEY,
	user_id INT UNSIGNED NOT NULL,
	hotel_id INT UNSIGNED NOT NULL,
	report TEXT NOT NULL,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- заполнял на сайте filldb:
INSERT INTO `reports` (`id`, `user_id`, `hotel_id`, `report`, `mark`, `created_at`, `updated_at`) VALUES (1, 164, 1352, 'Alice, a good deal frightened by this time, and was gone in a day did you begin?\' The Hatter was out of the officers of the Shark, But, when the White Rabbit interrupted: \'UNimportant, your Majesty.', 3, '2006-06-24 19:17:33', '1988-02-20 17:25:37');
INSERT INTO `reports` (`id`, `user_id`, `hotel_id`, `report`, `mark`, `created_at`, `updated_at`) VALUES (2, 105, 1909, 'Said he thanked the whiting kindly, but he could go. Alice took up the fan and the turtles all advance! They are waiting on the door began sneezing all at once. \'Give your evidence,\' said the.', 4, '1999-01-24 01:36:15', '1977-06-13 03:22:39');
-- и т.д., всего 400 отзывов




-- 18. таблица для хранения характеристик отеля
CREATE TABLE hotel_detail_types (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);
-- заполняем вручную:
INSERT INTO hotel_detail_types
  (id, name)
VALUES
  (1, 'taxi'),
  (2, 'restaurant'),
  (3, 'transfer'),
  (4, 'breakfast'),
  (5, 'basin'),
  (6, 'baggage_store'),
  (7, 'parking'),
  (8, 'cleaning'),
  (9, 'massage'),
  (10, 'exchange'),
  (11, 'smoking_area'),
  (12, 'car_rent')
;

-- 19. таблица, в которой будут храниться принадлежащие конкретному номеру характеристики
CREATE TABLE hotel_details (
	hotel_id INT UNSIGNED NOT NULL,
	hotel_detail_type_id INT UNSIGNED NOT NULL
);

-- сформировал 10 тысяч строк сервисом filldb:
INSERT INTO `hotel_details` (`hotel_id`, `hotel_detail_type_id`) VALUES (1860, 8);
INSERT INTO `hotel_details` (`hotel_id`, `hotel_detail_type_id`) VALUES (329, 8);
INSERT INTO `hotel_details` (`hotel_id`, `hotel_detail_type_id`) VALUES (1007, 11);
-- и т.д., всего 10 тысяч строк

пришлось удалить неуникальные сочетания:
CREATE TABLE hotel_details_temp SELECT DISTINCT * FROM hotel_details;
DROP TABLE hotel_details;
RENAME TABLE hotel_details_temp TO hotel_details;
-- осталось 8233 строк
-- позднее будет создан триггер на запрет неуникальных сочетаний

-- теперь, когда остались только уникальные, можно создать PRIMARY KEY:
ALTER TABLE hotel_details ADD PRIMARY KEY(hotel_id, hotel_detail_type_id);

	
	
	
-- 20. таблица для хранения оценок сервисам отеля	
CREATE TABLE marks (
	hotel_id INT UNSIGNED NOT NULL,
	user_id INT UNSIGNED NOT NULL,
	breakfast INT(2) UNSIGNED NOT NULL,
	personnell INT(2) UNSIGNED NOT NULL,
	comfort_details INT(2) UNSIGNED NOT NULL,
	free_wifi INT(2) UNSIGNED NOT NULL,
	place INT(2) UNSIGNED NOT NULL,
	price_to_quality INT(2) UNSIGNED NOT NULL,
	clearness INT(2) UNSIGNED NOT NULL,
	comfort INT(2) UNSIGNED NOT NULL,
	total_mark INT(2) UNSIGNED NOT NULL -- это поле нужно сделать вычисляемым?
);
-- заполним основную часть с помощью сервиса filldb:
INSERT INTO `marks` (`hotel_id`, `user_id`, `breakfast`, `personnell`, `comfort_details`, `free_wifi`, `place`, `price_to_quality`, `clearness`, `comfort`, `total_mark`) VALUES (177, 182, 1, 3, 4, 6, 1, 10, 2, 1, 3);
INSERT INTO `marks` (`hotel_id`, `user_id`, `breakfast`, `personnell`, `comfort_details`, `free_wifi`, `place`, `price_to_quality`, `clearness`, `comfort`, `total_mark`) VALUES (1049, 44, 1, 1, 5, 5, 9, 10, 6, 5, 5);
-- и т.д, всего 1000 строк
-- теперь у меня уже 20 таблиц, пожалуй, пока достаточно, основной функционал уже охвачен

-- Позднее добавил столбец с первичным ключом
alter table marks add column `id` int unsigned primary KEY AUTO_INCREMENT;
-- и код создания таблицы стала выглядеть так:
CREATE TABLE marks (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	hotel_id INT UNSIGNED NOT NULL,
	user_id INT UNSIGNED NOT NULL,
	breakfast INT(2) UNSIGNED NOT NULL,
	personnell INT(2) UNSIGNED NOT NULL,
	comfort_details INT(2) UNSIGNED NOT NULL,
	free_wifi INT(2) UNSIGNED NOT NULL,
	place INT(2) UNSIGNED NOT NULL,
	price_to_quality INT(2) UNSIGNED NOT NULL,
	clearness INT(2) UNSIGNED NOT NULL,
	comfort INT(2) UNSIGNED NOT NULL,
	total_mark INT(2) UNSIGNED NOT NULL -- это поле нужно сделать вычисляемым?
);



-- 21.
-- приведём в таблице adress_details данные адресов к логике и заполним значения country_id
-- правильными значениями, как они указаны в таблице cities
UPDATE adress_details
	SET adress_details.country_id = (SELECT cities.country_id FROM cities
		WHERE adress_details.city_id = cities.id);

