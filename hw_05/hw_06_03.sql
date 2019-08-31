/*Подсчитайте произведение чисел в столбце таблицы*/

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

/* получил такую таблицу
+---------+-----+
| name    | qty |
+---------+-----+
| object4 |   0 |
| object5 |   0 |
| object3 |   1 |
| object6 |   2 |
| object2 |  10 |
| object1 |   5 |
+---------+-----+*/

-- функция произведения
SELECT exp(SUM(log(qty))) FROM wh3;

/* Получил нужный результат
+--------------------+
| exp(SUM(log(qty))) |
+--------------------+
| 100.00000000000004 |
+--------------------+*/
