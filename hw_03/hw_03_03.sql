-- Ревёрс-инжинирнг социальной сети вКонтакте

-- Таблица пользователей
CREATE TABLE users (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	firstname VARCHAR(100) NOT NULL,
	lastname VARCHAR(100) NOT NULL,
	email VARCHAR(120) NOT NULL UNIQUE,
	phone VARCHAR(120) NOT NULL UNIQUE,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);


-- Таблица для фото --
CREATE TABLE photos (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
);


-- Таблица профилей
CREATE TABLE profiles (
	user_id INT UNSIGNED NOT NULL PRIMARY KEY,
	birthday DATE,
	sex CHAR(1) NOT NULL,
	hometown VARCHAR(100),
	photo_id INT UNSIGNED NOT NULL
);


-- Таблица сообщений
CREATE TABLE messages (
	from_user_id INT UNSIGNED NOT NULL,
	to_user_id INT UNSIGNED NOT NULL,
	BODY TEXT NOT NULL,
	importance BOOLEAN,
	delivered BOOLEAN,
	created_at DATETIME DEFAULT NOW(),
	PRIMARY KEY (from_user_id, created_at)
);


-- Таблица дружбы
CREATE TABLE friendship (
	user_id INT UNSIGNED NOT NULL,
	friend_id INT UNSIGNED NOT NULL,
	status VARCHAR(20) NOT NULL,
	requested_at DATETIME DEFAULT NOW(),
	confirmed_at DATETIME,
	PRIMARY KEY (user_id, friend_id)	
);


-- Таблица для групп
CREATE TABLE communities (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE
);


-- Таблица связей пользователей и групп
CREATE TABLE comminities_users (
	community_id INT UNSIGNED NOT NULL,
	user_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (community_id, user_id)
);


-- Таблица для типов медиа
CREATE TABLE media_types (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE
);


-- Таблица для медиа
CREATE TABLE media (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	media_type_id INT UNSIGNED NOT NULL,
	user_id INT UNSIGNED NOT NULL,
	filename VARCHAR(255) NOT NULL,
	size INT NOT NULL,
	metadata JSON,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

/* Сначала нужна таблица-список типов сущностей, которые лайкают: пост, медиа, пользователь. Следовательно, записей в такой таблице будет три */
CREATE TABLE likeable_item_types (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE
);


/* в этой таблице каждой лайкаемой сущности создаётся свой уникальный id*/
CREATE TABLE likeable_items (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	likeable_item_type_id INT UNSIGNED NOT NULL
);


/* Таблица лайков будет содержать юзера и id лайкаемой сущности в таблице likeable_items*/
CREATE TABLE likes (
	user_id INT UNSIGNED NOT NULL,
	likeable_item_id INT UNSIGNED NOT NULL,	
	PRIMARY KEY (user_id, likeable_item_id)
);	
