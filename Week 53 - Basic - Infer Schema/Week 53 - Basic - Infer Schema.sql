
-- Frosty Friday Challenge
-- Week 53 - Basic - Infer Schema
-- https://frostyfriday.org/2023/07/07/week-53-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_53;

use schema WEEK_53;

-------------------------------
-- Startup code

-- Create stage
create or replace stage STG_FROSTY;

-- This is empty to start, so we
-- need to upload our employees.csv
-- file into this stage. This is achieved
-- with the following commands in a local
-- SnowSQL console:
/* --snowsql
snowsql -a my.account -u my_user -r my_role --private-key-path "path\to\my\ssh\key.p8"
PUT 'FILE://C:/My/Path/To/employees.csv' @CH_FROSTY_FRIDAY.WEEK_53.STG_FROSTY;
*/

-- View files in stage
list @STG_FROSTY;

-- Create file format
create or replace file format FF_FROSTY_FRIDAY
  field_optionally_enclosed_by = '"'
  skip_header = 1
;

-------------------------------
-- Challenge code

-- First, ingest the inferred schema fully
create or replace table INFERRED_SCHEMA
as
select *
from table(
  infer_schema(
    LOCATION => '@STG_FROSTY',
    FILE_FORMAT => 'FF_FROSTY_FRIDAY'
  )
)
;

-- Query the inferred schema
select * from CHALLENGE_OUTPUT;

-- Challenge expects subset of columns with different names
-- so create a view to align
create or replace view CHALLENGE_OUTPUT
as
  select
      ORDER_ID as COLUMN_POSITION
    , TYPE as DATA_TYPE
  from INFERRED_SCHEMA
;

-- Query the final output
select * from CHALLENGE_OUTPUT;
