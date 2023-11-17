
-- Frosty Friday Challenge
-- Week 72 - Basic - Execute Immediate
-- https://frostyfriday.org/blog/2023/11/17/week-72-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_72;

use schema WEEK_72;

-------------------------------
-- Challenge Setup Script

-- Create table
create table WEEK72_EMPLOYEES (
    employeeid int
  , firstname string
  , lastname string
  , dateofbirth date
  , position string
);

-------------------------------
-- Challenge Solution

-- Create the stage
create or replace stage STG_STAGE
  URL = 's3://frostyfridaychallenges/challenge_72/'
;

-- View files in stage
list @STG_STAGE;

-- File to execute has the following path:
-- s3://frostyfridaychallenges/challenge_72/insert.sql
-- which equates to:
-- '@STG_STAGE/insert.sql'

-- Execute immediate from
execute immediate
from '@STG_STAGE/insert.sql'
;

-- View the table
select * from WEEK72_EMPLOYEES;
