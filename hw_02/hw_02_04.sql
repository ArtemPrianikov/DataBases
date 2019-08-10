-- В баше набрал команду:
mysqldump --opt mysql help_keyword --where="1 limit 100" > rows1
00.sql 

-- В результате получил файл rows100.sql

-- Зашёл mysql
CREATE DATABASE mysql rows100bd table100rows < rows100.sql;
USE 100rows_from_key_words;

-- хочу удостовериться в том, что таблица содержит именно 100 строк, разворачиваю из дампа:
SOURCE rows100.sql;

-- получаю ошибку:
ERROR 3723 (HY000): The table 'help_keyword' may not be created in the reserved tab
lespace 'mysql'.