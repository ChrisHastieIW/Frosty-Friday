
-- Frosty Friday Challenge
-- Week 95 - Intermediate - Snowflake imports
-- https://frostyfriday.org/blog/2024/05/24/week-95-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema "WEEK_95";

use schema "WEEK_95";

-------------------------------
-- Challenge Setup Script

-- Create the stage
create or replace stage "MY_STAGE";

-------------------------------
-- Challenge Solution

-- Upload file to stage
-- Using the VSCode extension, we can run this directly
-- without needing to outsource to SnowSQL!
put 'FILE://Week 95 - Intermediate - Snowflake imports/imported_python.py' @"MY_STAGE" overwrite=true auto_compress=false;

-- View files in stage
list @"MY_STAGE";

-- Create stored procedure
create or replace procedure "FROSTY_CHALLENGE" ()
  returns string
  language python
  runtime_version = '3.10'
  packages = ('snowflake-snowpark-python')
  imports = ('@"MY_STAGE"/imported_python.py')
  handler = 'main'
as
$$

## Import module for inbound Snowflake session
from snowflake.snowpark import Session as snowparkSession

## Import the bespoke module
from imported_python import success

## Define the main handler
def main(snowpark_session: snowparkSession):

  r = success()

  return r
$$
;

-- Test stored procedure
call "FROSTY_CHALLENGE"();
