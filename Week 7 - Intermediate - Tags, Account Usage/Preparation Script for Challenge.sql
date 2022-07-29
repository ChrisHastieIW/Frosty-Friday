
---------------------------------------------------
-- Change these variables as required

set system_role = 'CONSULTANT';
set security_role = 'SECURITYADMIN';

set warehouse = 'WH_CHASTIE';
set database = 'CH_FROSTY_FRIDAY';
set schema = 'WEEK_7';

-- Change these user names if they are
-- already taken in your Snowflake account
set user1 = 'CH_FROSTY_FRIDAY_USER_1';
set user2 = 'CH_FROSTY_FRIDAY_USER_2';
set user3 = 'CH_FROSTY_FRIDAY_USER_3';

---------------------------------------------------
-- Do not change these variables

set villain_table = 'villain_information';
set monster_table = 'monster_information';
set weapon_storage_table = 'weapon_storage_location';

set fq_villain_table = concat($database, '.', $schema, '.', $villain_table);
set fq_monster_table = concat($database, '.', $schema, '.', $monster_table);
set fq_weapon_storage_table = concat($database, '.', $schema, '.', $weapon_storage_table);

---------------------------------------------------
-- Object setup

use role identifier($system_role);

use warehouse identifier($warehouse);
use database identifier($database);
use schema identifier($schema);

create or replace table identifier($fq_villain_table) (
	id INT,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	email VARCHAR(50),
	Alter_Ego VARCHAR(50)
);

insert into identifier($fq_villain_table) (id, first_name, last_name, email, Alter_Ego) 
values 
    (1, 'Chrissy', 'Riches', 'criches0@ning.com', 'Waterbuck, defassa')
  , (2, 'Libbie', 'Fargher', 'lfargher1@vistaprint.com', 'Ibis, puna')
  , (3, 'Becka', 'Attack', 'battack2@altervista.org', 'Falcon, prairie')
  , (4, 'Euphemia', 'Whale', 'ewhale3@mozilla.org', 'Egyptian goose')
  , (5, 'Dixie', 'Bemlott', 'dbemlott4@moonfruit.com', 'Eagle, long-crested hawk')
  , (6, 'Giffard', 'Prendergast', 'gprendergast5@odnoklassniki.ru', 'Armadillo, seven-banded')
  , (7, 'Esmaria', 'Anthonies', 'eanthonies6@biblegateway.com', 'Cat, european wild')
  , (8, 'Celine', 'Fotitt', 'cfotitt7@baidu.com', 'Clark''s nutcracker')
  , (9, 'Leopold', 'Axton', 'laxton8@mac.com', 'Defassa waterbuck')
  , (10, 'Tadeas', 'Thorouggood', 'tthorouggood9@va.gov', 'Armadillo, nine-banded')
;

create or replace table identifier($fq_monster_table) (
	id INT,
	monster VARCHAR(50),
	hideout_location VARCHAR(50)
);

insert into identifier($fq_monster_table) (id, monster, hideout_location)
values 
    (1, 'Northern elephant seal', 'Huangban')
  , (2, 'Paddy heron (unidentified)', 'Várzea Paulista')
  , (3, 'Australian brush turkey', 'Adelaide Mail Centre')
  , (4, 'Gecko, tokay', 'Tafí Viejo')
  , (5, 'Robin, white-throated', 'Turośń Kościelna')
  , (6, 'Goose, andean', 'Berezovo')
  , (7, 'Puku', 'Mayskiy')
  , (8, 'Frilled lizard', 'Fort Lauderdale')
  , (9, 'Yellow-necked spurfowl', 'Sezemice')
  , (10, 'Agouti', 'Najd al Jumā‘ī')
;


create table identifier($fq_weapon_storage_table) (
	id INT,
	created_by VARCHAR(50),
	location VARCHAR(50),
	catch_phrase VARCHAR(50),
	weapon VARCHAR(50)
);

insert into identifier($fq_weapon_storage_table) (id, created_by, location, catch_phrase, weapon) 
values 
    (1, 'Ullrich-Gerhold', 'Mazatenango', 'Assimilated object-oriented extranet', 'Fintone')
  , (2, 'Olson-Lindgren', 'Dvorichna', 'Switchable demand-driven knowledge user', 'Andalax')
  , (3, 'Rodriguez, Flatley and Fritsch', 'Palmira', 'Persevering directional encoding', 'Toughjoyfax')
  , (4, 'Conn-Douglas', 'Rukem', 'Robust tangible Graphical User Interface', 'Flowdesk')
  , (5, 'Huel, Hettinger and Terry', 'Bulawin', 'Multi-channelled radical knowledge user', 'Y-Solowarm')
  , (6, 'Torphy, Ritchie and Lakin', 'Wang Sai Phun', 'Self-enabling client-driven project', 'Alphazap')
  , (7, 'Carroll and Sons', 'Digne-les-Bains', 'Profound radical benchmark', 'Stronghold')
  , (8, 'Hane, Breitenberg and Schoen', 'Huangbu', 'Function-based client-server encoding', 'Asoka')
  , (9, 'Ledner and Sons', 'Bukal Sur', 'Visionary eco-centric budgetary management', 'Ronstring')
  , (10, 'Will-Thiel', 'Zafar', 'Robust even-keeled algorithm', 'Tin')
;

--Create Tags
create or replace tag security_class comment = 'sensitive data';

--Apply tags
alter table identifier($fq_villain_table) set tag security_class = 'Level Super Secret A+++++++';
alter table identifier($fq_monster_table) set tag security_class = 'Level B';
alter table identifier($fq_weapon_storage_table) set tag security_class = 'Level Super Secret A+++++++';

---------------------------------------------------
-- Security setup

use role identifier($security_role);

--Create Roles
create role identifier($user1);
create role identifier($user2);
create role identifier($user3);

--Assign Roles to yourself with all needed privileges
grant role identifier($user1) to role identifier($system_role);
grant USAGE on warehouse identifier($warehouse) to role identifier($user1);
grant usage on database identifier($database) to role identifier($user1);
grant usage on all schemas in database identifier($database) to role identifier($user1);
grant select on all tables in database identifier($database) to role identifier($user1);

grant role identifier($user2) to role identifier($system_role);
grant USAGE on warehouse identifier($warehouse) to role identifier($user2);
grant usage on database identifier($database) to role identifier($user2);
grant usage on all schemas in database identifier($database) to role identifier($user2);
grant select on all tables in database identifier($database) to role identifier($user2);

grant role identifier($user3) to role identifier($system_role);
grant USAGE on warehouse identifier($warehouse) to role identifier($user3);
grant usage on database identifier($database) to role identifier($user3);
grant usage on all schemas in database identifier($database) to role identifier($user3);
grant select on all tables in database identifier($database) to role identifier($user3);


---------------------------------------------------
-- Queries to build history

use role identifier($user1);
use warehouse identifier($warehouse);
select * from identifier($fq_villain_table);

use role identifier($user2);
use warehouse identifier($warehouse);
select * from identifier($fq_monster_table);

use role identifier($user3);
use warehouse identifier($warehouse);
select * from identifier($fq_weapon_storage_table);