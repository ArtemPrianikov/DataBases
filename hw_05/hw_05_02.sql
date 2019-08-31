/*Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы
типом VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10".
Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения*/



-- Создаём таблицу
CREATE DATABASE hw_02;
USE hw_02;
CREATE TABLE che (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	created_at VARCHAR(100),
	updated_at VARCHAR(100)
);
-- вставил даты в строковом формате
INSERT INTO che(created_at, updated_at) VALUES ("23.05.2019 8:10", "20.10.2017 8:10");
INSERT INTO che(created_at, updated_at) VALUES ("02.01.2019 8:10", "19.11.2011 8:10");

-- перепроверил формат вставленных данных:
SHOW CREATE TABLE che;

-- Получил такое:
| che   | CREATE TABLE `che` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `created_at` varchar(100) DEFAULT NULL,
  `updated_at` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 |

-- формат отображения в столбцах привёл из строки в формат даты:
UPDATE che SET created_at = STR_TO_DATE (created_at,'%d.%m.%Y %h:%i');
UPDATE che SET updated_at = STR_TO_DATE (updated_at,'%d.%m.%Y %h:%i');

-- Проверка
SELECT * FROM che;
/* 
+----+---------------------+---------------------+
| id | created_at          | updated_at          |
+----+---------------------+---------------------+
|  1 | 2019-05-23 08:10:00 | 2017-10-20 08:10:00 |
|  2 | 2019-01-02 08:10:00 | 2011-11-19 08:10:00 |
+----+---------------------+---------------------+



