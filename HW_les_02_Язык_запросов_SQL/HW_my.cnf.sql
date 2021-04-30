/* Задача 1
	Установите СУБД MySQL. Создайте в домашней директории файл my.cnf, задав в нем логин и пароль, который указывался при установке.

	Создала данный файл в папке Windows. Заполнила его логином, паролем, все работает. MySQL загружается с консоли без ввода данных.
    Данное задание выполнила последним, т.к. не обратила внимаение на ссылки с видео по данной теме. Все выполняла в консоли.
 */

/* Задача 2
	Создайте базу данных example, разместите в ней таблицу users, состоящую из двух столбцов, числового id и строкового name.
 */

CREATE SCHEMA `example` DEFAULT CHARACTER SET utf8 ;
CREATE TABLE users (id INT, name VARCHAR(100));
insert into users values (1, 'Ivan');
select * from users;

/* Задача 3
	Создайте дамп базы данных example из предыдущего задания, разверните содержимое дампа в новую базу данных sample.
 */
-- mysqldump -u root -p example > example.sql
CREATE DATABASE sample;
-- mysql -u root -p sample < example.sql
use sample;
show tables;
select * from users;

/* Задача 4
	(по желанию) Ознакомьтесь более подробно с документацией утилиты mysqldump. 
	Создайте дамп единственной таблицы help_keyword базы данных mysql. 
	Причем добейтесь того, чтобы дамп содержал только первые 100 строк таблицы.
 */

-- mysqldump mysql help_keyword --where="1 limit 100" > dump.sql
