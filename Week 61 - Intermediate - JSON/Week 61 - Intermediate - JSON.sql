
-- Frosty Friday Challenge
-- Week 61 - Intermediate - JSON
-- https://frostyfriday.org/blog/2023/09/01/week-61-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_61;

use schema WEEK_61;

-------------------------------
-- Create stage

create or replace stage STG_WEEK_61
  URL = 's3://frostyfridaychallenges/challenge_61/'
;

-- View files in stage
list @STG_WEEK_61;

-------------------------------
-- Investigate files in stage

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
from @STG_WEEK_61
  (file_format => 'FF_SINGLE_FIELD')
order by 
    FILE_NAME
  , ROW_NUMBER
;

-- Files seems to contain the following fields 
-- without any text qualifiers or similar complications.
-- Brand
-- URL
-- Product name
-- Category
-- Friendly URL

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
  , BRAND string
  , URL string
  , PRODUCT_NAME string
  , CATEGORY string
  , FRIENDLY_URL string
)
;

-- Ingest the data
COPY INTO RAW_DATA
FROM (
  select 
      metadata$filename::string as FILE_NAME
    , metadata$file_row_number as ROW_NUMBER
    , $1::string as BRAND
    , $2::string as URL
    , $3::string as PRODUCT_NAME
    , $4::string as CATEGORY
    , $5::string as FRIENDLY_URL
  from @STG_WEEK_61
    (file_format => 'FF_CSV_INGESTION')
)
;

-- Query the results
select *
from RAW_DATA
;

-------------------------------
-- Cleanup the data

-- We forward fill BRAND using LAG,
-- as in Frosty Friday Challenge 13.
-- Simple coalesce() function can be
-- used to populate the URLs.
-- Combination of functions paired with
-- a CTE for ease of reading is used to
-- convert CATEGORY values to camelCase.
-- Simple filter to remove records
-- where CATEGORY is NULL.
-- Apply filtering last to avoid losing
-- any potential inputs for the forward fill.
-- We could do all of this in a single CTE
-- but this method makes it easier to
-- demonstrate what we are doing.

-- Create the view
create or replace view CLEAN_DATA
as
with forward_filled as (
  select
      coalesce(
          BRAND
        , lag(
              BRAND
            , 1
          ) ignore nulls over (
              order by
                  ROW_NUMBER asc
          )
      ) as BRAND
    , PRODUCT_NAME
    , CATEGORY
    , URL
    , FRIENDLY_URL
  from RAW_DATA
)
, friendly_url_populated as (
  select
      BRAND
    , PRODUCT_NAME
    , CATEGORY
    , coalesce(FRIENDLY_URL, URL) as FRIENDLY_URL
  from forward_filled
)
, category_camelcase_logic as (
  select
      BRAND
    , PRODUCT_NAME
    , FRIENDLY_URL
    , CATEGORY as CATEGORY_ORIGINAL
    , initcap(CATEGORY_ORIGINAL) as CATEGORY_INITCAP
    , split(CATEGORY_INITCAP, ' ') as CATEGORY_SPLIT_TO_ARRAY
    , concat(
          lower(CATEGORY_SPLIT_TO_ARRAY[0])
        , array_to_string(array_remove_at(CATEGORY_SPLIT_TO_ARRAY, 0), '')
      )
      as CATEGORY
  from friendly_url_populated
)
select
      BRAND
    , PRODUCT_NAME
    , CATEGORY
    , FRIENDLY_URL
from category_camelcase_logic
where CATEGORY is not null
;

-- Query the view
select * from CLEAN_DATA;

-------------------------------
-- Nested JSON output

-- Must leverage CTEs here as we cannot
-- nest aggregates in a single query.
-- Could do this in one less CTE but
-- opted for clarity over brevity.

-- Create the view
create or replace view NESTED_JSON_OUTPUT
as
with products_per_brand as (
  select
      CATEGORY
    , BRAND
    , array_unique_agg(
        object_construct(
            PRODUCT_NAME
          , FRIENDLY_URL
        )
    ) as PRODUCTS_ARRAY
  from CLEAN_DATA
  group by
      CATEGORY
    , BRAND
)
, brands_per_category as (
  select
      CATEGORY
    , object_agg(
          BRAND
        , PRODUCTS_ARRAY
      ) as BRANDS_OBJECT
  from products_per_brand
  group by
      CATEGORY
)
select
  object_agg(
      CATEGORY
    , BRANDS_OBJECT
  ) as JSON_EXPORT
from brands_per_category
;

-- Query the view
select * from NESTED_JSON_OUTPUT;

-------------------------------
-- Output

-- Create the output stage
create or replace stage STG_WEEK_61_OUTPUT
  encryption = (type = 'SNOWFLAKE_SSE')
  directory = (enable = TRUE)
;

-- Create file format for staging
-- the data as JSON
create or replace file format FF_JSON
  type = JSON
;

-- Stage the output file
copy into @STG_WEEK_61_OUTPUT
from NESTED_JSON_OUTPUT
file_format = (format_name = 'FF_JSON')
;

-- Quickly confirm the contents of the output
select *
from @STG_WEEK_61_OUTPUT
(file_format => 'FF_JSON')
;

-- Refresh the directory table
alter stage STG_WEEK_61_OUTPUT refresh;

-- Retrieve pre-signed URL to the file
select
  get_presigned_url(@STG_WEEK_61_OUTPUT, RELATIVE_PATH)
from directory(@STG_WEEK_61_OUTPUT)
;

