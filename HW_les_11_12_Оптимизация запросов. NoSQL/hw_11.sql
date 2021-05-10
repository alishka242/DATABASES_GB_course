use shop;

/* Практическое задание по теме “Оптимизация запросов”
1) Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products 
в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и 
содержимое поля name.
*/

-- создала таблицу
drop table if exists logs;
create table logs (
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	`table_name` VARCHAR(150) not null,
    `pk_table` BIGINT UNSIGNED NOT NULL,
    `column_name` VARCHAR(100) NOT NULL
) ENGINE = ARCHIVE;

-- TRIGGER FOR users
DELIMITER //
DROP TRIGGER IF EXISTS users_logs;
CREATE TRIGGER users_logs AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs (`table_name`, `pk_table`, `column_name`)
    VALUES('users', NEW.id, NEW.name);
END //
DELIMITER ;

-- TRIGGER FOR catalogs
DELIMITER //
DROP TRIGGER IF EXISTS catalogs_logs;
CREATE TRIGGER catalogs_logs AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	INSERT INTO logs (`table_name`, `pk_table`, `column_name`)
    VALUES('catalogs', NEW.id, NEW.name);
END //
DELIMITER ;

-- TRIGGER FOR products
DELIMITER //
DROP TRIGGER IF EXISTS products_logs;
CREATE TRIGGER products_logs AFTER INSERT ON products
FOR EACH ROW
BEGIN
	INSERT INTO logs (`table_name`, `pk_table`, `column_name`)
    VALUES('products', NEW.id, NEW.name);
END //
DELIMITER ;

-- Добавляю новую строку в каждую из таблиц
INSERT INTO users (name, birthday_at) VALUES
  ('Кристина', '1995-11-05'), ('Эля', '1996-11-09');
INSERT INTO catalogs (name) VALUES
  ('Монитор');
INSERT INTO products (name, desription, price, catalog_id) VALUES
  ('LG', 'Монитор 23-дюйма', 15000, 6);

-- Посмотрим, что вышло:)
select * from users;
select * from catalogs;
select * from products;
select * from logs;

/*2) Создайте SQL-запрос, который помещает в таблицу users миллион записей.*/

/*  Решение вроде бы неплохое, но у почему-то ошибка вылетает при SELECT MAX(id) ...
DROP DATABASE IF EXISTS million_of_users;
CREATE DATABASE million_of_users;
USE million_of_users;

DROP TABLE IF EXISTS mln_users;
CREATE TABLE mln_users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP PROCEDURE IF EXISTS insert_user;
DELIMITER //
CREATE PROCEDURE insert_user (IN `value_i` INT, IN `value_to` INT)
BEGIN
	DECLARE i INT DEFAULT 1;
    WHILE i <= i + `value_to` DO
		INSERT INTO mln_users (name) VALUES (CONCAT('user_', i));
        SET i = i + 1;
	END WHILE;
END // 
DELIMITER ; 
TRUNCATE mln_users;
CALL insert_user(1, 99); -- 
select * from mln_users;
select MAX(id) from mln_users; */


-- РЕШЕНИЕ ИЗ ИНТЕРНЕТА:(
DROP TABLE IF EXISTS test_users; 
CREATE TABLE test_users (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	birthday_at DATE,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
 	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


DROP PROCEDURE IF EXISTS insert_into_users ;
delimiter //
CREATE PROCEDURE insert_into_users ()
BEGIN
	DECLARE i INT DEFAULT 100;
	DECLARE j INT DEFAULT 0;
	WHILE i > 0 DO
		INSERT INTO test_users(name, birthday_at) VALUES (CONCAT('user_', j), NOW());
		SET j = j + 1;
		SET i = i - 1;
	END WHILE;
END //
delimiter ;


-- test
SELECT COUNT(id) FROM test_users;

CALL insert_into_users();

SELECT * FROM test_users LIMIT 3;