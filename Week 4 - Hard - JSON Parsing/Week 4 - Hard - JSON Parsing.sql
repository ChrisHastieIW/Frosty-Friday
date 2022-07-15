
-- Frosty Friday Challenge
-- Week 4 - Hard - JSON Parsing
-- https://frostyfriday.org/2022/07/15/week-4-hard/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_4;

use schema WEEK_4;

-------------------------------
-- Create internal stage

create or replace stage STG_WEEK_4
;

-- View files in stage
list @STG_WEEK_4;

-- This is empty to start, so we
-- need to upload our Spanish_Monarchs.json
-- file into this stage. This is achieved
-- with the following commands in a local
-- SnowSQL console:
/* --snowsql
snowsql -a my.account -u my_user -r my_role --private-key-path "path\to\my\ssh\key.p8"
PUT 'FILE://C:/My/Path/To/Spanish_Monarchs.json' @CH_FROSTY_FRIDAY.WEEK_4.STG_WEEK_4;
*/

-- View files in stage
list @STG_WEEK_4;

-------------------------------
-- Investigate files in stage

-- Create a simple file format that will 
-- ingest the full data into a single 
-- field for simple understanding
create or replace file format FF_JSON
    type = JSON
    strip_outer_array = TRUE
;

-- Query the data to understand the contents
select 
    METADATA$FILENAME::STRING as FILE_NAME
  , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
  , $1::VARIANT as CONTENTS
from @STG_WEEK_4
  (file_format => 'FF_JSON')
order by 
    FILE_NAME
  , ROW_NUMBER
;

-------------------------------
-- Ingest the files into a table

-- Create a table in which to land the data
create or replace table RAW_DATA (
    FILE_NAME STRING
  , ROW_NUMBER INT
  , RAW_JSON VARIANT
)
;

-- Ingest the data
COPY INTO RAW_DATA
FROM (
  select 
      METADATA$FILENAME::STRING as FILE_NAME
    , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
    , $1::variant as RAW_JSON
  from @STG_WEEK_4
    (file_format => 'FF_JSON')
)
;

-- Query the results
SELECT *
FROM RAW_DATA
ORDER BY 
    FILE_NAME
  , ROW_NUMBER
;

-------------------------------
-- View of Parsed Data

create or replace view PARSED_DATA
as
select 
    ROW_NUMBER() OVER (ORDER BY m.value:"Birth"::date) as ID
  , m.INDEX + 1 AS INTER_HOUSE_ID
  , RAW_JSON:"Era"::string as ERA
  , h.value:"House"::string as HOUSE
  , m.value:"Name"::string as NAME
  , m.value:"Nickname"[0]::string as NICKNAME_1
  , m.value:"Nickname"[1]::string as NICKNAME_2
  , m.value:"Nickname"[2]::string as NICKNAME_3
  , m.value:"Birth"::date as BIRTH
  , m.value:"Place of Birth"::string as PLACE_OF_BIRTH
  , m.value:"Start of Reign"::date as START_OF_REIGN
  , m.value:"Consort\/Queen Consort"[0]::string as CONSORT_OR_QUEEN_CONSORT_1
  , m.value:"Consort\/Queen Consort"[1]::string as CONSORT_OR_QUEEN_CONSORT_2
  , m.value:"Consort\/Queen Consort"[2]::string as CONSORT_OR_QUEEN_CONSORT_3
  , m.value:"End of Reign"::date as END_OF_REIGN
  , m.value:"Duration"::string as DURATION
  , m.value:"Death"::date as DEATH
  , split(m.value:"Age at Time of Death"::string, ' ')[0]::int as AGE_AT_TIME_OF_DEATH_YEARS
  , m.value:"Place of Death"::string as PLACE_OF_DEATH
  , m.value:"Burial Place"::string as BURIAL_PLACE
from RAW_DATA
  , LATERAL FLATTEN(RAW_JSON:"Houses") as h
  , LATERAL FLATTEN(h.value:"Monarchs") as m
order by ID ASC
;

-- Query the view
select * from PARSED_DATA
;
  
