SET GLOBAL time_zone = '+8:00';

DROP DATABASE IF EXISTS wild_shop;
CREATE DATABASE wild_shop;
USE wild_shop;

DROP TABLE IF EXISTS newsCategories;
CREATE TABLE newsCategories (
	id SERIAL,
    `name` VARCHAR(145)   
);

DROP TABLE IF EXISTS news;
CREATE TABLE news (
	id SERIAL,
    title VARCHAR(255),
    `text` TEXT,
    category_id BIGINT UNSIGNED NOT NULL,
    views INT DEFAULT 0,
    
    FOREIGN KEY (category_id) references newsCategories (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS images;
CREATE TABLE images(
	id SERIAL,
    `name` VARCHAR(255),
    likes INT UNSIGNED DEFAULT 0
);

DROP TABLE IF EXISTS product_categories;
CREATE TABLE product_categories (
	id SERIAL,
	`name` VARCHAR(255)
);

DROP TABLE IF EXISTS products;
CREATE TABLE products(
	id SERIAL,
	`name` VARCHAR(255) UNIQUE,
    category_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
    img_name VARCHAR(255),
    `description` text,
    price DECIMAL NOT NULL DEFAULT 1,
    createdAt DATETIME NOT NULL DEFAULT NOW(),
    
    FOREIGN KEY (category_id) references product_categories (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL,
	login VARCHAR(255) UNIQUE,
    `session_id` text,
    pass text
);

DROP TABLE IF EXISTS comments;
CREATE TABLE comments(
	id SERIAL,
    user_id BIGINT UNSIGNED DEFAULT NULL,
    `text` text,
    /* img_id BIGINT UNSIGNED NOT NULL DEFAULT 0, 0 - отзыв о мазагине, т.е. картинки нет*/
    createdAt DATETIME NOT NULL DEFAULT NOW(),
    
	FOREIGN KEY (user_id) references users (id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS basket;
CREATE TABLE basket (
	id SERIAL,
    user_id BIGINT UNSIGNED DEFAULT NULL,
	product_id BIGINT UNSIGNED NOT NULL,
    session_id TEXT NOT NULL,
    `count` INT(11) NOT NULL DEFAULT '1',
	price DECIMAL NOT NULL,

    FOREIGN KEY (user_id) references users (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (product_id) references products (id) ON UPDATE CASCADE ON DELETE CASCADE
);
select * from orders;
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	id SERIAL,
	`name` VARCHAR(145) NOT NULL,
    `phone` TEXT NOT NULL,
    `email` TEXT NOT NULL,
    `session_id` TEXT NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    `count` INT(11) NOT NULL DEFAULT '1',
	price DECIMAL NOT NULL,
	created_at DATETIME DEFAULT NOW(),
    `status` ENUM ('новый', 'собран', 'отправлен', 'доставлен') DEFAULT 'новый',
    
    FOREIGN KEY (product_id) references products (id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO newsCategories (`name`)
VALUES 
('спорт'),
('наука'),
('общество'),
('мир');

INSERT INTO  news (title, `text`, category_id, views)
VALUES 
('Иностранный язык для особенных детей: шпаргалка для учителя', 'МОСКВА, 25 мая — РИА Новости. Ученые Московского городского педагогического университета (МГПУ) разработали модульную программу повышения квалификации учителей иностранного языка, работающих в инклюзивном классе. В программе сформулированы дополнительные профессиональные компетенции педагога, необходимые для успешной работы с детьми с особыми образовательными потребностями, связанными с ограничениями возможностями здоровья (слух, зрение, работа опорно-двигательного аппарата). Исследование опубликовано в журнале Integration of Education.', '2', '2'),
('Путин поддержал идею об отчетах депутатов перед избирателями', 'Президент РФ Владимир Путин поддержал идею обязать депутатов Госдумы и парламентские партии на постоянной основе отчитываться перед избирателями о проделанной работе.
Депутат Александр Хинштейн (ЕР) на встрече президента с руководством партии "Единая Россия" и участниками праймериз предложил обязать парламентские партии и депутатов Госдумы на постоянной основе отчитываться перед избирателями о проделанной работе.', '4', '1'),
('Головин и Миранчук прибыли в расположение сборной России в Австрии', 'ЕВРО-2020. Полузащитник "Монако" Александр Головин и хавбек итальянской "Аталанты" Алексей Миранчук прибыли в расположение сборной России по футболу.
Сборная России проводит сбор в Австрии в преддверии чемпионата Европы.
ЕВРО-2020 пройдет в 11 городах Европы, в том числе в Санкт-Петербурге, с 11 июня по 11 июля. На групповом этапе финального турнира сборная России встретится с командами Бельгии (12 июня), Финляндии (16 июня) и Дании (21 июня).', '1', '3'),
('Овечкин рассказал, в каком клубе хочет завершить карьеру', 'МОСКВА, 25 мая - РИА Новости. Российский нападающий Александр Овечкин заявил, что хотел бы завершить карьеру хоккеиста в клубе НХЛ "Вашингтон".', '1', '5'),
('В Петербурге предложили построить второй по высоте небоскреб в мире', 'МОСКВА, 25 мая - РИА Новости. "Газпром" предложил построить в Санкт-Петербурге "Лахта Центр 2", который станет вторым по высоте небоскребом в мире, говорится в сообщении компании.
Новая градостроительная инициатива была представлена на заседании межведомственного совета по реализации соглашения о сотрудничестве между Санкт-Петербургом и "Газпромом".', '3', '10');

INSERT INTO images (`name`, likes)
VALUES 
('01.jpg', 2),
('02.jpg', 6),
('03.jpg', 8),
('04.jpg', 4),
('05.jpg', 0),
('06.jpg', 9),
('07.jpg', 22),
('08.jpg', 20),
('09.jpg', 14),
('10.jpg', 15),
('11.jpg', 68),
('12.jpg', 12),
('13.jpg', 23),
('14.jpg', 31),
('15.jpg', 36);

INSERT INTO product_categories (`name`)
VALUES 
('Не указано'),
('Фрукты'),
('Напитки'),
('Пиццы');

INSERT INTO products (`name`, category_id, img_name, `description`, price)
VALUES 
('Яблоко красное', 2, 'apple01.png',
'Яблоки – очень популярный и, пожалуй, наиболее распространенный в нашей стране фрукт. 
Регулярное их употребление помогает поддерживать необходимый уровень витаминов и минералов, важных для человеческого организма. 
В них содержатся витамины С, В1, В2, Р, Е, каротин, калий, железо, марганец, кальций, пектины, сахара, органические кислоты и другие полезные вещества.',
12),
('Пиццa c пoмидopaми', 4, 'pizza01.png', 
'Пиццa c пoмидopaми — пpocтaя и вкуcнaя. В ocнoвe ee клaccичecкиe итaльянcкиe peцeпты. Ингpeдиeнты:пoмидopы, cыp, зeлeнь и oливкoвoe мacлo.',
24),
('Чай черный с лимоном', 3, 'tea01.png', 
'Байховый чай (от китайского бай хуа — «белый цветок», название едва распустившихся почек чайного листа, одного из компонентов чая, придающих ему аромат и вкус) — торговое название рассыпного чая, выработанного в виде отдельных чаинок.',
10);

INSERT INTO users (login, pass)
VALUES 
('admin', '$2y$10$kSnRXB1y/SKoDJtGvTkfuebJ8e1e6bmUJiKUrwvAMBP88jjSb8HwK'),
('user', '$2y$10$JAHvykZ0KxWWKFv6cBVzzeCsCjiyQDiN2NmxXko8T.Cd40DCW7ph.');

INSERT INTO comments (`user_id`, `text`, createdAt)
VALUES 
(1, 'Все супер!', '2021-05-26 12:53:31'),
(2, 'Мне не понравилось(', '2021-05-26 15:53:31'),
(1, 'Высшее качество обслуживания!', '2021-05-28 12:53:31'),
(2, 'Я больше ни ногой', '2021-05-29 19:53:31'),
(1, 'таким как ты никогда ничего не нравится', '2021-05-30 10:53:31');