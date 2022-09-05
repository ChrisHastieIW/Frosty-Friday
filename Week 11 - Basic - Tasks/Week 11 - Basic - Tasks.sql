
-- Frosty Friday Challenge
-- Week 11 - Basic - Tasks
-- https://frostyfriday.org/2022/08/26/week-11-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_11;

use schema WEEK_11;

-------------------------------
-- Initial Ingestion

-- Create stage
create or replace stage STG_WEEK_11
  URL = 's3://frostyfridaychallenges/challenge_11/'
;

-- View files in stage
list @STG_WEEK_11; 

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
  , MILKING_DATETIME STRING
  , COW_NUMBER STRING
  , FAT_PERCENTAGE STRING
  , FARM_CODE STRING
  , CENTRIFUGE_START_TIME STRING
  , CENTRIFUGE_END_TIME STRING
  , CENTRIFUGE_KWPH STRING
  , CENTRIFUGE_ELECTRICITY_USED STRING
  , CENTRIFUGE_PROCESSING_TIME STRING
  , TASK_USED STRING
)
;

-- Ingest the data
COPY INTO RAW_DATA
FROM (
  select 
      METADATA$FILENAME::STRING as FILE_NAME
    , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
    , $1::string as MILKING_DATETIME
    , $2::string as COW_NUMBER
    , $3::string as FAT_PERCENTAGE
    , $4::string as FARM_CODE
    , $5::string as CENTRIFUGE_START_TIME
    , $6::string as CENTRIFUGE_END_TIME
    , $7::string as CENTRIFUGE_KWPH
    , $8::string as CENTRIFUGE_ELECTRICITY_USED
    , $9::string as CENTRIFUGE_PROCESSING_TIME
    , $10::string as TASK_USED
  from @STG_WEEK_11/milk_data
    (file_format => 'FF_CSV_INGESTION')
)
;

-- View raw data
select * from RAW_DATA;

-- Create clean table for tasks to act on
create or replace table CLEAN_DATA
as
select
    TRY_CAST(MILKING_DATETIME AS TIMESTAMP) AS MILKING_DATETIME
  , TRY_CAST(COW_NUMBER AS INT) AS COW_NUMBER
  , TRY_CAST(FAT_PERCENTAGE AS INT) AS FAT_PERCENTAGE
  , TRY_CAST(FARM_CODE AS INT) AS FARM_CODE
  , TRY_CAST(CENTRIFUGE_START_TIME AS TIMESTAMP) AS CENTRIFUGE_START_TIME
  , TRY_CAST(CENTRIFUGE_END_TIME AS TIMESTAMP) AS CENTRIFUGE_END_TIME
  , TRY_CAST(CENTRIFUGE_KWPH AS DECIMAL(5, 2)) AS CENTRIFUGE_KWPH
  , TRY_CAST(CENTRIFUGE_ELECTRICITY_USED AS DECIMAL(5, 2)) AS CENTRIFUGE_ELECTRICITY_USED
  , TRY_CAST(CENTRIFUGE_PROCESSING_TIME AS INT) AS CENTRIFUGE_PROCESSING_TIME
  , TRY_CAST(TASK_USED AS STRING) AS TASK_USED
from RAW_DATA
;

-- View clean data
select * from CLEAN_DATA;

-------------------------------
-- Task 1

-- Remove all the centrifuge dates
-- and centrifuge kwph and replace 
-- them with NULLs WHERE fat = 3.

create or replace task WHOLE_MILK_UPDATES
  warehouse = 'WH_CHASTIE'
  schedule = '1400 minutes'
as
  update CLEAN_DATA
  set 
      CENTRIFUGE_START_TIME = NULL
    , CENTRIFUGE_END_TIME = NULL
    , CENTRIFUGE_KWPH = NULL
    , TASK_USED = concat(
          SYSTEM$CURRENT_USER_TASK_NAME()
        , ' at '
        , CURRENT_TIMESTAMP()::STRING
      )
  where FAT_PERCENTAGE = 3
;

-------------------------------
-- Task 2

-- Calculate centrifuge processing time 
-- (difference between start and end time) 
-- WHERE fat != 3

create or replace task SKIM_MILK_UPDATES
  warehouse = 'WH_CHASTIE'
  after WHOLE_MILK_UPDATES
as
  update CLEAN_DATA
  set 
      CENTRIFUGE_PROCESSING_TIME = TIMESTAMPDIFF(
          minute
        , CENTRIFUGE_START_TIME
        , CENTRIFUGE_END_TIME
      )
    , CENTRIFUGE_ELECTRICITY_USED = 
        TIMESTAMPDIFF(
            minute
          , CENTRIFUGE_START_TIME
          , CENTRIFUGE_END_TIME
        ) * CENTRIFUGE_KWPH / 60
    , TASK_USED = concat(
          SYSTEM$CURRENT_USER_TASK_NAME()
        , ' at '
        , CURRENT_TIMESTAMP()::STRING
      )
  where FAT_PERCENTAGE != 3
;

-- Enable the task
alter task SKIM_MILK_UPDATES resume;

-------------------------------
-- View tasks

-- View the tasks
show tasks;

-- View task history
select *
from table(information_schema.task_history())
order by scheduled_time DESC
;

-------------------------------
-- Testing
    
-- Manually execute the task.
execute task WHOLE_MILK_UPDATES;

-- Check that the data looks as it should.
select * from CLEAN_DATA
order by FAT_PERCENTAGE ASC
;

-- Check that the numbers are correct.
select 
    task_used
  , count(*) as row_count 
from CLEAN_DATA
group by 
    task_used
;
