
-- Frosty Friday Challenge
-- Week 100 - Hard - Streamlit Images
-- https://frostyfriday.org/blog/2024/07/05/week-100-hard/

-------------------------------
-- Environment Configuration

use database "CH_FROSTY_FRIDAY";

use warehouse "WH_CHASTIE";

create schema if not exists "WEEK_100";

use schema "WEEK_100";

-------------------------------
-- Challenge Setup Script

create or replace table "IMAGES" (
    "FILE_NAME" string
  , "IMAGE_BYTES" string
)
;

-------------------------------
-- Challenge Solution

-- First step is to populate the table.
-- Going forwards, I'll be using a metadata-driven approach
-- for ingestions in Frosty Friday challenges. I spoke at
-- Snowflake Summit 2024 on the topic of metadata-driven
-- ingestion and it fits nicely for many Frosty Friday challenges.

-- Create file format for CSV
create or replace file format "FF__CSV"
  type = 'CSV'
  parse_header = TRUE
;

-- Create the stage pointing to the files
-- Create the stage
create or replace stage "STG__FROSTY_AWS_STAGE"
  url = 's3://frostyfridaychallenges/'
;

-- Identify the files
list @"STG__FROSTY_AWS_STAGE"/challenge_100;

copy into "IMAGES"
from @"STG__FROSTY_AWS_STAGE"/challenge_100
  file_format = "FF__CSV"
  match_by_column_name = CASE_INSENSITIVE
;

-- Review data
select * from "IMAGES";

-- Looks like we have 5 images stored as bytes.
-- From here, switch to the streamlit.