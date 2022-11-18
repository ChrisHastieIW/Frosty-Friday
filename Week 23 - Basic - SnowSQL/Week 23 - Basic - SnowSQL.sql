
-- Frosty Friday Challenge
-- Week 23 - Basic - SnowSQL
-- https://frostyfriday.org/2022/11/18/week-23-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_23;

use schema WEEK_23;

-------------------------------
-- Create internal stage

create or replace stage STG_WEEK_23
;

-- View files in stage
list @STG_WEEK_23;

-- This is empty to start, so we
-- need to upload our set of files
-- into this stage. We only wish
-- to ingest files which end in
-- "1.csv", which we can achieve
-- leveraging wildcards.

-- This is achieved with the
-- following commands in a local
-- SnowSQL console:
/* --snowsql
snowsql -a my.account -u my_user -r my_role --private-key-path "path\to\my\ssh\key.p8"
PUT 'FILE://C:/My/Path/To/Files to ingest/data_batch_*1.csv' @CH_FROSTY_FRIDAY.WEEK_23.STG_WEEK_23;
*/

-- View files in stage
list @STG_WEEK_23;

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
  , $1::STRING as CONTENTS
from @STG_WEEK_23
  (file_format => 'FF_SINGLE_FIELD')
order by 
    FILE_NAME
  , ROW_NUMBER
;

-- Files are structured with optional quote mark
-- text qualifiers and commas for delimiters.

-- Columns appear to be:
-- - id
-- - first_name
-- - last_name
-- - email
-- - gender
-- - ip_address

-------------------------------
-- Ingest the files into a table

-- Create the appropriate file format
create or replace file format FF_CSV_INGESTION
    type = CSV
    field_delimiter = ','
    record_delimiter = '\n'
    field_optionally_enclosed_by = '"'
    escape = '\\'
    skip_header = 1
;

-- Create a table in which to land the data
create or replace table RAW_DATA (
    id STRING
  , first_name STRING
  , last_name STRING
  , email STRING
  , gender STRING
  , ip_address STRING
)
;

-- Ingest the data
COPY INTO RAW_DATA
FROM @STG_WEEK_23
FILE_FORMAT = (format_name = 'FF_CSV_INGESTION')
ON_ERROR = SKIP_FILE
;

-- Query the results
SELECT *
FROM RAW_DATA
ORDER BY ID::INT
;