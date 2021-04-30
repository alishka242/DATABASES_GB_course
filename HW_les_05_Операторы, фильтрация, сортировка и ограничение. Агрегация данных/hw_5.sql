DROP DATABASE IF EXISTS hw_3_4;
CREATE DATABASE hw_3_4;
USE hw_3_4;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  birthday_at DATE,
  created_at VARCHAR(150),
  updated_at VARCHAR(150)
);

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

-- START
/*Практическое задание по теме «Операторы, фильтрация, сортировка и ограничение»*/

/* Задание 1. Пусть в таблице users поля created_at и updated_at 
оказались незаполненными. Заполните их текущими датой и временем.*/

select * from users;

update users 
set `created_at` = now(), `updated_at` = now() where id > 0;

/* Задание 2 Таблица users была неудачно спроектирована. 
Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время 
помещались значения в формате 20.10.2017 8:10. Необходимо преобразовать поля 
к типу DATETIME, сохранив введённые ранее значения.*/

TRUNCATE `users`;
select * from users;

INSERT INTO users (`name`, birthday_at, `created_at`, `updated_at`) 
VALUES 
	('Геннадий', '1990-10-05', '26.09.1970 23:57', '26.09.1970 23:57'),
	('Наталья', '1984-11-12', '26.09.1970 23:57', '26.09.1970 23:57'),
	('Александр', '1985-05-20', '26.09.1970 23:57', '26.09.1970 23:57'),
	('Сергей', '1988-02-14', '26.09.1970 23:57', '26.09.1970 23:57'),
	('Иван', '1998-01-12', '26.09.1970 23:57', '26.09.1970 23:57'),
	('Мария', '1992-08-29', '26.09.1970 23:57', '26.09.1970 23:57');

ALTER table `users` add new_created_at DATETIME;
ALTER table `users` add new_updated_at  DATETIME; 

SELECT updated_at, STR_TO_DATE(updated_at, "%d.%m.%Y %k:%i") as new_updated_at, STR_TO_DATE(created_at, '%d.%m.%Y %k:%i') as new_created_at FROM users;

UPDATE users
SET new_updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i'), 
	new_created_at = STR_TO_DATE(created_at, '%d.%m.%Y %k:%i') where id > 0;

ALTER TABLE hw_3_4.users DROP COLUMN created_at;
ALTER TABLE hw_3_4.users DROP COLUMN updated_at;

ALTER TABLE users RENAME COLUMN new_updated_at TO updated_at;
ALTER TABLE users RENAME COLUMN new_created_at TO created_at;

/* Задание 3. В таблице складских запасов storehouses_products в поле value 
могут встречаться самые разные цифры: 0, если товар закончился и выше нуля, 
если на складе имеются запасы. Необходимо отсортировать записи таким образом, 
чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы 
должны выводиться в конце, после всех*/

DROP TABLE IF EXISTS storehouses_products;
create table storehouses_products (
	id SERIAL,
	`name` VARCHAR(145) not null,
    `value` INT NOT NULL
);

select * from storehouses_products;

INSERT INTO storehouses_products (`name`, `value`) 
VALUES 
	('Процессор','135'),
	('Жесткий диск','50'),
	('Материнская плата','0'),
	('Видеокарта','20');
    
select * from storehouses_products ORDER BY
if(`value` = 0, 1, 0), `value`;

/* Задание 4. (по желанию) Из таблицы users необходимо извлечь пользователей, 
родившихся в августе и мае. Месяцы заданы в виде списка английских названий (may, august)*/

select * from users;
ALTER TABLE users MODIFY birthday_at TEXT;

SELECT name,
CASE
	WHEN birthday_at LIKE '%-05-%' THEN 'may'
    WHEN birthday_at LIKE '%-08-%' THEN 'august'
    ELSE '0'
    END AS birthday_at
FROM users HAVING birthday_at <> '0';

/* Задание 5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. 
SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, 
заданном в списке IN.*/

DROP TABLE IF EXISTS catalogs;
create table catalogs (
	id SERIAL,
	`name` VARCHAR(145) not null,
    `value` INT NOT NULL
);

INSERT INTO catalogs (`name`, `value`) 
VALUES 
	('Процессор','135'),
	('Жесткий диск','50'),
	('Материнская плата','0'),
    ('Дисковод','0'),
	('Видеокарта','20');

SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY IF(id = 5, 0, 1), id ASC;

-- START 
/*Практическое задание теме «Агрегация данных»*/

/* Задание 1. Подсчитайте средний возраст пользователей в таблице users.*/
SELECT id, name, birthday_at FROM users;
ALTER TABLE users MODIFY birthday_at DATE;
ALTER TABLE users ADD COLUMN age INT;

UPDATE users SET age = (YEAR(NOW()) - SUBSTRING(birthday_at, 1, 4)) WHERE id > 0;

select id, name, birthday_at, age from users;

-- Вывод решения
select ROUND(AVG(age), 0) AS average_age from users;

/* Задача 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
Следует учесть, что необходимы дни недели текущего года, а не года рождения.*/

select id, name, DAYNAME(concat(year(now()), '-', DATE_FORMAT(birthday_at, '%m-%d'))) as `in_this_year` from users;
ALTER TABLE users ADD COLUMN `in_this_year` VARCHAR(50);
update users set `in_this_year` = DAYNAME(concat(year(now()), '-', DATE_FORMAT(birthday_at, '%m-%d'))) where id > 0;
SELECT id, name, `in_this_year` from users;

SELECT 
	sum(`in_this_year` = 'Monday') as 'Monday',
	sum(`in_this_year` = 'Tuesday') as 'Tuesday',
    sum(`in_this_year` = 'Wednesday') as 'Wednesday',
	sum(`in_this_year` = 'Thursday') as 'Thursday',
    sum(`in_this_year` = 'Friday') as 'Friday',
	sum(`in_this_year` = 'Saturday') as 'Saturday',
    sum(`in_this_year` = 'Sunday') as 'Sunday'
 from users;
 
 -- select DISTINCT `in_this_year` from users;
 
/* Хотела создать таблицу с данными, которые приходят из другой таблицы, пока не получилось, 
дочитаю и дополню
 DROP TABLE IF EXISTS holidays_for_week;
create table holidays_for_week (
	id SERIAL,
	`days_of_week` VARCHAR(50) not null,
    `value` INT NOT NULL
);

INSERT INTO holidays_for_week (`days_of_week`, `value`) 
VALUES 
	('Monday', sum(users.in_this_year = 'Monday')), 
	('Tuesday', sum(users.in_this_year = 'Tuesday')),
    ('Wednesday', sum(users.in_this_year = 'Wednesday')),
    ('Thursday', sum(users.in_this_year = 'Thursday')),
    ('Friday', sum(users.in_this_year = 'Friday')),
    ('Saturday', sum(users.in_this_year = 'Saturday')),
    ('Sunday', sum(users.in_this_year = 'Sunday'));
 */
/* Задание 3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.*/

select * from users;
-- Нашла в гугл.
select ROUND(exp(sum(ln(age)))) as n from users;

-- END