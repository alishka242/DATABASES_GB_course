/* Lesson 6. Вебинар. Операторы, фильтрация, сортировка и ограничение. Агрегация данных */

USE vk;

-- Ex_1 Вложенные запросы (долго выполняются, с помощью корреляции) с JOIN будет быстрее
SELECT id, firstname, lastname, 'city', 'main_photo' FROM users;

SELECT 
	id,
    firstname,
    lastname,
    (SELECT hometown FROM profiles WHERE user_id = users.id) as 'city',
    (SELECT filename FROM media WHERE id = (
		SELECT photo_id FROM profiles WHERE user_id = users.id
	)) AS 'main_photo'
FROM users;

-- Ex_2 Выбрать все фото определенного п-ля
SELECT media_type_id, filename FROM media 
WHERE user_id = 1 AND media_type_id IN (
	SELECT id FROM media_types WHERE name LIKE 'photo'
);

-- Ex_3 Выбрать видео п-ля, выбрать не по id, а по типу avi и mp4
SELECT * FROM media 
WHERE user_id = 1 AND (filename LIKE '%.avi' OR filename LIKE '%.mp4');

-- Ex_4 Выбрать фотки п-ля
SELECT 
	COUNT(*)
FROM media
WHERE user_id = 1 AND media_type_id = 1;

-- Агрегирующие функции (avg, max, min, count,sum)

-- Ex_5 Посчитать кол-во записей media каждого типа
-- Когда речь идет о каждом типе, значит тут точно нужно исп GROUP BY
SELECT
	media_type_id,
    (SELECT name FROM media_types WHERE id = media.media_type_id) as media_types,
	COUNT(*)
FROM media
GROUP BY media_type_id;

-- Ex_6 Архив данных, медиа. Сколько в каждом месяце было создано (за год или не привязываясь к году).
-- Сколько - COUNT(), Месяцев - MONTH(), Каждый (месяц) - GROUP BY(month)
SELECT 
	COUNT(*) AS cnt,
    MONTH(created_at) AS mounth_num,
	monthname(created_at) as mounth_name
FROM media
GROUP BY mounth_num
ORDER BY cnt DESC;

-- Ex_7 Сколько документов у каждого п-ля
SELECT 
	COUNT(id) AS cnt, /* считаем кол-во id-шники, которые сгруппированны по user_id, 
    т.е. все повторные п-ли (имейлы) будут выводиться один раз, но с учетом кол-ва их повтора. */
	(SELECT email FROM users WHERE id = media.user_id) AS user,
    created_at
FROM media
GROUP BY user_id /*сортировка по user_id*/;

-- Cколько в каждый месяц у п-лей было документов
-- !!! Чтобы понимать по какому полю группировать, нужно посмотреть в задание на слово КАЖДЫЙ
SELECT 
	COUNT(id) AS cnt, 
    MONTH(created_at) as month,
	(SELECT email FROM users WHERE id = media.user_id) AS user
FROM media
GROUP BY user_id, month
ORDER BY user;

/*  SELECT @@sql_mode; - параметры БД, 
	перед изменением лучше скопировать начальные значение, если понадобится откатиться 
	set @@sql_mode = cancat(@@sql_mode, ',ONLY_FULL_GROUP_BY');
*/

-- Ex_8 Вывести всех друзей какого-то п-ля
/* Тут выведутся все друзья одного п-ля, но не совсем верно, т.к. заявку может и наш п-ль 
отправить кому-то, и кто-то может отправить нам (initiator_user_id, target_user_id). 
Мы хотим сделать так, чтобы выводилась строка с друзьями и строка с нашим п-лем.
 */
SELECT initiator_user_id, target_user_id FROM friend_requests
WHERE (initiator_user_id = 1 OR target_user_id = 1)
	AND status = 'approved';

-- id друзей, поддтвердивших мою заявку
SELECT target_user_id FROM friend_requests
WHERE (initiator_user_id = 1) AND status = 'approved';
-- id друзей, заявку которых я принял
SELECT initiator_user_id FROM friend_requests
WHERE target_user_id = 1 AND status = 'approved';

