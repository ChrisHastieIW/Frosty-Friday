
-- Frosty Friday Challenge
-- Week 34 - Intermediate - Data Structuring
-- https://frostyfriday.org/2023/02/17/week-34-data-structuring/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_34;

use schema WEEK_34;

-------------------------------
-- Create challenge data

create or replace table CHALLENGE_DATA(
    code VARCHAR
  , code_parent VARCHAR
  , valid_until DATE
  , valid_from DATE
  , is_lowest_level BOOLEAN
  , max_level INTEGER
)
as
select * from values
    ('CC0193','EBGABA','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',1,7)
  , ('CC0194','EBGABA','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',1,7)
  , ('EBGABA','EBGAB','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('EBGAB','EBGA','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('EBGA','EBG','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('EBG','EB','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('EB','ZZ','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('ZZ',NULL,'9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,7)
  , ('7050307','CC','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',1,3)
  , ('CC','A1','9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,3)
  , ('A1',NULL,'9999-01-01 00:00:00.000','1950-01-01 00:00:00.000',0,3)
;

-- View challenge data
select * from CHALLENGE_DATA;

-------------------------------
-- Create view with CONNECT BY and array parsing

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
with connected_hierarchy as (
  select
      SYS_CONNECT_BY_PATH(code, '|') as path_string
    , split(path_string, '|') as member_array
    , *
  from CHALLENGE_DATA
    start with code_parent is null
    connect by code_parent = prior code
)
, lowest_levels_parsed as (
  select 
      coalesce(member_array[1], member_array[array_size(member_array)-1])::string as "level_1"
    , coalesce(member_array[2], member_array[array_size(member_array)-1])::string as "level_2"
    , coalesce(member_array[3], member_array[array_size(member_array)-1])::string as "level_3"
    , coalesce(member_array[4], member_array[array_size(member_array)-1])::string as "level_4"
    , coalesce(member_array[5], member_array[array_size(member_array)-1])::string as "level_5"
    , coalesce(member_array[6], member_array[array_size(member_array)-1])::string as "level_6"
    , coalesce(member_array[7], member_array[array_size(member_array)-1])::string as "level_7"
  from connected_hierarchy
  where is_lowest_level
)
select *
from lowest_levels_parsed
;

-- Query the view
select * from CHALLENGE_OUTPUT;
