
-- Frosty Friday Challenge
-- Week 91 - Intermediate - Git and Stored Procs
-- https://frostyfriday.org/blog/2024/04/26/week-91-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema "WEEK_91";

use schema "WEEK_91";

-------------------------------
-- Challenge Setup Script

-- Create the table
create or replace table "PEOPLE" (
    "ID" integer
  , "NAME" varchar
)
as
select * from values
    (1, 'Alice')
  , (2, 'Bob')
  , (3, 'Charlie')
  , (4, 'David')
  , (5, 'Eva')
  , (6, 'Fiona')
  , (7, 'George')
  , (8, 'Hannah')
  , (9, 'Ian')
  , (10, 'Julia')
;

-- Review the table
select * from "PEOPLE";

-------------------------------
-- Challenge Solution

-- Create the API integration
create or replace api integration "API__GIT__FROSTY_FRIDAYS"
  api_provider = GIT_HTTPS_API
  api_allowed_prefixes = ('https://github.com/FrostyFridays/')
  comment = 'API integration for Frosty Friday challenges stored in GitHub'
  enabled = TRUE
;

-- Create the Git repository
create or replace git repository "FF_WEEK_91"
  origin = 'https://github.com/FrostyFridays/FF_week_91.git'
  api_integration = "API__GIT__FROSTY_FRIDAYS"
;

-- Fetch, just in case
alter git repository "FF_WEEK_91" fetch;

show git repositories;

-- Create the stored procedure
create or replace procedure "ADD_1" (TABLE_NAME varchar, COLUMN_NAME varchar)
  returns table()
  language python
  runtime_version = '3.10'
  packages = ('snowflake-snowpark-python')
  imports = ('@FF_WEEK_91/branches/main/add_1.py')
  handler = 'add_1.add_one_to_column';
;

-- Test the stored procedure
call "ADD_1"('PEOPLE', 'ID');
