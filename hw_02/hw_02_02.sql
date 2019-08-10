CREATE DATABASE example;
USE example;
CREATE TABLE users (
	id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
  	name VARCHAR(100) NOT NULL);
SHOW TABLES;
DESCRIBE users;
INSERT INTO users (name) VALUES ("Tom"), ("Julia"), ("Diana"), ("Andrew");
SHOW * FROM users;