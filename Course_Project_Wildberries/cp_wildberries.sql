DROP DATABASE IF EXISTS wildberries;
CREATE DATABASE wildberries;
USE wildberries;



DROP TABLE IF EXISTS genders;
CREATE TABLE genders (
	id SERIAL PRIMARY KEY,
    `name` ENUM ('жен', 'муж')
);

DROP TABLE IF EXISTS sizes;
CREATE TABLE sizes (
	id SERIAL PRIMARY KEY,
    `name` ENUM ('XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', 'маленький', 'средний', 'большой')
);

DROP TABLE IF EXISTS user_figure_parameters;
CREATE TABLE user_figure_parameters (
	id SERIAL PRIMARY KEY,
	bust BIGINT UNSIGNED DEFAULT NULL,
    waist BIGINT UNSIGNED DEFAULT NULL,
    hips BIGINT UNSIGNED DEFAULT NULL,
    weight BIGINT UNSIGNED DEFAULT NULL,
    height BIGINT UNSIGNED DEFAULT NULL,
    clothing_size_id BIGINT UNSIGNED DEFAULT NULL,
    
    FOREIGN KEY (clothing_size_id) REFERENCES sizes (id) 
    ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'параметры фигуры п-ля (для комментариев (чтобы было видно, какой размер 
    одежды на какие параметры подошел), профиля)';

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
    firstname VARCHAR (145) NOT NULL,
    lastname VARCHAR (145) NOT NULL,
    gender_id BIGINT UNSIGNED NOT NULL, 
    figure_parameters_id BIGINT UNSIGNED NOT NULL,
    birthday DATE NOT NULL,
    number_phone BIGINT UNSIGNED NOT NULL UNIQUE,
    email VARCHAR (145) NOT NULL UNIQUE,
    hash_password TEXT NOT NULL,
    reg_date DATETIME NOT NULL DEFAULT NOW() COMMENT 'Дата регистрации',
    
    FOREIGN KEY (gender_id) REFERENCES genders (id) 
    ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (figure_parameters_id) REFERENCES  user_figure_parameters (id) 
    ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS brands;
CREATE TABLE brands (
	id SERIAL PRIMARY KEY,
    `name` VARCHAR(200) UNIQUE NOT NULL
) COMMENT 'бренд или торговая марка одежды, предметов';

DROP TABLE IF EXISTS colors;
CREATE TABLE colors (
	id SERIAL PRIMARY KEY,
    `name` ENUM ('черный', 'белый', 'зеленый', 'желтый', 'розовый', 'серый', 'коричневый', 'голубой')
) COMMENT 'цвета одежды, предметов';

DROP TABLE IF EXISTS materials;
CREATE TABLE materials (
	id SERIAL PRIMARY KEY,
    `name` ENUM ('Хлопок', 'Эластан', 'Пластмасса', 'Резина', 'Вильвет', 'Алюминий', 'Медь')
) COMMENT 'материал одежды, предметов';

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
	id SERIAL PRIMARY KEY,
    `name` VARCHAR(250) NOT NULL UNIQUE
    
) COMMENT 'каталог с разным видом товара (одежда, обувь, игрушки, товары для дома, товары для сада, электроника)';

DROP TABLE IF EXISTS product_types;
CREATE TABLE product_types (
	id SERIAL PRIMARY KEY,
    catalog_id BIGINT UNSIGNED NOT NULL,
    `name` VARCHAR(250) NOT NULL UNIQUE,
    
	FOREIGN KEY (catalog_id) REFERENCES catalogs (id) 
    ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'тип товара, расскывающий каталог (куртка, юбка, джинсы, кроссовки, шлепки, видеокарта, мат.плата, паровой утюг)';

DROP TABLE IF EXISTS products; 
CREATE TABLE products (
	-- сам товар
	id SERIAL PRIMARY KEY,
    product_type_id BIGINT UNSIGNED NOT NULL,
    `name` VARCHAR(250) NOT NULL UNIQUE,
    gender_id BIGINT UNSIGNED NOT NULL,
    brand_id BIGINT UNSIGNED NOT NULL,
    color_id BIGINT UNSIGNED NOT NULL,
    material_id BIGINT UNSIGNED NOT NULL,
    size_id BIGINT UNSIGNED NOT NULL,
    price DECIMAL(10 ,2) UNSIGNED NOT NULL,
    
	FOREIGN KEY (product_type_id) REFERENCES product_types (id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (gender_id) REFERENCES genders (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (brand_id) REFERENCES brands (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (color_id) REFERENCES colors (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (material_id) REFERENCES materials (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (size_id) REFERENCES sizes (id) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS product_comments;
CREATE TABLE product_comments (
	id SERIAL PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    product_size BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL, 
    user_figure_parameters_id BIGINT UNSIGNED DEFAULT NULL, 
	`text` TEXT NOT NULL,
    
	FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_size) REFERENCES products (size_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_figure_parameters_id) REFERENCES users (figure_parameters_id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT 'Комментарий об одежде';

DROP TABLE IF EXISTS order_statuses;
CREATE TABLE order_statuses (
  id SERIAL PRIMARY KEY,
  name ENUM ('не оплачено', 'оплачено', 'собирается', 'отправлен', 'доставлен', 'возврат', 'отменен')
) COMMENT = 'Статсус заказа';

DROP TABLE IF EXISTS payment_type;
CREATE TABLE payment_type (
  id SERIAL PRIMARY KEY,
  name ENUM ('картой сейчас','картой при получении', 'наличными сейчас', 'наличными при получении')
) COMMENT = 'Тип оплаты';

DROP TABLE IF EXISTS discounts; -- подумай еще. хотя вроде уже ничего так))
CREATE TABLE discounts (
    id SERIAL PRIMARY KEY,
    `value` FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
    product_id BIGINT UNSIGNED DEFAULT NULL,
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    finished_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE ON UPDATE CASCADE
)  COMMENT='Скидки могут зависеть от бренда, типа товара и самого продукта';

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  order_status_id BIGINT UNSIGNED NOT NULL,
  delivery_address VARCHAR(1000) NOT NULL,
  payment_type_id BIGINT UNSIGNED NOT NULL,
  -- total_amount DECIMAL(12 ,2) UNSIGNED NOT NULL, /еще не знаю к чему привязать
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (order_status_id) REFERENCES order_statuses (id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'Заказы';

DROP TABLE IF EXISTS order_products;
CREATE TABLE order_products (
  id SERIAL PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  order_quantity INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'Состав заказа';

DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Склады';

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (storehouse_id) REFERENCES storehouses (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE ON UPDATE CASCADE
) COMMENT = 'Запасы на складе';

