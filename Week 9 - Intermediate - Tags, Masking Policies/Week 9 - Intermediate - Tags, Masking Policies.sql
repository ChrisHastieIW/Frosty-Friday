
-- Frosty Friday Challenge
-- Week 9 - Intermediate - Tags, Masking Policies
-- https://frostyfriday.org/2022/08/12/week-9-intermediate/

---------------------------------------------------
-- Change these variables as required

set system_role = 'CONSULTANT';
set security_role = 'SECURITYADMIN';

set warehouse = 'WH_CHASTIE';
set database = 'CH_FROSTY_FRIDAY';
set schema = 'WEEK_9';

-- Change these role names if they are
-- already taken in your Snowflake account
set role1 = 'CH_FROSTY_FRIDAY_ROLE_1';
set role2 = 'CH_FROSTY_FRIDAY_ROLE_2';

-------------------------------
-- Environment Configuration

use role identifier($system_role);

use warehouse identifier($warehouse);
use database identifier($database);
create or replace schema identifier($schema);

use schema identifier($schema);

------------------------------------------------------------------------------------------
---- Preparation

---------------------------------------------------
-- Do not change these variables

-- Concat required as username contains period .
set current_user = (select concat('"', current_user(), '"'));

set data_table = 'DATA_TO_BE_MASKED';

set fq_data_table = concat($database, '.', $schema, '.', $data_table);

---------------------------------------------------
-- Object setup

use role identifier($system_role);

use warehouse identifier($warehouse);
use database identifier($database);
use schema identifier($schema);

create or replace table identifier($fq_data_table) (
  first_name varchar, 
  last_name varchar,
  hero_name varchar
);

insert into identifier($fq_data_table) (first_name, last_name, hero_name) 
values 
    ('Eveleen', 'Danzelman','The Quiet Antman')
  , ('Harlie', 'Filipowicz','The Yellow Vulture')
  , ('Mozes', 'McWhin','The Broken Shaman')
  , ('Horatio', 'Hamshere','The Quiet Charmer')
  , ('Julianna', 'Pellington','Professor Ancient Spectacle')
  , ('Grenville', 'Southouse','Fire Wonder')
  , ('Analise', 'Beards','Purple Fighter')
  , ('Darnell', 'Bims','Mister Majestic Mothman')
  , ('Micky', 'Shillan','Switcher')
  , ('Ware', 'Ledstone','Optimo')
;

---------------------------------------------------
-- Security setup

use role identifier($security_role);

--Create Roles
create role if not exists identifier($role1);
create role if not exists identifier($role2);

--Assign required privileges to role 1
grant usage on warehouse identifier($warehouse) to role identifier($role1);
grant usage on database identifier($database) to role identifier($role1);
grant usage on all schemas in database identifier($database) to role identifier($role1);
grant select on all tables in database identifier($database) to role identifier($role1);

--Assign required privileges to role 2
grant usage on warehouse identifier($warehouse) to role identifier($role2);
grant usage on database identifier($database) to role identifier($role2);
grant usage on all schemas in database identifier($database) to role identifier($role2);
grant select on all tables in database identifier($database) to role identifier($role2);

--Assign roles to yourself
grant role identifier($role1) to user identifier($current_user);
grant role identifier($role2) to user identifier($current_user);

------------------------------------------------------------------------------------------
---- Main challenge

---------------------------------------------------
-- Change these variables as required

-- Concat required as username contains period .
set security_tag = 'SECURITY_TAG';
set fq_security_tag = concat($database, '.', $schema, '.', $security_tag);

set security_masking_role_level_1 = 'CH_FROSTY_FRIDAY_WEEK_9_SECURITY_CLASS_LEVEL_1';
set security_masking_role_level_2 = 'CH_FROSTY_FRIDAY_WEEK_9_SECURITY_CLASS_LEVEL_2';

set security_masking_policy = 'MASKING_POLICY';

set fq_security_masking_policy = concat($database, '.', $schema, '.', $security_masking_policy);

---------------------------------------------------
-- Security setup

--Use security role to create masking policy objects
use role identifier($security_role);

-- Create security roles
create or replace role identifier($security_masking_role_level_1);
create or replace role identifier($security_masking_role_level_2);
grant role identifier($security_masking_role_level_1) to role identifier($security_masking_role_level_2);

grant role identifier($security_masking_role_level_1) to role identifier($role1);
grant role identifier($security_masking_role_level_2) to role identifier($role2);

---------------------------------------------------
-- Object setup

--Use system role to create tage
use role identifier($system_role);

--Create Tags
create or replace tag identifier($fq_security_tag) 
  comment = 'sensitive data'
;

--Apply tags
alter table identifier($fq_data_table) 
  alter column first_name
    set tag identifier($fq_security_tag) = 'Level 1'
  , column last_name
    set tag identifier($fq_security_tag) = 'Level 2'
;

-- Create masking policy
create or replace masking policy identifier($fq_security_masking_policy) as (val string) returns string ->
  case
    when  system$get_tag_on_current_column($fq_security_tag) = 'Level 1'
      and is_role_in_session($security_masking_role_level_1) 
      then val
    when  system$get_tag_on_current_column($fq_security_tag) = 'Level 2'
      and is_role_in_session($security_masking_role_level_2) 
      then val
      else '*********'
  end
;

-- Apply masking policy to tag
-- Note that $system_role has been granted APPLY MASKING POLICY ON ACCOUNT by ACCOUNTADMIN
alter tag identifier($fq_security_tag) set masking policy identifier($fq_security_masking_policy);

---------------------------------------------------
-- Queries to test access

use role identifier($system_role);
use warehouse identifier($warehouse);
select * from identifier($fq_data_table);

use role identifier($role1);
use warehouse identifier($warehouse);
select * from identifier($fq_data_table);

use role identifier($role2);
use warehouse identifier($warehouse);
select * from identifier($fq_data_table);