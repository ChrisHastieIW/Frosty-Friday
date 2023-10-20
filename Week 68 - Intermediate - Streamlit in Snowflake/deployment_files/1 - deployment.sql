
-- This is the main SQL script that is
-- used to deploy the native application package
-- and native application

-------------------------------
-- Environment

-- Use the application admin role
-- which was created at another time.
-- This role has the following grants:
-- - CREATE APPLICATION PACKAGE
-- - CREATE APPLICATION
use role APPLICATION_ADMIN;

-------------------------------
-- Application package creation

-- Create the application package
create application package if not exists "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_68"
  comment = 'Owned by Chris Hastie. Solution for Frosty Friday challenge 68.'
;

-- View the application package
show application packages like 'APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_68';

-- Set environemt to the application package
use application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_68";

-------------------------------
-- Application data

-- Create schema within the application package
create or replace schema shared_data;
use schema shared_data;

-- Create a stage
create or replace stage STG_FROSTY_FRIDAY_CHALLENGES_WEEK_68
  url = 's3://frostyfridaychallenges/challenge_68/'
;

-- Determine what data we are working with
list @STG_FROSTY_FRIDAY_CHALLENGES_WEEK_68;

-- Create file format
create or replace file format FF_JSON
    type = 'JSON'
  , strip_outer_array = TRUE
;

-- Ingest raw data
create or replace table CHALLENGE_DATA_RAW
as
select
  $1 as RAW_JSON
from @STG_FROSTY_FRIDAY_CHALLENGES_WEEK_68
  (file_format => FF_JSON)
;

-- View challenge data raw
select * from CHALLENGE_DATA_RAW;

-- Grant access to the application
grant usage on schema SHARED_DATA to share in application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_68";
grant select on table SHARED_DATA.CHALLENGE_DATA_RAW to share in application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_68";

-------------------------------
-- Application deployment

-- Add a version to the application package with the uploaded files
alter application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_68"
  add version V1_0 using '@"CH_FROSTY_FRIDAY"."WEEK_68"."STG_NATIVE_APP_CONTENT"'
;

-- View the application package version
show versions in application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_68";

-- Install the application using the version
drop application if exists "APP_CH_FROSTY_FRIDAY_WEEK_68";
create application "APP_CH_FROSTY_FRIDAY_WEEK_68"
  from application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_68"
  using version V1_0
  comment = 'Owned by Chris Hastie. Solution for Frosty Friday challenge 68.'
;
