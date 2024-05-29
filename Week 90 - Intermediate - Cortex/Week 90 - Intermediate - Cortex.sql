
-- Frosty Friday Challenge
-- Week 90 - Intermediate - Cortex
-- https://frostyfriday.org/blog/2024/04/19/week-90-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema "WEEK_90";

use schema "WEEK_90";

-------------------------------
-- Challenge Setup Script

-- Create the stage
create or replace stage "FROSTY_AWS_STAGE"
  url = 's3://frostyfridaychallenges/'
;

-- Create the table
create or replace table "MAIN_DATA"
as
select 
    $1::timestamp_ntz as "SALE_DATE"
  , $2::int as "PRODUCT_ID"
  , $3::int as "QUANTITY_SOLD"
  , $4::int as "UNIT_PRICE"
  , $5/100::float as "TAX_PCT"
  , $6/100::float as "DCT_PCT"
from '@"FROSTY_AWS_STAGE"/challenge_90'
where $1 != 'Date'
;

-- Review the table
select * from "MAIN_DATA";

-- Create the forecasting targets table
create or replace table "FORECASTING_TARGETS" like "MAIN_DATA";
alter table "FORECASTING_TARGETS" drop column "QUANTITY_SOLD";

insert into "FORECASTING_TARGETS" values 
    (to_timestamp_ntz('2023-10-29'), 1000, 450, 0.1, 0.02)
  , (to_timestamp_ntz('2023-10-29'), 1001, 150, 0.15, 0.02)
  , (to_timestamp_ntz('2023-10-29'), 1002, 100, 0.13, 0.18)
  , (to_timestamp_ntz('2023-10-29'), 1003, 170, 0.11, 0.03)
  , (to_timestamp_ntz('2023-10-29'), 1004, 300, 0.04, 0.03)
;

-- Review the forecasting targets table
select * from "FORECASTING_TARGETS";

-------------------------------
-- Challenge Solution

-- Create the forecast model
create or replace SNOWFLAKE.ML.FORECAST "MY_FORECASTING_MODEL"(
    input_data => SYSTEM$REFERENCE('TABLE', 'MAIN_DATA')
  , series_colname => 'PRODUCT_ID' -- Model will forecast each value of this field independently, similar to a GROUP BY or a PARTITION
  , timestamp_colname => 'SALE_DATE' -- Forecasting using timestamp field to determine order of records and leverage potential seasonality
  , target_colname => 'QUANTITY_SOLD' -- Attempt to forecast the field that we are missing
)
;

-- Retrieve the forecasted values
call "MY_FORECASTING_MODEL"!forecast(
    input_data => SYSTEM$REFERENCE('TABLE', 'FORECASTING_TARGETS')
  , series_colname => 'PRODUCT_ID'
  , timestamp_colname => 'SALE_DATE'
)
;
