/*В таблице складских запасов storehouses_products в поле value могут встречаться самые
разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы.
Необходимо отсортировать записи таким образом, чтобы они выводились в порядке
увеличения значения value. Однако, нулевые запасы должны выводиться в конце, после всех
записей.*/

CREATE TABLE wh(
	name VARCHAR(100) NOT NULL PRIMARY KEY,
	qty INT UNSIGNED NOT NULL
);

DESC wh;

INSERT INTO wh (name, qty) VALUES
	('object1',0),
	('object2',2500),
	('object3',0),
	("object4",30),
	("object5", 500),
	("object6", 1)
;

SELECT * FROM wh ORDER BY FIELD (qty, 0), qty;
/* результат:
+---------+------+
| name    | qty  |
+---------+------+
| object6 |    1 |
| object4 |   30 |
| object5 |  500 |
| object2 | 2500 |
| object1 |    0 |
| object3 |    0 |
+---------+------+
