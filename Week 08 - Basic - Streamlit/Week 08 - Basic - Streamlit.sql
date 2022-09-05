
-- Frosty Friday Challenge
-- Week 8 - Basic - Streamlit
-- https://frostyfriday.org/2022/08/05/week-8-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_8;

use schema WEEK_8;

-------------------------------
-- Create internal stage

create or replace stage STG_WEEK_8
;

-- View files in stage
list @STG_WEEK_8;

-- This is empty to start, so we
-- need to upload our input
-- file into this stage. This is achieved
-- with the following commands in a local
-- SnowSQL console:
/* --snowsql
snowsql -a my.account -u my_user -r my_role --private-key-path "path\to\my\ssh\key.p8"
PUT 'FILE://C:/My/Path/To/payments.csv' @CH_FROSTY_FRIDAY.WEEK_8.STG_WEEK_8;
*/

-- View files in stage
list @STG_WEEK_8;

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
from @STG_WEEK_8
  (file_format => 'FF_SINGLE_FIELD')
order by 
    FILE_NAME
  , ROW_NUMBER
;

-- We can ingest the file with the standard
-- csv file format


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
create or replace table PAYMENTS (
    FILE_NAME STRING
  , ROW_NUMBER INT
  , FILE_ROW_NUMBER INT
  , PAYMENT_DATE TIMESTAMP
  , CARD_TYPE STRING
  , AMOUNT_SPENT FLOAT
)
;

-- Ingest the data
COPY INTO PAYMENTS
FROM (
  select 
      METADATA$FILENAME::STRING as FILE_NAME
    , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
    , $1::int as FILE_ROW_NUMBER
    , $2::timestamp as PAYMENT_DATE
    , $3::string as CARD_TYPE
    , $4::float as AMOUNT_SPENT
  from @STG_WEEK_8/payments
    (file_format => 'FF_CSV_INGESTION')
)
;

-- Query the results
SELECT 
    PAYMENT_DATE
  , CARD_TYPE
  , AMOUNT_SPENT
FROM PAYMENTS
ORDER BY 
    FILE_ROW_NUMBER
;

