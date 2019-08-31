/*Из таблицы извлекаются записи при помощи запроса. SELECT * FROM
catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.*/


CREATE TABLE wh3(
	name VARCHAR(100) NOT NULL PRIMARY KEY,
	qty INT UNSIGNED NOT NULL
);


INSERT INTO wh3 (name, qty) VALUES
	('object1',5),
	('object2',10),
	('object3',1),
	("object4",0),
	("object5", 0),
	("object6", 2)
;

SELECT * FROM wh3 WHERE qty IN (5, 1, 2) ORDER BY qty;