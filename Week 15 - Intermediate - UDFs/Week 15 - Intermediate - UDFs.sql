
-- Frosty Friday Challenge
-- Week 15 - Intermediate - UDFs
-- https://frostyfriday.org/2022/09/23/week-15-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_15;

use schema WEEK_15;

-------------------------------
-- Create the sample table

create or replace table HOME_SALES (
    SALE_DATE date
  , PRICE number(11, 2)
)
;

insert into HOME_SALES (SALE_DATE, PRICE) 
values
    ('2013-08-01'::date, 290000.00)
  , ('2014-02-01'::date, 320000.00)
  , ('2015-04-01'::date, 399999.99)
  , ('2016-04-01'::date, 400000.00)
  , ('2017-04-01'::date, 470000.00)
  , ('2018-04-01'::date, 510000.00)
;

-- Query the sample table
select * from HOME_SALES;

-------------------------------
-- Define the Python UDF

create or replace function split_to_bins(
    VALUE_TO_BIN NUMBER(11, 2)
  , BIN_THRESHOLDS_LIST ARRAY
)
returns int
language python
runtime_version = '3.8'
handler = 'split_to_bins_py'
as
$$
def split_to_bins_py(
    value_to_bin_py: float
  , bin_thresholds_list_py: list
):
  matching_indexes = [index for index, bin_threshold in enumerate(bin_thresholds_list_py) if value_to_bin_py >= bin_threshold]
  if len(matching_indexes) == 0 :
    return 0 # Return 0 if no match
  else :
    return matching_indexes[-1] + 1 # Add one since buckets should start at 1, not 0
$$
;

-------------------------------
-- Test the Python UDF
select 
    SALE_DATE
  , PRICE
  , split_to_bins(PRICE, ARRAY_CONSTRUCT(1, 310000, 400000, 500000)) as BUCKET_SET_1
  , split_to_bins(PRICE, ARRAY_CONSTRUCT(210000, 350000)) as BUCKET_SET_2
  , split_to_bins(PRICE, ARRAY_CONSTRUCT(250000, 290001, 320000, 360000, 410000, 470001)) as BUCKET_SET_3
from HOME_SALES
;
