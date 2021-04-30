use shop;

drop table if exists logs;
create table logs (
    `table_name` VARCHAR(150) not null, 
    `table_id` BIGINT UNSIGNED NOT NULL,
    `column_name` VARCHAR(100) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    
) ENGINE = ARCHIVE;

DELIMITER //
DROP TRIGGER IF EXISTS `add_value_in_log`;
CREATE TRIGGER `add_value_in_log` AFTER INSERT ON users
for each row BEGIN
	INSERT INTO logs (`table_name`, `table_id`, `column_name`)
    VALUES(users, users.id, users.name);
END //

DELIMITER ;
