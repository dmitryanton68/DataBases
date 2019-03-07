# Задача 1. У Вас есть социальная сеть, где пользователи (id, имя) могут ставить друг другу лайки.

# а) Создайте необходимые таблицы для хранения данной информации. 
CREATE DATABASE likes;
USE likes;
CREATE TABLE users (
    id INT AUTO_INCREMENT,
    name VARCHAR(255),
    PRIMARY KEY (id)
);
CREATE TABLE likes (
    id INT AUTO_INCREMENT,
    id_user_post_like INT,
    id_user_get_like INT,
    PRIMARY KEY (id),
    CONSTRAINT fk_UserPostLike FOREIGN KEY (id_user_post_like)
    REFERENCES users(id)
    ON DELETE CASCADE,
    CONSTRAINT fk_UserGetLike FOREIGN KEY (id_user_get_like)
    REFERENCES users(id)
    ON DELETE CASCADE
);

# б) Создайте запрос, который выведет информацию:
# ● ид пользователя;
# ● имя;
# ● лайков получено;
# ● лайков поставлено;
# ● взаимные лайки.

SELECT users.id, users.name, likesPosted.count_posted, likesGotten.count_gotten, mutual.mutaul_likes FROM users
LEFT JOIN (SELECT likes.id_user_post_like, COUNT(likes.id_user_post_like) AS count_posted
FROM likes GROUP BY likes.id_user_post_like) AS likesPosted ON users.id=likesPosted.id_user_post_like
LEFT JOIN (SELECT likes.id_user_get_like, COUNT(likes.id_user_get_like) AS count_gotten
FROM likes GROUP BY likes.id_user_get_like) AS likesGotten ON users.id=likesGotten.id_user_get_like
LEFT JOIN (SELECT l1.id_user_get_like AS user_id, COUNT(l1.id_user_get_like) AS mutaul_likes FROM likes AS l1, likes AS l2
WHERE l1.id_user_get_like=l2.id_user_post_like AND l1.id_user_post_like=l2.id_user_get_like 
GROUP BY l1.id_user_get_like) AS mutual ON users.id=mutual.user_id;

# Задача 2. Для структуры из задачи 1 выведите список всех пользователей, которые поставили лайк пользователям A и B (id задайте произвольно), но при этом не поставили лайк пользователю C.

SELECT DISTINCT users.id FROM likes
LEFT JOIN users ON likes.id_user_post_like=users.id
WHERE (likes.id_user_get_like=2 OR likes.id_user_get_like=3) AND users.id NOT IN 
(SELECT likes.id_user_post_like FROM likes WHERE likes.id_user_get_like=4);

# Задача 3. 

# а) Добавим сущности «Фотография» и «Комментарии к фотографии».
CREATE TABLE photo (
    id INT AUTO_INCREMENT,
    PRIMARY KEY (id)
);
CREATE TABLE comment (
    id INT AUTO_INCREMENT,
    PRIMARY KEY (id)
);

# б) Нужно создать функционал для Пользователей, который позволяет ставить лайки не только пользователям, но и фото или комментариям к фото.
ALTER TABLE likes DROP FOREIGN KEY fk_UserGetLike;
ALTER TABLE likes DROP COLUMN id_user_get_like;
ALTER TABLE likes DROP COLUMN id;
ALTER TABLE likes ADD COLUMN entity_type INT(1);
ALTER TABLE likes ADD COLUMN entity_id INT(11);

CREATE TABLE entity_types (
    id INT AUTO_INCREMENT,
    type_name VARCHAR(50),
    PRIMARY KEY (id)
);

ALTER TABLE likes ADD FOREIGN KEY (entity_type) REFERENCES entity_types(id);

# в) Учитывайте следующие ограничения:
# ● пользователь не может дважды лайкнуть одну и ту же сущность;

ALTER TABLE likes ADD PRIMARY KEY (id_user_post_like, entity_type, entity_id);

# ● пользователь имеет право отозвать лайк;

DELETE FROM likes WHERE id_user_post_like=3 AND entity_type=3 AND entity_id=3;

# ● необходимо иметь возможность считать число полученных сущностью лайков;

SELECT COUNT(*) FROM likes WHERE entity_type=3 AND entity_id=3;

# ● необходимо иметь возможность выводить список пользователей, поставивших лайки сущности;

SELECT users.name FROM users
JOIN likes ON users.id=likes.id_user_post_like
WHERE entity_type=3 AND entity_id=3;

# ● в будущем могут появиться новые виды сущностей, которые можно лайкать.

CREATE TABLE entry (
    id INT AUTO_INCREMENT,
    PRIMARY KEY (id)
);

INSERT INTO entity_types (type_name) VALUES ('entry');

SELECT * FROM likes;
SELECT * FROM users;
