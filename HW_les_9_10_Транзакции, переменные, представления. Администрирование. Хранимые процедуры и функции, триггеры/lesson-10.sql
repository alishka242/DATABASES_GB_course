USE vk;
-- lesson-10
DROP PROCEDURE IF EXISTS sp_friendship_offers;

DELIMITER //

CREATE PROCEDURE sp_friendship_offers(IN for_user_id BIGINT)
BEGIN
	WITH friends AS (
		SELECT initiator_user_id AS id
		FROM friend_requests
		WHERE status = 'approved' AND target_user_id = for_user_id
		UNION
		SELECT target_user_id AS id
		FROM friend_requests
		WHERE status = 'approved' AND initiator_user_id = for_user_id
    )
	-- общий город
    SELECT p2.user_id
    FROM profiles p1
    JOIN profiles p2 ON p1.hometown = p2.hometown
    WHERE p1.user_id = for_user_id AND p2.user_id <> for_user_id
    UNION
	-- состоят в одной группе
    SELECT uc_2.user_id
    FROM users_communities uc_1
    JOIN users_communities uc_2 ON uc_1.community_id = uc_2.community_id
    WHERE uc_1.user_id = for_user_id AND uc_2.user_id <> for_user_id
    UNION    
	-- друзья друзей
    
    SELECT fr.initiator_user_id
    FROM friends AS f
    JOIN friend_requests fr ON fr.target_user_id = f.id
    WHERE fr.initiator_user_id != for_user_id AND fr.status = 'approved'
    UNION 
    SELECT fr.target_user_id
    FROM friends AS f
    JOIN friend_requests fr ON fr.initiator_user_id = f.id
    WHERE fr.target_user_id != for_user_id AND fr.status = 'approved'
    ORDER BY rand()
    LIMIT 5;
    
END//

DELIMITER ;

CALL sp_friendship_offers(1);
SELECT TRUNCATE(`friendship_direction`(1), 2) AS `user popularity`;


START TRANSACTION;
INSERT INTO users (fiersname, lastname, email, phone)
VALUES ('New', 'User', 'new@mail.com', 9333333333);

SET @last_user_id = last_insert_id();

INSERT INTO profiles (user_id, gender, birthday, hometown)
VALUES (@last_user_id, 'M', '1999-10-10', 'Moscow');
COMMIT;