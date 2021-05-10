DROP DATABASE IF EXISTS wildberries;
CREATE DATABASE wildberries;
USE wildberries;

DROP TABLE IF EXISTS rus_cities;
CREATE TABLE rus_cities (
	id SERIAL PRIMARY KEY,
    `name` ENUM ('Москва', 'Санкт-Петербург', 'Новосибирск', 'Екатеринбург', 'Казань', 'Нижний Новгород', 'Челябинск', 'Самара', 'Омск', 'Ростов-на-Дону', 'Уфа', 'Красноярск', 'Воронеж', 'Пермь', 'Волгоград')  UNIQUE
);

DROP TABLE IF EXISTS genders;
CREATE TABLE genders (
	id SERIAL PRIMARY KEY,
    `name` ENUM ('жен', 'муж')  UNIQUE
);

DROP TABLE IF EXISTS sizes;
CREATE TABLE sizes (
	id SERIAL PRIMARY KEY,
    `value` VARCHAR(250) NOT NULL UNIQUE
	-- строка ниже используется для автоматической генерации данных с сайта http://filldb.info/
    -- `value` ENUM ('XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', 'маленький', 'средний', 'большой', '37', '38', '39', '35', '36', '40', '41', '42', '43')  UNIQUE
);

DROP TABLE IF EXISTS user_figure_parameters;
CREATE TABLE user_figure_parameters (
	id SERIAL PRIMARY KEY,
	bust BIGINT UNSIGNED DEFAULT NULL COMMENT 'Объем груди',
    waist BIGINT UNSIGNED DEFAULT NULL COMMENT 'Объем талии',
    hips BIGINT UNSIGNED DEFAULT NULL COMMENT 'Объем бедер',
    weight BIGINT UNSIGNED DEFAULT NULL COMMENT 'Вес',
    height BIGINT UNSIGNED DEFAULT NULL COMMENT 'Высота',
    clothing_size_id BIGINT UNSIGNED DEFAULT NULL COMMENT 'Размер одежды, который обычно носит п-ль',
    foot_length BIGINT UNSIGNED DEFAULT NULL COMMENT 'Длина стопы',
    foot_size BIGINT UNSIGNED DEFAULT NULL COMMENT 'Размер обуви, который п-ль обычно носит',
    
    FOREIGN KEY (clothing_size_id) REFERENCES sizes (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (foot_size) REFERENCES sizes (id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT 'параметры фигуры п-ля, для комментариев (чтобы было видно, какой размер 
    одежды и обуви п-ля на какие параметры подошел)';

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
    firstname VARCHAR (255) NOT NULL,
    lastname VARCHAR (255) NOT NULL,
    gender_id BIGINT UNSIGNED NOT NULL, 
    figure_parameters_id BIGINT UNSIGNED DEFAULT NULL,
    birthday DATE NOT NULL,
    number_phone BIGINT UNSIGNED NOT NULL UNIQUE,
    email VARCHAR (500) NOT NULL UNIQUE,
    hash_password TEXT NOT NULL COMMENT 'Пароль',
    reg_date DATETIME NOT NULL DEFAULT NOW() COMMENT 'Дата регистрации',
    
    FOREIGN KEY (gender_id) REFERENCES genders (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (figure_parameters_id) REFERENCES  user_figure_parameters (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS brands;
CREATE TABLE brands (
	id SERIAL PRIMARY KEY,
    `name` VARCHAR(200) UNIQUE NOT NULL
	-- строка ниже используется для автоматической генерации данных с сайта http://filldb.info/
    -- `name` ENUM ('Adidas', 'ASUS', 'Nike', 'Баба Зина', 'Acer', 'MSI', 'Клава', 'Супер бренд')  UNIQUE

) COMMENT 'Бренд или торговая марка одежды, предметов';

DROP TABLE IF EXISTS colors;
CREATE TABLE colors (
	id SERIAL PRIMARY KEY,
    `name` ENUM ('черный', 'белый', 'зеленый', 'желтый', 'розовый', 'серый', 'коричневый', 'голубой', 'бежевый', 'синий', 'фиолетовый', 'оранжевый')  UNIQUE
) COMMENT 'Цвета товара, как на самом Wildberries выбирается основной цвет и всего их 12';

DROP TABLE IF EXISTS materials;
CREATE TABLE materials (
	id SERIAL PRIMARY KEY,
    `name` VARCHAR(250) NOT NULL UNIQUE
    -- строка ниже используется для автоматической генерации данных с сайта http://filldb.info/
    -- `name` ENUM ('Хлопок', 'Эластин', 'Пластмасса', 'Резина', 'Вельвет', 'Алюминий', 'Медь', 'Акрил', 'Шелк', 'Титан', 'Дерево', 'Плюшевая')  UNIQUE
) COMMENT 'Материалы';

DROP TABLE IF EXISTS products_materials;
CREATE TABLE products_materials (
	id SERIAL PRIMARY KEY,
    `value_1` BIGINT UNSIGNED NOT NULL,
    `value_2` BIGINT UNSIGNED DEFAULT NULL,
    `value_3` BIGINT UNSIGNED DEFAULT NULL,
    `value_4` BIGINT UNSIGNED DEFAULT NULL,
    
    FOREIGN KEY (`value_1`) REFERENCES materials (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`value_2`) REFERENCES materials (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`value_3`) REFERENCES materials (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (`value_4`) REFERENCES materials (id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT 'Материал товаров. Один товар может состоять минимум из 1-ого материала, максимум из 4-ех';

DROP TABLE IF EXISTS catalog_types;
CREATE TABLE catalog_types (
	id SERIAL PRIMARY KEY,
    `name` VARCHAR(250) NOT NULL UNIQUE
	-- строка ниже используется для автоматической генерации данных с сайта http://filldb.info/
    -- `name` ENUM ('Одежда', 'Обувь', 'Игрушки', 'Сад', 'Дом', 'Авто товары', 'Электроника')  UNIQUE
) COMMENT 'каталог с разным видом товара (одежда, обувь, игрушки, товары для дома, товары для сада, электроника)';

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
	id SERIAL PRIMARY KEY,
    catalog_type_id BIGINT UNSIGNED NOT NULL,
    `name` VARCHAR(250) NOT NULL UNIQUE,
	-- строка ниже используется для автоматической генерации данных с сайта http://filldb.info/
    /* `name` ENUM ('Шорты', 'Футболка', 'Юбки', 'Платья', 'Носки', 'Колготки', 'Брюки', 'Рубашки', 'Шлепки', 'Кроссовки', 'Туфли', 'Ботинки', 'Сапоги', 
    'Слиппоны','Антистресс', 'Для песочницы', 'Конструктор', 'Для ванной', 'Музыкальные', 'Радиоуправляемые', 'Развивающие',
    'Удобрения', 'Инструменты', 'Ванная', 'Кухня', 'Спальня', 
    'Авто запчасти', 'Аварийные принадлежности',
    'Телефоны', 'Компьютеры и ноутбуки', 'Гарнитура и наушники', 'Принтеры')  UNIQUE,
    */
    FOREIGN KEY (catalog_type_id) REFERENCES catalog_types (id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT 'каталог с разным видом товара (одежда, обувь, игрушки, товары для дома, товары для сада, электроника)';

DROP TABLE IF EXISTS product_types;
CREATE TABLE product_types (
	id SERIAL PRIMARY KEY,
    catalog_id BIGINT UNSIGNED NOT NULL,
    `name` VARCHAR(200) NOT NULL, 
    -- строка ниже используется для автоматической генерации данных с сайта http://filldb.info/
    /* `name` ENUM ('Повседневные', 'Пляжные', 'Праздничные', 'Зимние', 'Летние', 'Весна-осень', 
    'Спортивные', 'Обезьянка', 'Кукла', 'Машинки', 'Мыло', 'Коврики', 'Мебель', 'Бокалы',
    'Вилки', 'Кувшины', 'Постельное белье', 'Матрасы', 'Зеркало', 'Грабли', 'Лопаты', 
    'Провода прикуривания', 'Жилет светоотражающий', 'Сайленблоки', 'Дворники', 'Фары',
    'Наушники', 'Микрофон', 'Наушники с микрофоном', 'Мышь компьютерная', 'Клавиатура', 'Ноутбук',
    'Кнопочный', 'Сенсорный', 'Аксессуары', 'Моноблоки', 'Оперативная память', 'Ноутбук')  UNIQUE, 
    */
	FOREIGN KEY (catalog_id) REFERENCES catalogs (id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT 'тип товара, раскрывающий каталог (куртка, юбка, джинсы, кроссовки, шлепки, видеокарта, мат. плата, паровой утюг)';

DROP TABLE IF EXISTS discounts; 
CREATE TABLE discounts (
    id SERIAL PRIMARY KEY,
    `name` VARCHAR(200) NOT NULL COMMENT 'Информация о скидки (Ликвидация)',
    `value` FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    finished_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)  COMMENT = 'Скидки могут зависеть от бренда, типа товара и самого продукта';

DROP TABLE IF EXISTS products; 
CREATE TABLE products (
	id SERIAL PRIMARY KEY,
    `name` VARCHAR(200) NOT NULL, 
    `text` VARCHAR(700) NOT NULL COMMENT 'Краткая информация',
    product_type_id BIGINT UNSIGNED NOT NULL,
    gender_id BIGINT UNSIGNED DEFAULT NULL COMMENT 'Если указано NULL, значит товар подходит как для мужчин, так и для женщин',
    brand_id BIGINT UNSIGNED NOT NULL,
    color_id BIGINT UNSIGNED NOT NULL,
    product_materials_id BIGINT UNSIGNED NOT NULL,
    size_id BIGINT UNSIGNED DEFAULT NULL COMMENT 'Если указано NULL, значит товар имеет единственный размер',
    price DECIMAL(10 ,2) UNSIGNED NOT NULL,
    discount_id BIGINT UNSIGNED DEFAULT 0,
    
	FOREIGN KEY (product_type_id) REFERENCES product_types (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (gender_id) REFERENCES genders (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (brand_id) REFERENCES brands (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (color_id) REFERENCES colors (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (product_materials_id) REFERENCES products_materials (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (size_id) REFERENCES sizes (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (discount_id) REFERENCES discounts (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS order_statuses;
CREATE TABLE order_statuses (
  id SERIAL PRIMARY KEY,
  `name` ENUM ('не оплачено', 'оплачено', 'собирается', 'отправлен', 'доставлен', 'возврат', 'отменен')  UNIQUE
) COMMENT = 'Статус заказа';

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  order_status_id BIGINT UNSIGNED NOT NULL,
  delivery_city_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (order_status_id) REFERENCES order_statuses (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (delivery_city_id) REFERENCES rus_cities (id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT = 'Заказы';

DROP TABLE IF EXISTS order_products;
CREATE TABLE order_products (
  id SERIAL PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  order_quantity INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT = 'Состав заказа';

DROP TABLE IF EXISTS product_comments;
CREATE TABLE product_comments (
	user_id BIGINT UNSIGNED NOT NULL COMMENT 'Из таблицы orders, т.к. коммент может оставить только тот, кто купил товар',
    product_id BIGINT UNSIGNED NOT NULL COMMENT 'Из таблицы order_products',
	`text` TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	PRIMARY KEY(user_id, product_id)
) COMMENT 'Комментарий о товаре может оставить только тот п-ль, который купил товар для которого оставляет комментарий';

DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  id SERIAL PRIMARY KEY,
  `name` VARCHAR(255) COMMENT 'Название' UNIQUE,
  city_id BIGINT UNSIGNED NOT NULL COMMENT 'Город, в котором находится склад',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (city_id) REFERENCES rus_cities (id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT = 'Склады';

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL UNIQUE, 
  `value` INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (storehouse_id) REFERENCES storehouses (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT ON UPDATE CASCADE
) COMMENT = 'Запасы на складе';