/*
Практическое задание по теме “Транзакции, переменные, представления”

Задание 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users 
в таблицу sample.users. Используйте транзакции.
*/
-- посмотрим на п-ля с users.id = 1
USE shop;
select * from users;

-- посмотрим на табл users
use sample;
select * from users;
TRUNCATE users;

DROP procedure IF EXISTS `add_user_from_db_shop`;
DELIMITER //

CREATE PROCEDURE `add_user_from_db_shop` (user_id INT)
BEGIN
	START TRANSACTION;
	INSERT INTO sample.users (id, name, birthday_at, `created_at`, `updated_at`)
	select id, name, birthday_at, `created_at`, `updated_at` from shop.users where id = user_id;
    COMMIT;
    select * from sample.users;
END//
DELIMITER ;

CALL `add_user_from_db_shop`(1);

/*Задание 2. Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее 
название каталога name из таблицы catalogs.*/

USE shop;

CREATE OR REPLACE VIEW pc AS select products.`name` as products, catalogs.`name` as categories from products, catalogs where catalogs.id = products.catalog_id;
select * from pc;

/* Практическое задание по теме “Хранимые процедуры и функции, триггеры"
Задание 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, 
в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", 
с 00:00 до 6:00 — "Доброй ночи".
*/

DROP FUNCTION IF EXISTS hello;
DELIMITER //

CREATE FUNCTION hello(time TIME)
RETURNS text READS SQL DATA
BEGIN
	IF time BETWEEN '06:00' AND '12:00' then RETURN 'Доброе утро';
    ELSEIF time BETWEEN '12:00' AND '18:00' then RETURN 'Добрый день';
    ELSEIF time BETWEEN '18:00' AND '00:00' then RETURN 'Добрый вечер';
    ELSE RETURN 'Доброй ночи';
    END IF;
END //
DELIMITER ;

-- вызов хранимой ф-ии
select hello(DATE_FORMAT(CURTIME(), '%H:%i')) as time;