
-- Frosty Friday Challenge
-- Week 84 - Basic - Staging
-- https://frostyfriday.org/blog/2024/03/08/week-84-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_84;

use schema WEEK_84;

-------------------------------
-- Challenge Setup Script

-- Create the challenge stage
create or replace stage "STG__SOURCE"
  URL = 's3://frostyfridaychallenges/challenge_84/'
;

-------------------------------
-- Challenge Solution

-- Create the solution stage
create or replace stage "STG__DESTINATION";

-- View the files in the source stage
list @"STG__SOURCE" pattern = '.*\\/(_+[a-z]+){3,5}[.]txt';

-- Copy the files
copy files into @"STG__DESTINATION"
  from @"STG__SOURCE"
  pattern = '.*\\/(_+[a-z]+){3,5}[.]txt'
;