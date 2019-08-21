-- отработка команд CRUD

-- На предыдущем этапе (задание 2) вставил значения в таблицу like_types c помощью команды INSERT
USE vk;
CREATE TABLE like_types;
INSERT INTO like_types VALUES (1, "media"), (DEFAULT, "user"), (DEFAULT, "post"), (DEFAULT, "newsline");
SELECT * FROM like_types; -- проверка, вставились ли данные

-- добавил новое значение в таблицу
INSERT INTO like_types SET name = "community"
SELECT * FROM like_types; -- проверка, внеслись ли новые значения

-- вставка значения в таблицу с использованием IGNORE
INSERT IGNORE INTO like_types SET name = "community";
SHOW WARNINGS; -- Просмотр предупреждения о дубликате

-- вставка значений в определённый столбец
INSERT INTO like_types (name) VALUES
	('object1'), ('object2'), ('object3');
	
-- попробовал REPLACE: 
REPLACE INTO like_types (name) VALUES ('community');
SELECT * FROM like_types; -- после выполнения команды, id 'community' изменился

/* уникальные строки (так ведь если у нас таблица хотя бы в 1й нормальной форме, то строки должны быть уникальными? */
SELECT DISTINCT * FROM like_types;

-- использование LIMIT
SELECT ALL * FROM like_types LIMIT 1; -- получил значение "community"
SELECT ALL * FROM like_types LIMIT 1; -- во второй запрос тоже получил значение "community"
SELECT ALL * FROM like_types LIMIT 1; -- в третий запрос тоже получил значение "community"

-- в гугле подсмотрел, как выбрать значения по маске:
SELECT * FROM like_types WHERE name LIKE 'obj%' -- получил инфу только по тем полям, имя которых начинается с "obj"
SELECT * FROM like_types; 

-- Команда UPDATE 
UPDATE like_types SET name = "xxx"; -- попробовал заменить все имена в таблице на xxx
-- получил ошибку ERROR 1062 (23000): Duplicate entry 'xxx' for key 'name'
-- это произошло из-за того, что после того, как было переименовано первое значение, второе похожее уже является дубликатом
UPDATE IGNORE like_types SET name = "xxx"; -- одно значение переименовалось
SHOW WARNINGS; -- получил 7 предупреждений о дубликате

-- обновление по условию
UPDATE like_types SET name = 'group' WHERE name = 'community'; -- переименовал community в group
UPDATE like_types SET name = 'thing' WHERE name LIKE 'obj%';
/* Опять получил ошибку ERROR 1062 (23000): Duplicate entry 'thing' for key 'name' */
UPDATE IGNORE like_types SET name = 'thing' WHERE name LIKE 'obj%';
/* вот теперь одно из подходящих по маске значений переименовалось а по двум другим - предупреждения*/

-- удаление по условию
DELETE FROM like_types WHERE ID>10; -- хочу удалить все записи с id меньше 10... Сработало!
DELETE FROM like_types WHERE name = 'xxx' OR name = 'thing'; -- в гугле подсмотрел, что можно использовать OR
DELETE FROM like_types WHERE name LIKE 'obj%' -- удаляю значения по маске

-- удаляю записи
TRUNCATE like_types;
INSERT INTO like_types VALUES (DEFAULT, 'media'); -- вставилась с индексом 1


-- удаление слимитом LIMIT
DELETE FROM like_types LIMIT 1;
