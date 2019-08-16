/* Добавить необходимую таблицу/таблицы для того, чтобы можно было использовать лайки для медиафайлов, постов и пользователей.*/

-- ПЕРВЫЙ СПОСОБ --
/* Создать сквозной список лайкаемых сущностей, чтобы юзеры, медиа, посты получили общую единую таблицу со своим первичным ключом для каждого элемента. Тогда можно лайкать лайкайемую сущность по её id */

/* Сначала нужна таблица-список типов сущностей, которые лайкают: пост, медиа, пользователь. Следовательно, записей будет три */
CREATE TABLE likeable_item_types (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE
);


/* в этой таблице каждой лайкаемой сущности создаётся свой уникальный id*/
CREATE TABLE likeable_items (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	likeable_item_type_id INT UNSIGNED NOT NULL
);


/* Таблица лайков будет содержать юзера и id лайкаемой сущности, которой может быть то, что определено в таблице likeable_items*/
CREATE TABLE likes (
	user_id INT UNSIGNED NOT NULL PRIMARY KEY,			/* Это юзер, который лайкнул, ссылаемся на таблицу пользователей */
	likeable_item_id INT UNSIGNED NOT NULL,					/* Это сущность, которую можно лайкнуть, см. таблицу */
	PRIMARY KEY (user_id, likeable_item_id)
);	

-- ВТОРОЙ СПОСОБ --
/* сделать отдельную таблицу на каждый вид лайкайемой сущности: для медиа, юзеров, сообщений */

CREATE TABLE media_likes (
	user_id INT UNSIGNED NOT NULL,
	media_id INT UNSIGNED NOT NULL,					
	PRIMARY KEY (user_id, media_id)
);	


CREATE TABLE user_likes (
	user_id INT UNSIGNED NOT NULL,
	liked_user_id INT UNSIGNED NOT NULL,				
	PRIMARY KEY (user_id, liked_user_id)
);	


CREATE TABLE post_likes (
	user_id INT UNSIGNED NOT NULL,	
	post_id INT UNSIGNED NOT NULL,					
	PRIMARY KEY (user_id, post_id)
);	

