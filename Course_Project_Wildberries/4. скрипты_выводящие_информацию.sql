 USE wildberries;
 
-- 6. скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы)
-- 6.1  Вывести всех п-лей, которые сделали хотя бы 1 заказ, т.е статус заказа оплачено и выше с помощью JOIN.
SELECT o.user_id, u.firstname, o.order_status_id FROM users AS u
INNER JOIN orders AS o ON u.id = o.user_id WHERE o.order_status_id >= 2;

-- 6.2  Вывести п-лей и вес только тех, у которых вес больше или равен 80, с помощью JOIN.
SELECT u.id, ufp.weight FROM users AS u
INNER JOIN user_figure_parameters AS ufp ON u.figure_parameters_id = ufp.id AND ufp.weight >= 80;

-- 6.3  Вывести всех п-лей и название статуса из таблиц orders и order_statuses, которые сделали возвтрат, с помощью JOIN.
SELECT o.user_id, os.`name` FROM orders AS o
INNER JOIN order_statuses AS os ON o.order_status_id = os.id AND os.id = 6;

-- 6.4 Вывести максимальную цену за товар, у которого catalog_types = 'Одежда' с помощью вложенного запроса.

/* Действия, которые понадобились для получения решения
SELECT id FROM catalog_types WHERE `name` = 'Одежда';
SELECT * FROM catalogs WHERE catalog_type_id = (SELECT id FROM catalog_types WHERE `name` = 'Одежда');
SELECT * FROM product_types WHERE catalog_id IN 
(SELECT id FROM catalogs WHERE catalog_type_id = (SELECT id FROM catalog_types WHERE `name` = 'Одежда'));
*/

SELECT id, `name`, text AS `comment`, product_type_id, price FROM products WHERE product_type_id IN 
(SELECT id FROM product_types WHERE catalog_id IN 
	(SELECT id FROM catalogs WHERE catalog_type_id = 
		(SELECT id FROM catalog_types WHERE `name` = 'Одежда')
	)
) ORDER BY price DESC LIMIT 1;

/* ВНИМАНИЕ! Из-за того, что я использовала автоматическую генерацию данных, в итоге под id = 33 будет Компьютерная мышь, которая не является Одеждой. */

-- 6.5 Вывести id пользователя и название города из таблицы с заказами с помощью вложенного запроса.
SELECT o.user_id, 
(SELECT rc.`name` FROM rus_cities AS rc WHERE rc.id = o.delivery_city_id) AS city 
FROM orders AS o;

-- 6.6 Вывести имя п-ля и его комментарий к продукту с помощью вложенного запроса.
SELECT (SELECT u.firstname FROM users AS u WHERE pc.user_id = u.id) AS name, 
pc.text 
FROM product_comments AS pc;

-- 7 представления (минимум 2)
/*7.1 Создать представление, которое будет выводить id продукта и значение sum, определяющее сколько раз 
заказывали данный продукт, отсортировать по sum*/
DROP VIEW IF EXISTS analysis_orders;
CREATE VIEW analysis_orders AS
SELECT product_id, COUNT(product_id) as sum FROM order_products GROUP BY product_id ORDER BY sum DESC;

SELECT * FROM analysis_orders;

/* 7.2 Создать представление, которое выводит id склада, id товара и кол-во товара на складе, которые заказывали.
Данные берутся из таблицы storehouses_products и таблицы (представления) analysis_orders.
*/
DROP VIEW IF EXISTS total_product_on_storehouse;
CREATE VIEW total_product_on_storehouse AS
select st_h.storehouse_id, st_h.product_id, st_h.`value` AS quantity_products from storehouses_products AS st_h
INNER JOIN analysis_orders a_o ON (a_o.product_id = st_h.product_id);

SELECT * FROM total_product_on_storehouse;

/* хранимые процедуры / триггеры
	8.1 Создать хранимую процедуру, которая добавляет новый товар в таблицу products и 
    меняет gender_id на противололожный. Если в gender_id приходит NULL, то значение NULL менять не нужно.
*/
DELIMITER //
DROP PROCEDURE IF EXISTS add_product//
CREATE PROCEDURE add_product (
	IN `val_id` BIGINT, 
    IN `val_name` VARCHAR(150), 
    IN `val_text` TEXT, 
    IN `val_product_type_id` BIGINT, 
    IN `val_gender_id` BIGINT, 
    IN `val_brand_id` BIGINT, 
    IN `val_color_id` BIGINT, 
    IN `val_product_materials_id` BIGINT, 
    IN `val_size_id` BIGINT, 
    IN `val_price` FLOAT, 
    IN `val_discount_id` BIGINT
)
	BEGIN
    IF (`val_gender_id` = 1) THEN
		SET `val_gender_id` = 2;
	ELSEIF (`val_gender_id` = 2) THEN
		SET `val_gender_id` = 1;
	END IF;
    
	INSERT INTO `products` (`id`,`name`, `text`, `product_type_id`, `gender_id`, `brand_id`, `color_id`, `product_materials_id`, `size_id`, `price`, `discount_id`) 
	VALUES 
	(`val_id`, `val_name`, `val_text`, `val_product_type_id`, `val_gender_id`, `val_brand_id`, `val_color_id`, `val_product_materials_id`, `val_size_id`, `val_price`, `val_discount_id`);
    END //
DELIMITER ;

-- Тут `val_gender_id` передается 1
CALL add_product (101, 'Мики', 'Самые удобные шлепки, которые Вы видели!', '5', '1', '3', '10', '4', '6', 720.00, 14);

select * from products WHERE id = 101 LIMIT 1;

-- gender_id изменился на 2, что если мы передадим NULL в gender_id?

CALL add_product (102, 'Для всех', 'Самые удобные шлепки, которые Вы видели!', '5', NULL, '3', '10', '4', '6', 720.00, 14);
select * from products WHERE id = 102 LIMIT 1;
-- NULL как был так и остался:) Результат ожидаемый и подходит

/* 8.2 Создать  триггер который выводит кол-во уникальных городов, которые были указаны при заказе после вставки нового значения в таблицу orders 
где order_status_id = 6 (возврат). 
*/
DELIMITER //
DROP TRIGGER IF EXISTS add_new_product_type//
CREATE TRIGGER add_new_product_type AFTER INSERT ON orders
	FOR EACH ROW
    BEGIN
		select COUNT(DISTINCT delivery_city_id) INTO @total from orders where order_status_id = 6;
	END//
DELIMITER ;

-- Проверка последних 3-ех записей, перед ввнесением данных в таблицу.
select * from orders ORDER BY id DESC LIMIT 3;

-- Смотрим кол-во уникальных городов до внесения данных. Их 6.
select COUNT(DISTINCT delivery_city_id) AS count_uq_cities from orders where order_status_id = 6;

-- Вносим новую запись в таблицу.
INSERT INTO `orders` (`user_id`, `order_status_id`, `delivery_city_id`, `created_at`, `updated_at`) 
VALUES 
('163', '6', '5', NOW(), NOW());

-- Смотрим кол-во уникальных городов после внесенных данных. Их стало 7.
SELECT @total;

-- Проверка последних 3-ех записей, после обновления таблицы. 
select * from orders ORDER BY id DESC LIMIT 3;