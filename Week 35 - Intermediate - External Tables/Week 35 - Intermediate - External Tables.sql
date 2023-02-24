
-- Frosty Friday Challenge
-- Week 35 - Intermediate - External Tables
-- https://frostyfriday.org/2023/02/24/week-35-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_35;

use schema WEEK_35;

-------------------------------
-- Create challenge stage

create or replace stage external_table_stage
  url = 's3://frostyfridaychallenges/challenge_35/'
;

-------------------------------
-- Exploring

-- Create the single-field file format
create or replace file format FF_SINGLE_FIELD_INGESTION
  type = CSV
  field_delimiter = NONE
  record_delimiter = '\n'
  skip_header = 0
;

-- Query the data
select
    METADATA$FILENAME::STRING as FILE_NAME
  , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
  , $1::string as CONTENTS
from @external_table_stage
  (file_format => 'FF_SINGLE_FIELD_INGESTION')
;

-- Identified that files are standard CSVs with comma delimiters.
-- Also looks like the sale month is part of the file name

-- Create the appropriate file format
create or replace file format FF_CSV_INGESTION
    type = CSV
    field_delimiter = ','
    record_delimiter = '\n'
    field_optionally_enclosed_by = '"'
    skip_header = 1
;

-- Query the data
select
    TO_DATE(
      CONCAT(
          SPLIT_PART(METADATA$FILENAME::STRING, '/', 2) -- Extract year
        , '-'
        , SPLIT_PART(METADATA$FILENAME::STRING, '/', 3) -- Extract month
      )
      , 'YYYY-MM'
    ) as SALE_MONTH
  , $1::int as ID
  , $2::string as DRUG_NAME
  , $3::int as AMOUNT_SOLD
from @external_table_stage
  (file_format => 'FF_CSV_INGESTION')
;

-------------------------------
-- Create external table

create or replace external table CHALLENGE_OUTPUT(
      SALE_MONTH date AS TO_DATE(
          CONCAT(
              SPLIT_PART(METADATA$FILENAME::STRING, '/', 2) -- Extract year
            , '-'
            , SPLIT_PART(METADATA$FILENAME::STRING, '/', 3) -- Extract month
          )
          , 'YYYY-MM'
        )
    , ID INT as (value:c1::int)
    , DRUG_NAME VARCHAR as (value:c2::string)
    , AMOUNT_SOLD INT as (value:c3::int)
  )
  partition by (SALE_MONTH)
  auto_refresh = false -- No need as this is a one-off challenge
  location = @external_table_stage
  file_format = FF_CSV_INGESTION
;

-- View challenge output
select * from CHALLENGE_OUTPUT;

select 
    SALE_MONTH
  , ID
  , DRUG_NAME
  , AMOUNT_SOLD
from CHALLENGE_OUTPUT
order by AMOUNT_SOLD
;
