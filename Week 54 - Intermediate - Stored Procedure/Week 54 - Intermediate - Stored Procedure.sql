
-- Frosty Friday Challenge
-- Week 54 - Intermediate - Stored Procedure
-- https://frostyfriday.org/2023/07/14/week-54-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_54;

use schema WEEK_54;

-------------------------------
-- Startup code

-- Table creation
create or replace table TABLE_A (
    ID int
  , NAME varchar
  , AGE int
)
as
select * from values
    (1, 'John', 25)
  , (2, 'Mary', 30)
  , (3, 'David', 28)
  , (4, 'Sarah', 35)
  , (5, 'Michael', 32)
  , (6, 'Emily', 27)
  , (7, 'Daniel', 29)
  , (8, 'Olivia', 31)
  , (9, 'Matthew', 26)
  , (10, 'Sophia', 33)
  , (11, 'Jacob', 24)
  , (12, 'Emma', 29)
  , (13, 'Joshua', 32)
  , (14, 'Ava', 30)
  , (15, 'Andrew', 28)
  , (16, 'Isabella', 34)
  , (17, 'James', 27)
  , (18, 'Mia', 31)
  , (19, 'Logan', 25)
  , (20, 'Charlotte', 29)
;

create or replace table TABLE_B (
    ID int
  , NAME varchar
  , AGE int
)
;

-- Role creation
-- Change to SECURITYADMIN role, if required
set current_user = (select concat('"', current_user(), '"'));
create role if not exists CH_FROSTY_FRIDAY_WEEK_54 comment = 'Owned by Chris Hastie for a Frosty Friday challenge';
grant role CH_FROSTY_FRIDAY_WEEK_54 to user identifier($current_user);
grant usage on database CH_FROSTY_FRIDAY to role CH_FROSTY_FRIDAY_WEEK_54;
grant usage on schema CH_FROSTY_FRIDAY.WEEK_54 to role CH_FROSTY_FRIDAY_WEEK_54;
grant select on all tables in schema CH_FROSTY_FRIDAY.WEEK_54 to role CH_FROSTY_FRIDAY_WEEK_54;
grant insert on all tables in schema CH_FROSTY_FRIDAY.WEEK_54 to role CH_FROSTY_FRIDAY_WEEK_54;
grant usage on warehouse WH_CHASTIE to role CH_FROSTY_FRIDAY_WEEK_54;

-------------------------------
-- Environment switch for new role

use role CH_FROSTY_FRIDAY_WEEK_54;
use database CH_FROSTY_FRIDAY;
use warehouse WH_CHASTIE;
use schema WEEK_54;

-------------------------------
-- Initial attempt to create and execute procedure

-- First, attempt to create the
-- procedure we wish to use
create or replace procedure COPY_TO_TABLE(FROM_TABLE STRING, TO_TABLE STRING, COUNT INT)
  RETURNS STRING
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.8'
  PACKAGES = ('snowflake-snowpark-python')
  HANDLER = 'copy_between_tables'
AS
$$
def copy_between_tables(snowpark_session, from_table, to_table, count):
  snowpark_session.table(from_table).limit(count).write.mode("append").save_as_table(to_table)
  return "Success"
$$
;

-- Result as expected:
-- Unknown function Insufficient privileges to operate on schema 'WEEK_54'

-------------------------------
-- Work around this with an Anonymous Procedure

-- Fortunately, Snowflake now have
-- anonymous procedures which can help:
-- https://docs.snowflake.com/en/sql-reference/sql/call-with
with COPY_TO_TABLE as procedure(FROM_TABLE STRING, TO_TABLE STRING, COUNT INT)
  RETURNS STRING
  LANGUAGE PYTHON
  RUNTIME_VERSION = '3.8'
  PACKAGES = ('snowflake-snowpark-python')
  HANDLER = 'copy_between_tables'
AS
$$
def copy_between_tables(snowpark_session, from_table, to_table, count):
  snowpark_session.table(from_table).limit(count).write.mode("append").save_as_table(to_table)
  return "Success"
$$
call COPY_TO_TABLE('TABLE_A', 'TABLE_B', 5)
;

-- Confirm population of TABLE_B
select * from TABLE_B;
