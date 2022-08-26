
-- Frosty Friday Challenge
-- Week 5 - Basic - UDFs
-- https://frostyfriday.org/2022/07/15/week-5-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_5;

use schema WEEK_5;

-------------------------------
-- Create the sample table

create or replace table SAMPLE_DATA
as
select
  uniform(1, 100, random())::int as START_INT
from (table(generator(rowcount => 100)))
;

-- Query the sample table
select * from SAMPLE_DATA;

-------------------------------
-- Define the Python UDF

create or replace function multiply_by_three(i int)
returns int
language python
runtime_version = '3.8'
handler = 'multiply_by_three_py'
as
$$
def multiply_by_three_py(i):
  return i*3
$$
;

-------------------------------
-- Test the Python UDF
select 
    START_INT
  , multiply_by_three(START_INT) as UDF_RESULT
  , START_INT*3 as VALIDATION_RESULT
  , UDF_RESULT = VALIDATION_RESULT as VALIDATION_FLAG
from SAMPLE_DATA
;