-- Теперь объединим прерыдущие SELECTS с помощью UNION, при этом кол-во полей должно совпадать;
SELECT target_user_id FROM friend_requests
WHERE initiator_user_id = 1 AND status = 'approved'
UNION
SELECT initiator_user_id FROM friend_requests
WHERE target_user_id = 1 AND status = 'approved';

-- Теперь можно вывести документы всех друзей:
SELECT * FROM media WHERE user_id IN (
	SELECT target_user_id FROM friend_requests
	WHERE initiator_user_id = 1 AND status = 'approved'
	UNION
	SELECT initiator_user_id FROM friend_requests
	WHERE target_user_id = 1 AND status = 'approved'
);

-- 2 варианта вывода своих документов и документов друзей:
-- 1. Это не оч хороший способ, т.к. мы добавляем еще один SELECT, UNION - вывод будет медленей
SELECT * FROM media WHERE user_id =1 
UNION
SELECT * FROM media WHERE user_id IN (
	SELECT target_user_id FROM friend_requests
	WHERE (initiator_user_id = 1) AND status = 'approved'
	UNION
	SELECT initiator_user_id FROM friend_requests
	WHERE (target_user_id = 1) AND status = 'approved'
) ORDER BY user_id DESC;
-- 2. 
SELECT * FROM media WHERE user_id IN (
	SELECT target_user_id FROM friend_requests
	WHERE (initiator_user_id = 1) AND status = 'approved'
	UNION
	SELECT initiator_user_id FROM friend_requests
	WHERE (target_user_id = 1) AND status = 'approved'
) OR user_id = 1
ORDER BY user_id DESC;

-- Ex_9 Подсчет лайков для моих документов (media) 
--  для моих документов = для каждого моего документа
SELECT 
	media_id,
	COUNT(*) 
FROM likes
WHERE media_id IN (
	SELECT id FROM media WHERE user_id = 1
)
GROUP BY media_id;

-- Ex_10 Выбрать сообщения от п-ля и к п-лю и к самому себе
SELECT * FROM messages
	WHERE from_user_id = 1
	OR to_user_id = 1
ORDER BY created_at DESC;

-- Добавим колонку is_read DEFAULT 0
ALTER TABLE messages
ADD COLUMN is_read bit DEFAULT b'0';

-- Ex_11 Получим все сообщения, которые п-ль не прочитал
SELECT * FROM messages
	WHERE to_user_id = 1
		AND is_read = 0
ORDER BY created_at DESC;

UPDATE messages
set is_read = b'1'
where created_at < DATE_SUB(NOW(), INTERVAL 100 DAY);

-- Ex_12 
SELECT 
	user_id,
    CASE(gender)
		when 'f' then 'женский'
        when 'm' then 'мужской'
        else 'нет'
    END as gender,
    TIMESTAMPDIFF(YEAR, birthday, NOW()) as age -- выводит возраст, точнее функция определяет разницу между датами
	FROM profiles
    WHERE user_id IN (
    SELECT target_user_id FROM friend_requests	WHERE (initiator_user_id = 1) AND status = 'approved'
	UNION
	SELECT initiator_user_id FROM friend_requests WHERE (target_user_id = 1) AND status = 'approved'
);

/* Ex_13 Если п-ль состоит в группе, он должен видеть кнопку выйти из группы 
 и наоборот если п-ль не состоит в группе, он должен видеть кнопку войти в группу, то */
 
 select * from communities;
 ALTER TABLE communities ADD admin_user_id INT DEFAULT 1 NOT NULL;
 
 update communities 
 set admin_user_id = 2
 where id = 6;
 
 -- Является ли п-ль админом группы?
 -- user_id =1
 -- community_id = 5
 -- 1 - да, 0 - нет
 SELECT 1 = (SELECT admin_user_id FROM communities WHERE id = 6) AS 'is admin';
 
 ALTER TABLE friend_requests
 ADD CHECK (initiator_user_id <> target_user_id);
 
  