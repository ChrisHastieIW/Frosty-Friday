
-- Frosty Friday Challenge
-- Week 1 - Basic - External Stages
-- https://frostyfriday.org/2022/07/14/week-1/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_1;

use schema WEEK_1;

-------------------------------
-- Create stage

create or replace stage STG_WEEK_1
  URL = 's3://frostyfridaychallenges/challenge_1/'
;

-- View files in stage
list @STG_WEEK_1;

-------------------------------
-- Investigate files in stage

-- Create a simple file format that will 
-- ingest the full data into a single 
-- field for simple understanding
create or replace file format FF_SINGLE_FIELD
    type = CSV
    field_delimiter = NONE
    record_delimiter = NONE
    skip_header = 0 
;

-- Query the data using the single field
-- file format to understand the contents
select 
    METADATA$FILENAME::STRING as FILE_NAME
  , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
  , $1::VARIANT as CONTENTS
from @STG_WEEK_1
  (file_format => 'FF_SINGLE_FIELD')
order by 
    FILE_NAME
  , ROW_NUMBER
;

-- Files seems to contain a single field
-- across multiple records without any
-- text qualifiers or similar complications.

-- It looks like the field has a column header
-- called result

-------------------------------
-- Ingest the files into a table

-- Create the appropriate file format
create or replace file format FF_SINGLE_FIELD_INGESTION
    type = CSV
    field_delimiter = NONE
    record_delimiter = '\n'
    skip_header = 1
;

-- Create a table in which to land the data
create or replace table RAW_DATA (
    FILE_NAME STRING
  , ROW_NUMBER INT
  , RESULT STRING
)
;

-- Ingest the data
COPY INTO RAW_DATA
FROM (
  select 
      METADATA$FILENAME::STRING as FILE_NAME
    , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
    , $1::string as CONTENTS
  from @STG_WEEK_1
    (file_format => 'FF_SINGLE_FIELD_INGESTION')
)
;

-- Query the results
SELECT "RESULT" 
FROM RAW_DATA
ORDER BY 
    FILE_NAME
  , ROW_NUMBER
;