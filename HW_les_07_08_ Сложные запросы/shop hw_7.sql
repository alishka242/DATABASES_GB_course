DROP DATABASE IF EXISTS hw_7;
CREATE DATABASE hw_7;
USE hw_7;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

/* DROP TABLE IF EXISTS rubrics;
CREATE TABLE rubrics (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела'
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO rubrics VALUES
  (NULL, 'Видеокарты'),
  (NULL, 'Память'); */

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id),
  FOREIGN KEY products_catalog_id (catalog_id) REFERENCES catalogs (id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  FOREIGN KEY orders_user_id (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE 
) COMMENT = 'Заказы';

INSERT INTO orders (user_id) 
VALUES 	(1), (2), (5);

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  total INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY orders_products_order_id (order_id) REFERENCES orders (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY orders_products_product_id (product_id) REFERENCES products (id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'Состав заказа';

INSERT INTO orders_products (order_id, product_id, total) 
VALUES  (3, 6, 2), 
        (1, 2, 3), 
        (2, 5, 4);

DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id SERIAL PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  KEY index_of_product_id(product_id),
  FOREIGN KEY discounts_user_id (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY discounts_product_id (product_id) REFERENCES products (id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'Скидки';

INSERT INTO discounts (user_id, product_id, discount) 
VALUES  (5, 6, 0.5), 
        (1, 2, 0), 
        (2, 5, 0);

DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Склады';

INSERT INTO storehouses (name) 
VALUES  ('MVideo'), 
        ('CityLink');

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY discounts_storehouse_id (storehouse_id) REFERENCES storehouses (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY discounts_product_id (product_id) REFERENCES products (id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'Запасы на складе';

INSERT INTO storehouses_products (storehouse_id, product_id, value) 
VALUES  (1, 1, 8), (1, 2, 9), (1, 3, 7), (1, 4, 8), (2, 5, 8), (2, 6, 8), (2, 7, 8);


-- HW_7 Тема “Сложные запросы”
-- Задание 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
SELECT users.id, users.name, orders.id as orser_id from users, orders where orders.user_id = users.id;

-- Задание 2. Выведите список товаров products и разделов catalogs, который соответствует товару.
select products.name as product_name, catalogs.name category_name from products, catalogs where products.catalog_id = catalogs.id;

/* Задание 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
Поля from, to и label содержат английские названия городов, поле name — русское. 
Выведите список рейсов flights с русскими названиями городов.*/

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
  id SERIAL PRIMARY KEY,
  `from` VARCHAR(50) NOT NULL,
  `to` VARCHAR(50) NOT NULL
);

INSERT INTO flights (`from`, `to`) 
VALUES  ('moscow', 'omsk'), 
		('novgorod', 'kazan'),
        ('irkutsk', 'moscow'),
        ('omsk', 'irkutsk'),
        ('moscow', 'kazan');
        
DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
  label VARCHAR(50) NOT NULL,
  name VARCHAR(50) NOT NULL
);

INSERT INTO cities (label, name) 
VALUES  ('moscow', 'Москва'), 
		('irkutsk', 'Иркутск'),
        ('novgorod', 'Новгород'),
        ('kazan', 'Казань'),
        ('omsk', 'Омск');

select f.id,
	(SELECT c.name as `from` from cities c where c.label = f.from) as `from`,
	(SELECT c.name as `to` from cities c where c.label = f.to) as `to`
from flights f;