
-- Frosty Friday Challenge
-- Week 82 - Basic - Staging Files
-- https://frostyfriday.org/blog/2024/02/23/week-82-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_82;

use schema WEEK_82;

-------------------------------
-- Challenge Solution

-- Create the starting stage
create or replace stage STG__STARTING_STAGE
  URL = 's3://frostyfridaychallenges/challenge_82/'
;

-- View the files in the starting stage
list @STG__STARTING_STAGE;

-- Create the destination stage
create or replace stage STG__DESTINATION_STAGE;

-- View the files in the destination stage.
-- This should be empty at this point.
list @STG__STARTING_STAGE;

-- Copy the files
copy files into @STG__DESTINATION_STAGE
  from @STG__STARTING_STAGE
;

-- View the files in the destination stage.
-- This should now contain the file(s)
-- from the starting stage
list @STG__STARTING_STAGE;
