/* 1. Пусть задан некоторый пользователь. 
Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользоваетелем.*/
-- В итоговой таблице должен быть user_id пользователя и пусть будет сумма сообщение от пользователя и к пользователю
-- ради того, чтобы учесть пользователя два раза (от и кому), нам нужно сджоинить таблицу сообщений два раза

SELECT * FROM
	messages as ms
	JOIN
	messages as me;
-- получили общую таблицу, пока всё хорошо, теперь выведем для конкретного пользователя c id =66 и оставим только нужные столбцы

-- получим таблицу сообщений от него и к этому пользователю
SELECT ms.from_user_id, ms.to_user_id
	FROM
	messages as ms
	JOIN
	messages as me
	JOIN
	friendship as f
	ON f.user_id = 66
	AND
	ms.from_user_id = f.user_id
	AND
	me.to_user_id = f.user_id;	
-- тут ещё что-то не то, выводится 20 строк, должно остаться 9 (5 сообщений от пользователя + 4 к нему), попробую-ка

-- список сообщений от пользователя к другим пользователям
SELECT ms.from_user_id, ms.to_user_id
	FROM
	messages as ms
	JOIN
	friendship as f
	ON f.user_id = 66
	AND
	ms.from_user_id = f.user_id;
	
/* пока всё правильно
+--------------+------------+
| from_user_id | to_user_id |
+--------------+------------+
|           66 |         42 |
|           66 |         68 |
|           66 |         18 |
|           66 |         79 |
|           66 |         36 |
+--------------+------------+*/

-- список сообщений к пользователю от других пользователей
SELECT ms.from_user_id, ms.to_user_id
	FROM
	messages as ms
	JOIN
	friendship as f
	ON f.user_id = 66
	AND
	ms.to_user_id = f.user_id;
	
/* Тоже всё правильно
+--------------+------------+
| from_user_id | to_user_id |
+--------------+------------+
|           16 |         66 |
|           57 |         66 |
|           60 |         66 |
|           67 |         66 |
+--------------+------------+*/	

-- вообще пока без таблицы дружбы попробуем ещё
SELECT *
	FROM
	messages as ms
	JOIN
	messages as me
	ON
	ms.from_user_id = 66
	AND
	me.to_user_id = 66;
	



/* 2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.
Тут нужно джоинить таблицу лайков, таблицу профилей, начнём с простого */

SELECT *
	FROM profiles as p
	JOIN likes as li;
	
-- так как нам нужны лайкнутые пользователи, а не лайкнувшие, то нам нужно отобрать их по likes_type_id = 2
	
-- теперь попробуем просто вывести всех пользователей и общая сумма лайков по ним, а также добавим условия на джоин
SELECT p.user_id, COUNT(li.id) as likes_qty
	FROM profiles as p
	JOIN likes as li
	ON
	likes_type_id =2 -- нам нужны только лайки пользователям (это тип 2 в таблице)
	AND
	li.item_id = p.user_id -- и условие 
	GROUP BY p.user_id;
/* так получилось, я перепроверил, что в моей БД id пользователей от 1 до 100, а id лайкнувших пользователей от 1 до 1000, 
поэтому в первой сотне оказалось лишь два пользователя
+---------+-----------+
| user_id | likes_qty |
+---------+-----------+
|      94 |         1 |
|      92 |         1 |
+---------+-----------+
поэтому я заполню значениями от 1 до 100, чтобы всё было нагляднее*/

UPDATE likes SET item_id = FLOOR(1 + (RAND() * 100));

-- снова сделаем запрос
SELECT p.user_id, COUNT(li.id) as likes_qty
	FROM profiles as p
	JOIN likes as li
	ON
	likes_type_id =2 -- нам нужны только лайки пользователям (это тип 2 в таблице)
	AND
	li.item_id = p.user_id -- и условие, что джоиним только если id лайкнутого юзера и id лайкаемой сущности совпали 
	GROUP BY p.user_id;
	
/* получил уже таблицу из 32 строк:
+---------+-----------+
| user_id | likes_qty |
+---------+-----------+
|      25 |         1 |
|      64 |         1 |
|      47 |         1 |
|      50 |         1 |
|      11 |         2 |
|      79 |         1 |
|      14 |         1 |
|      77 |         1 |
|      13 |         1 |
|      78 |         1 | */

-- Теперь из этой таблицы выберем 10 самых молодых, ах, надо было ещё подгрузить из таблицы профилей дату рождения:

SELECT p.user_id, p.birthday, COUNT(li.id) as likes_qty
	FROM profiles as p
	JOIN likes as li
	ON
	likes_type_id =2
	AND
	li.item_id = p.user_id
	GROUP BY p.user_id;

