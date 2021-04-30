/* Lesson 6. Вебинар. Операторы, фильтрация, сортировка и ограничение. Агрегация данных */
/* HW_6 Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение. Агрегация данных” */

USE vk;

/* Задание 1. Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, 
который больше всех общался с нашим пользователем. */

-- смотрим кто друг нашего п-ля
SELECT initiator_user_id, target_user_id, status from friend_requests where status = 'approved' and (initiator_user_id = 1 OR target_user_id = 1);

-- выводим только друзей нашего п-ля
SELECT initiator_user_id from friend_requests where status = 'approved' and target_user_id = 1
UNION
SELECT target_user_id from friend_requests where status = 'approved' and initiator_user_id = 1;

SELECT from_user_id, to_user_id FROM messages;
-- from_user_id - кто писал - отсюда выбираем кто писал больше нашему п-лю
-- to_user_id - кому писал (1) - наш п-ль
SELECT from_user_id
FROM messages where to_user_id = 1;

-- Посмотим кто из всех п-лей больше всего писал нашему
SELECT from_user_id, COUNT(from_user_id) as count 
FROM messages where to_user_id = 1 
GROUP BY from_user_id ORDER BY `count` DESC LIMIT 1;

-- А теперь выведем кто чаще писал нашему п-лю из друзей
SELECT from_user_id, COUNT(from_user_id) AS `count`
FROM messages 
WHERE to_user_id = 1 AND from_user_id IN (
	SELECT initiator_user_id FROM friend_requests WHERE status = 'approved' AND target_user_id = 1
	UNION
	SELECT target_user_id FROM friend_requests where status = 'approved' AND initiator_user_id = 1
) 
GROUP BY from_user_id 
ORDER BY `count` DESC
LIMIT 1;


-- Задание 2. Подсчитать общее количество лайков, которые получили пользователи младше 10 лет.
SELECT id, user_id, media_id FROM likes;
SELECT id, media_type_id, user_id FROM media;
select user_id from profiles; 

-- п-ли младше 10 лет
SELECT user_id, TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age FROM profiles HAVING age < 10;
SELECT user_id FROM profiles where (TIMESTAMPDIFF(YEAR, birthday, NOW()) < 10);

/*  id from likes - кол-во лайков; user_id from likes - кто поставил лайк; media_id fro like - id from media 
    media_tupe_id from media - тип медиа; user_id - тот кто создал медиа
*/
-- Все п-ли младше 10 лет, у  которых есть медиа. (13 человек)
SELECT media.id as media_id, media.media_type_id as media_type, media.user_id as media_user_id, profiles.user_id
FROM media, profiles
WHERE media.user_id = profiles.user_id and profiles.user_id IN (select user_id from profiles where(TIMESTAMPDIFF(YEAR, profiles.birthday, NOW()) < 10));

-- Добавим столбец с лайками и людьми, которые ставили лайк
SELECT media.id `media.id`, likes.media_id  `likes.media_id`, media.user_id `media.user_id`, profiles.user_id `profiles.user_id`, likes.user_id `likes.user_id`, likes.id `likes.id`
FROM media, profiles, likes
WHERE media.user_id = profiles.user_id  and likes.media_id = media.id and profiles.user_id;

-- вывела все необходимое для решения задачи
SELECT likes.media_id as media_id_fr_likes, media.id as media_id_fr_media, likes.id as id_likes, likes.user_id as who_liked, media.user_id as who_created_fr_med, profiles.user_id as who_created_fr_prof 
FROM likes, media, profiles
where likes.media_id = media.id AND media.user_id = profiles.user_id;

SELECT likes.media_id as media_types, likes.id as id_likes, likes.user_id as who_liked, media.user_id as who_created_fr_med, profiles.user_id as who_created_fr_prof
FROM likes, media, profiles
where likes.media_id = media.id AND media.user_id = profiles.user_id and profiles.user_id IN (select user_id from profiles where(TIMESTAMPDIFF(YEAR, profiles.birthday, NOW()) < 10))
;

-- Выше при выполнении есть неточности в id_likes, who_liked, т.к. я группирую по пользователю, который выставил media, чей возраст меньше 10 лет. Поэтому я удаляю лишние столбцы.
-- Ответ: 
SELECT likes.media_id as media_types, profiles.user_id as user_id_who_created_fr_prof, COUNT(likes.id) 
FROM likes, media, profiles
where likes.media_id = media.id AND media.user_id = profiles.user_id and profiles.user_id IN (select user_id from profiles where(TIMESTAMPDIFF(YEAR, profiles.birthday, NOW()) < 10))
GROUP BY profiles.user_id;

-- Задание 3. Определить кто больше поставил лайков (всего): мужчины или женщины.

SELECT IF (
	-- Первое условие:
	(SELECT 
     COUNT(likes.user_id) AS count
	FROM profiles, likes
	WHERE likes.user_id = profiles.user_id
	GROUP BY profiles.gender
	ORDER BY  profiles.gender DESC
	LIMIT 1) 
    like (
	SELECT 
     COUNT(likes.user_id) AS count
	FROM profiles, likes
	WHERE likes.user_id = profiles.user_id
	GROUP BY profiles.gender
	ORDER BY profiles.gender
	LIMIT 1), 
    -- Если правда, то выведет строку ниже:
    'Лайки мужчин и женщин равны', 
    -- Иначе:
	(SELECT 
		CONCAT((select COUNT(likes.user_id) AS count
		FROM profiles, likes
		WHERE likes.user_id = profiles.user_id
		GROUP BY profiles.gender
		ORDER BY count DESC
		LIMIT 1), 
			' - ',
			(SELECT 
			CASE (profiles.gender)
				WHEN 'm' THEN 'male'
				WHEN 'f' THEN 'famale'
				ELSE 'not specified'
			 END AS gender
			FROM profiles, likes
			WHERE likes.user_id = profiles.user_id
			GROUP BY gender
			ORDER BY COUNT(likes.user_id) DESC
			LIMIT 1)) 
    )
) AS `Who is?`;