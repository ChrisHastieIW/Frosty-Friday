
-- Frosty Friday Challenge
-- Week 3 - Intermediate - Metadata Queries
-- https://frostyfriday.org/2022/07/15/week-3-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_3;

use schema WEEK_3;

-------------------------------
-- Create stage

create or replace stage STG_WEEK_3
  URL = 's3://frostyfridaychallenges/challenge_3/'
;

-- View files in stage
list @STG_WEEK_3;


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
from @STG_WEEK_3
  (file_format => 'FF_SINGLE_FIELD')
order by 
    FILE_NAME
  , ROW_NUMBER
;

-- Other than the keywords file, each
-- file seems to match the same format.
-- We can ingest all files other than keywords
-- into a destination, and import keywords
-- into a separate table.

-- Also, the file format looks like standard csv


-------------------------------
-- Ingest the files into a table

-- Create the appropriate file format
create or replace file format FF_CSV_INGESTION
    type = CSV
    field_delimiter = ','
    record_delimiter = '\n'
    skip_header = 1
;

-- Create a table in which to land the data
create or replace table RAW_DATA (
    FILE_NAME STRING
  , ROW_NUMBER INT
  , ID STRING
  , FIRST_NAME STRING
  , LAST_NAME STRING
  , CATCH_PHRASE STRING
  , TIMESTAMP_RAW STRING
)
;

-- Ingest the data
COPY INTO RAW_DATA
FROM (
  select 
      METADATA$FILENAME::STRING as FILE_NAME
    , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
    , $1::string as ID
    , $2::string as FIRST_NAME
    , $3::string as LAST_NAME
    , $4::string as CATCH_PHRASE
    , $5::string as TIMESTAMP_RAW
  from @STG_WEEK_3/week3
    (file_format => 'FF_CSV_INGESTION')
)
;

-- Create a table in which to land the data
create or replace table KEYWORDS (
    FILE_NAME STRING
  , ROW_NUMBER INT
  , KEYWORD STRING
  , ADDED_BY STRING
  , NONSENSE STRING
)
;

-- Ingest the data
COPY INTO KEYWORDS
FROM (
  select 
      METADATA$FILENAME::STRING as FILE_NAME
    , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
    , $1::string as KEYWORD
    , $2::string as ADDED_BY
    , $3::string as NONSENSE
  from @STG_WEEK_3/keywords
    (file_format => 'FF_CSV_INGESTION')
)
;

-- Query the results
SELECT *
FROM RAW_DATA
ORDER BY 
    FILE_NAME
  , ROW_NUMBER
;

SELECT *
FROM KEYWORDS
ORDER BY 
    FILE_NAME
  , ROW_NUMBER
;

-------------------------------
-- View of ingested keyword files

create or replace view INGESTED_KEYWORD_FILES
as
select 
    FILE_NAME
  , count(*) as NUMBER_OF_ROWS
from RAW_DATA
where exists (
  SELECT 1 
  FROM KEYWORDS
  WHERE CONTAINS(RAW_DATA.FILE_NAME, KEYWORDS.KEYWORD)
)
group by
    FILE_NAME
;

-- Query the view
select * from INGESTED_KEYWORD_FILES
order by 1
;
  
