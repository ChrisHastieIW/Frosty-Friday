
-- Frosty Friday Challenge
-- Week 47 - Basic - Tagging in Snowsight
-- https://frostyfriday.org/2023/05/26/week-47-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_47;

use schema WEEK_47;

-------------------------------
-- Create challenge data

create or replace table FROSTY_TAG_TABLE (
    KEY int
  , VALUE string
);

create or replace tag PURPOSE;

-------------------------------
-- Return challenge output

-- Run the following after adding the tag
-- using the Snowsight interface
SELECT SYSTEM$GET_TAG('PURPOSE', 'FROSTY_TAG_TABLE', 'table');
