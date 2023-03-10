
-- Frosty Friday Challenge
-- Week 37 - Intermediate - Unstructured Data
-- https://frostyfriday.org/2023/03/10/week-37-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_37;

use schema WEEK_37;

-------------------------------
-- Create challenge stage

-- Directly creating stage without storage integration for simplicity
create or replace stage external_stage
  url = 's3://frostyfridaychallenges/challenge_37/'
  credentials = (aws_role = 'arn:aws:iam::184545621756:role/week37')
  directory = (
    enable = TRUE
    refresh_on_create = TRUE
    auto_refresh = FALSE -- No need for this as it is a one-off challenge
  )
;

-------------------------------
-- Create directory table view

-- Create view
create or replace view CHALLENGE_OUTPUT
as
select
    relative_path
  , size
  , file_url
  , build_scoped_file_url(@external_stage, relative_path) as scoped_file_url
  , build_stage_file_url(@external_stage, relative_path) as stage_file_url
  , get_presigned_url(@external_stage, relative_path) as presigned_url
from directory(@external_stage)
;

-- View challenge output
select * from CHALLENGE_OUTPUT;
