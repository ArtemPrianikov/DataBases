/*1. связать все таблицы vk через внешние ключи
Сначала попробуем повторить всё из видеоурока*/

-- ВНЕШНИЕ КЛЮЧИ ТАБЛИЦЫ profiles
ALTER TABLE profiles
	ADD CONSTRAINT profiles_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT profiles_photo_id_fk
		FOREIGN KEY (photo_id) REFERENCES photos(id)
			ON DELETE SET NULL;

-- ВНЕШНИЕ КЛЮЧИ ТАБЛИЦЫ messages
ALTER TABLE messages
	ADD CONSTRAINT profiles_from_user_id_fk
		FOREIGN KEY (from_user_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT profiles_to_user_id_fk
		FOREIGN KEY (to_user_id) REFERENCES users(id)
			ON DELETE CASCADE;

-- условие CASCADE не подходит!
-- пришлось убрать внешние ключи для таблицы сообщений
ALTER TABLE messages DROP FOREIGN KEY profiles_from_user_id_fk;
ALTER TABLE messages DROP FOREIGN KEY profiles_to_user_id_fk;

-- пришлось создать заново ключи без условия CASCADE
ALTER TABLE messages
	ADD CONSTRAINT profiles_from_user_id_fk
		FOREIGN KEY (from_user_id) REFERENCES users(id),
	ADD CONSTRAINT profiles_to_user_id_fk
		FOREIGN KEY (to_user_id) REFERENCES users(id);

-- также пришлось удалить ключи для таблицы profiles
ALTER TABLE profiles DROP FOREIGN KEY profiles_user_id_fk;
ALTER TABLE profiles DROP FOREIGN KEY profiles_photo_id_fk;

--
ALTER TABLE profiles
	ADD CONSTRAINT profiles_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT profiles_photo_id_fk
		FOREIGN KEY (photo_id) REFERENCES media(id)
			ON DELETE SET NULL;

-- получаю ошибку: Column 'photo_id' cannot be NOT NULL: needed in a foreign key constraint 'profiles_photo_id_fk' SET NULL
-- придётся разрешить значения NULL
ALTER TABLE profiles MODIFY photo_id INT(10) UNSIGNED;

-- ещё раз установка ключей
ALTER TABLE profiles
	ADD CONSTRAINT profiles_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT profiles_photo_id_fk
		FOREIGN KEY (photo_id) REFERENCES media(id)
			ON DELETE SET NULL;

/*таблица communities_users, для неё родительским элементом должен быть id из таблицы users,
также таблица communities_users связана с таблицей communities, свяжем все сразу */

ALTER TABLE communities_users
	ADD CONSTRAINT communities_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT community_id_fk
		FOREIGN KEY (community_id) REFERENCES communities(id)
			ON DELETE CASCADE;
			
/*в обоих случаях посчитал нужным применить каскад, потому что: если ползователь исчезает из соц. сети,
то бессмысленно продолжать его учитывать в составе группы. Также если исчезает группа из списка групп, то зачем хранить
принадлежность пользователя к удалённой группе*/

ALTER TABLE friendship
	ADD CONSTRAINT user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE,
	ADD CONSTRAINT friend_id_fk
		FOREIGN KEY (friend_id) REFERENCES users(id)
			ON DELETE CASCADE;

/* Сразу два внешних ключа связываются с одной и той же таблицей
вопрос, стоит ли хранить пользователя, который удалён из сети, в друзьях, можно считать дискусионным, люди ведь ходят
на кладбища. Я буду считать, что если удалился, то не надо его показывать в друзьях даже со статусом "удалённый"*/

-- теперь таблица media

ALTER TABLE media
	ADD CONSTRAINT media_type_id_fk
		FOREIGN KEY (media_type_id) REFERENCES media_types(id)
			ON DELETE SET NULL,
	ADD CONSTRAINT media_type_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE;

/* вот здесь уже сценарий поведения при удалении типа медиа лучше оставить SET NULL, так как файл медиа не должен удаляться
если для него не определён тип, а при удалении юзера, возможно, удалять его файлы имеет смысл? Не знаю, но пусть пока так
Опять столкнулся с тем, что поле содержит запрет на NULL:
Column 'media_type_id' cannot be NOT NULL: needed in a foreign key constraint 'media_type_id_fk' SET NULL
поэтому инструкцию SET NULL выполнить не удастся, надо менять*/

ALTER TABLE media MODIFY media_type_id INT(10) UNSIGNED;

-- снова попытка:
ALTER TABLE media
	ADD CONSTRAINT media_type_id_fk
		FOREIGN KEY (media_type_id) REFERENCES media_types(id)
			ON DELETE SET NULL,
	ADD CONSTRAINT media_type_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id)
			ON DELETE CASCADE;
-- на этот раз всё прошло

-- таблица likes должна быть связана внешними ключами сразу с тремя таблицами: like_types, media, users

ALTER TABLE likes
	ADD CONSTRAINT likes_type_id_fk
		FOREIGN KEY (likes_type_id) REFERENCES like_types(id)
			ON DELETE SET NULL,
	ADD CONSTRAINT likes_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id);
		
/* тут решено при удалении какого-то типа лайков не удалять лайки, а выставлять категорию в NULL,
При удалении юзера удалять его лайки было бы как-то нелогично, кажется на первый взгляд. В этом случай лайкаемая сущность
может начать "терять" налайканное :) - кошмар многих пользователей соц сетей, наверно.
Ошибка:
Column 'likes_type_id' cannot be NOT NULL: needed in a foreign key constraint 'item_id_fk' SET NULL
Пришлось менять свойства поля: */

ALTER TABLE likes MODIFY likes_type_id INT(10) UNSIGNED;
-- теперь запрос сработал

/* теперь надо в таблицу лайков по item_id установить связь с лайкаемыми сущностями, т.е. таблицами
users, photos, media */

ALTER TABLE likes MODIFY item_id INT(10) UNSIGNED;

ALTER TABLE likes
	ADD CONSTRAINT item_id_fk1
		FOREIGN KEY (item_id) REFERENCES users(id)
			ON DELETE SET NULL,
	ADD CONSTRAINT item_id_fk2
		FOREIGN KEY (item_id) REFERENCES media(id)
			ON DELETE SET NULL,
	ADD CONSTRAINT item_id_fk3
		FOREIGN KEY (item_id) REFERENCES photos(id)
			ON DELETE SET NULL;

/* получил ошибку
Cannot add or update a child row: a foreign key constraint fails (`vk`.`#sql-697_17`, CONSTRAINT `item_id_fk1` FOREIGN KEY 
(`item_id`) REFERENCES `users` (`id`) ON DELETE SET NULL)
вероятно, это - тот случай, когда надо связку производить на уровне приложения? */


