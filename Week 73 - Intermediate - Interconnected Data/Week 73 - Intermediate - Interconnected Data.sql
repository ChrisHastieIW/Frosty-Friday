
-- Frosty Friday Challenge
-- Week 73 - Intermediate - Interconnected Data
-- https://frostyfriday.org/blog/2023/11/24/week-73-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_73;

use schema WEEK_73;

-------------------------------
-- Challenge Setup Script

-- Create table
create or replace table DEPARTMENTS (
    DEPARTMENT_NAME varchar
  , DEPARTMENT_ID int
  , HEAD_DEPARTMENT_ID int
)
as
select * from values
    ('Research & Development', 1, NULL)  -- The Research & Development department is the top level.
  , ('Product Development', 11, 1)
  , ('Software Design', 111, 11)
  , ('Product Testing', 112, 11)
  , ('Human Resources', 2, 1)
  , ('Recruitment', 21, 2)
  , ('Employee Relations', 22, 2)
;

-- Query the table
select * from DEPARTMENTS;

-------------------------------
-- Challenge Solution

-- Finally, a chance to use CONNECT BY!

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
select
    sys_connect_by_path(DEPARTMENT_NAME, ' -> ') as CONNECTION_TREE
  , DEPARTMENT_ID
  , HEAD_DEPARTMENT_ID
  , DEPARTMENT_NAME
from DEPARTMENTS
  start with DEPARTMENT_ID = 1
  connect by HEAD_DEPARTMENT_ID = prior DEPARTMENT_ID
;

-- Query the view
select * from CHALLENGE_OUTPUT
order by CONNECTION_TREE
;
