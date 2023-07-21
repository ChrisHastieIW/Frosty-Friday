
-- Frosty Friday Challenge
-- Week 55 - Basic - Group by all
-- https://frostyfriday.org/2023/07/21/week-55-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_55;

use schema WEEK_55;

-------------------------------
-- Startup code

-- Stage creation
create or replace stage STG_WEEK_55
  url='s3://frostyfridaychallenges/challenge_55/';
;

-------------------------------
-- Investigate files in stage

-- View files in stage
list @STG_WEEK_55;

-- Create a simple file format that will 
-- ingest the full data into a single 
-- field for simple understanding
create or replace file format FF_SINGLE_FIELD
    type = CSV
    field_delimiter = NONE
    record_delimiter = '\n'
    skip_header = 0 
;

-- Query the data using the single field
-- file format to understand the contents
select
    metadata$filename::string as FILE_NAME
  , metadata$file_row_number as ROW_NUMBER
  , $1::variant as CONTENTS
from @STG_WEEK_55
  (file_format => 'FF_SINGLE_FIELD')
order by 
    FILE_NAME
  , ROW_NUMBER
;

-- Files seems to contain the following fields 
-- without any text qualifiers or similar complications.
-- sale_id
-- product
-- quantity
-- sale_date
-- price
-- country
-- city

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
    FILE_NAME string
  , ROW_NUMBER int
  , SALE_ID int
  , PRODUCT string
  , QUANTITY int
  , SALE_DATE date
  , PRICE float
  , COUNTRY string
  , CITY string
)
;

-- Ingest the data
COPY INTO RAW_DATA
FROM (
  select 
      metadata$filename::string as FILE_NAME
    , metadata$file_row_number as ROW_NUMBER
    , $1::int as SALE_ID
    , $2::string as PRODUCT
    , $3::int as QUANTITY
    , $4::date as SALE_DATE
    , $5::float as PRICE
    , $6::string as COUNTRY
    , $7::string as CITY
  from @STG_WEEK_55
    (file_format => 'FF_CSV_INGESTION')
)
;

-- Query the results
select *
from RAW_DATA
;
-- The above tells us the table
-- has a total of 106 records

-------------------------------
-- Challenge code

-- Identify some dupes
select *
from RAW_DATA
qualify count(*) over (partition by SALE_ID) > 1
order by SALE_ID
;

-- The above gives us 6 duplicate pairs (12 records).
-- Interestingly, the duplicates appear to be
-- exact duplicates so we don't need to do anything
-- fancy here. We can use the new "group by all"
-- functionality in a simple select of all the columns
select * exclude (FILE_NAME, ROW_NUMBER)
from RAW_DATA
group by all
;

-- The above yields only 100 records
-- as the 6 duplicates are removed