/* Получил таблицу такого вида
+---------+------------+-----------+
| user_id | birthday   | likes_qty |
+---------+------------+-----------+
|      25 | 1998-11-11 |         1 |
|      64 | 2018-03-08 |         1 |
|      47 | 1988-10-24 |         1 |
|      50 | 1972-08-21 |         1 |
|      11 | 1971-06-19 |         2 |
|      79 | 1984-10-06 |         1 |*/

-- теперь отсортируем их по полю birthday

SELECT p.user_id, p.birthday, COUNT(li.id) as likes_qty
	FROM profiles as p
	JOIN likes as li
	ON
	likes_type_id =2
	AND
	li.item_id = p.user_id
	GROUP BY p.user_id
	ORDER BY birthday DESC;
	
/* наверху получил 10 самых молодых пользователей и общее кол-во лайков у каждого
+---------+------------+-----------+
| user_id | birthday   | likes_qty |
+---------+------------+-----------+
|       3 | 2018-10-26 |         1 |
|      64 | 2018-03-08 |         1 |
|     100 | 2016-07-02 |         2 |
|      78 | 2015-08-25 |         1 |
|      61 | 2007-04-25 |         1 |
|      44 | 2007-04-25 |         1 |*/

-- теперь возьмём лимит 10 верхних пользователей и попробуем просуммировать. Попробую использовать вложенный запрос:
	
SELECT SUM(likes_qty) FROM
    (SELECT COUNT(li.id) as likes_qty
    FROM profiles as p
    JOIN likes as li
    ON
    likes_type_id =2
    AND
    li.item_id = p.user_id
    GROUP BY p.user_id
    ORDER BY p.birthday DESC
    LIMIT 10) as youngest;

/* Результат получился правильный, теперь подумаем, как обойтись без вложенных запросов
возможно, мне нужен левый джоин, который соберёт все лайки, даже если пользователи повторяются
+----------------+
| SUM(likes_qty) |
+----------------+
|             11 |
+----------------+*/

-- мне не стоит использовать группировку по user_id вообще! Она тут не нужна

SELECT COUNT(li.item_id)
	FROM likes as li
	LEFT JOIN profiles as p
	ON
	likes_type_id =2
	AND
	li.item_id = p.user_id
	GROUP BY li.item_id
	ORDER BY p.birthday DESC
	LIMIT 10;

/* что-то не то, я думал, что посчитаю кол-во элементов уже с учётом лимита в 10:
+-------------------+
| COUNT(li.item_id) |
+-------------------+
|               100 |
+-------------------+
Пока продолжу делать остальные задания, а вернусь к этому, если успею
*/

	
/* 3. Определить кто больше поставил лайков (всего) - мужчины или женщины? 
тут нужно джоинить таблицу лайков и таблицу профилей
*/	

SELECT p.sex as sex, COUNT(li.id) as qty
	FROM profiles as p
	JOIN likes as li
	ON
	li.user_id = p.user_id
	GROUP BY sex;
	
/*
+-----+-----+
| sex | qty |
+-----+-----+
| m   |  49 |
| f   |  51 |
+-----+-----+*/

/* 4. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
меньше всех сообщений, лайков, медиа?

нам нужно сджоинить таблицы сообщений, лайков, медиа и посчитать сумму активностей (одно сообщение - одна активность,
один лайк - одна активность, одно медиа - одна активность) */

SELECT u.id as user, COUNT(*)
	FROM users as u
	JOIN
	media as m
	JOIN
	likes as li
	JOIN
	messages as s
	ON m.user_id = u.id
	AND li.user_id = u.id
	AND s.from_user_id = u.id
	GROUP BY user;

/*Получил промежуточную таблицу
+------+----------+
| user | COUNT(*) |
+------+----------+
|    1 |        3 |
|    2 |        1 |
|    3 |        1 |
|    4 |        1 |
|    5 |        1 |
|    7 |        1 |
|    9 |        1 |
|   14 |        4 |*/

-- теперь надо отсортировать её и вывести лимит 10

SELECT u.id as user, COUNT(*) as activity
	FROM users as u
	JOIN
	media as m
	JOIN
	likes as li
	JOIN
	messages as s
	ON m.user_id = u.id
	AND li.user_id = u.id
	AND s.from_user_id = u.id
	GROUP BY user
	ORDER BY activity
	LIMIT 10;

/* Получил нужный результат, ответ правильный
+------+----------+
| user | activity |
+------+----------+
|   17 |        1 |
|   40 |        1 |
|   51 |        1 |
|   60 |        1 |
|   74 |        1 |
|   85 |        1 |
|    2 |        1 |
|   18 |        1 |
|   41 |        1 |
|   98 |        1 |
+------+----------+*/ 



