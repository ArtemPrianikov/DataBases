/*1. Проанализировать какие запросы могут выполняться наиболее часто в процессе
работы приложения и добавить необходимые индексы.*/

-- навскидку частыми запросами могут быть:
-- 1. посмотреть друзей пользователя
-- 2. посмотреть фотографии пользователя
-- 3. посмотреть переписку с пользователем
-- 4. посмотреть, сколько лайков получила та или иная сущность, выложенная пользователем

/* сначала посмотрим какой синтаксис будет для таких запросов

посмотреть друзей пользователя. Пожалуй, это самый важный функционал, который
будет использовать не просто часто, а постоянно, ведь надо видеть всех друзей, вне
зависимости от "направления" дружбы, т.е. кто кого пригласил неважно 
"направление дружбы" - некоторая условность,
требующая дополнительных ресурсов под более громоздкие запросы*/

-- в классическом виде запрос должен выглядеть как-то так:
SELECT *
	FROM friendship
		WHERE user_id = 10
			OR friend_id = 10;

-- для такого запроса нужен индекс по сочетанию user_id_friend_id и, наверно, наоборот тоже
SELECT * FROM
	(SELECT f.user_id as friend
	FROM
	friendship as f
	WHERE friend_id = 10
	UNION
	SELECT f.friend_id as friend
	FROM
	friendship as f
	WHERE user_id = 10) as friends;
	
-- вот тут затруднения, как составить индекс, ведь, по идее тут больше двух параметров
-- мне кажется, тут нужно два индекса:
CREATE INDEX user_id_friend_id_idx ON friendship(user_id, friend_id);
CREATE INDEX friend_id_user_id_idx ON friendship(friend_id, user_id); 

-- Следующий индекс на наиболее частый запрос "посмотреть все фото пользователя"
-- вероятно, это обращение к таблице media_id, и, похоже, это индекс, показанный на уроке:
CREATE INDEX media_user_id_media_type_id_idx ON media(user_id, media_type_id);

-- посмотреть все сообщения от пользователя и к пользователю. Типичный запрос выглядит так:
EXPLAIN
SELECT *
	FROM messages
		WHERE from_user_id = 66
			OR to_user_id = 66;
			
-- индекс для ускорения таких запросов должен быть таким, или даже их должно быть два:
CREATE INDEX from_user_id_to_user_id_idx ON messages(from_user_id, to_user_id);
CREATE INDEX from_user_id_to_user_id_idx ON messages(from_user_id, to_user_id);

-- теперь сколько лайков всего имеет та или иная сущность, выложенная пользователем
SELECT * FROM likes
	WHERE user_id = 57;

-- тут, вероятно, всё просто, и индекс нужен по user_id:
CREATE INDEX user_id_idx ON likes(user_id);

/*2. Задание на денормализацию
Разобраться как построен и работает следующий запрос:
SELECT SUM(count) as overall FROM (
	SELECT
		CONCAT(u.firstname, ' ', u.lastname) as user, 
		count(l.id) as count, 
		TIMESTAMPDIFF(YEAR, p.birthday, NOW()) AS age
			FROM users AS u
	INNER JOIN profiles AS p
		ON p.user_id = u.id
	LEFT JOIN media as m
		ON m.user_id = u.id
	LEFT JOIN messages as t
		ON t.from_user_id = u.id
	LEFT JOIN likes AS l
		ON l.item_id = u.id AND l.likes_type_id = 2
		OR l.item_id = m.id AND l.likes_type_id = 1
		OR l.item_id = t.id AND l.likes_type_id = 3
	GROUP BY u.id
	ORDER BY p.birthday DESC
LIMIT 10) AS likes;

Правильно-ли он построен?
Какие изменения, включая денормализацию, можно внести в структуру БД
чтобы существенно повысить скорость работы этого запроса? */

запрос у меня не выполнился, получил ошибку:
ERROR 1054 (42S22): Unknown column 't.id' in 'on clause'
такого поля в моей таблице вообще не существует ('id'), есть поля from_user_id, to_user_id
пока не буду править таблицу, т.к. задачи на денормализацию можно выполнить и так
запрос, вероятно, должен считать сумму лайков по каждому пользователю, лайков, поставленных
всем сущностям: сообщения, медиа, профиль. Затем выводить 10 самых "старых" пользователей

вообще, этот запрос связывает целых 5 таблиц: users, media, messages, profiles, likes
вероятно, это будет "тяжёлый" запрос, и чтобы облегчить его, 
следует создать представление для промежуточной таблицы, которая достаточно
часто может использоваться, это запрос, в котором связываются все сущности,
ассоциированные с пользователем
Таким образом, представление должно быть примерно таким:

CREATE VIEW users_things AS SELECT
	FROM users AS u
	INNER JOIN profiles AS p
		ON p.user_id = u.id
	LEFT JOIN media as m
		ON m.user_id = u.id
	LEFT JOIN messages as t
		ON t.from_user_id = u.id;

а также нужны индексы на столбцы 'id' в таблице users, т.к.
по нему происходит связывание большинства сущностей в таком запросе, и обращение
к этому полю происходит аж 5 раз!

CREATE INDEX user_id_idx ON users(id);