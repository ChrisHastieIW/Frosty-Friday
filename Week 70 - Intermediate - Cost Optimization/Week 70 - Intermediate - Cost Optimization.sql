
-- Frosty Friday Challenge
-- Week 70 - Intermediate - Cost Optimization
-- https://frostyfriday.org/blog/2023/11/03/week-70/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_70;

use schema WEEK_70;

-------------------------------
-- Challenge Setup Script

-- Set session query tag
alter session set query_tag = 'CH_FROSTY_FRIDAY_CHALLENGE_70';

-- Random queries without common pattern
select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;
select COUNT(*) from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER where C_NATIONKEY = 15;
select C_NAME from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER where C_PHONE = '19-144-468-5416';

-- First set of queries following the same pattern.
-- Pattern = All columns from customers
-- with one WHERE-condition for C_MKTSEGMENT
select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER where C_MKTSEGMENT = 'BUILDING';
select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER where C_MKTSEGMENT = 'AUTOMOBILE';
select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER where C_MKTSEGMENT = 'MACHINERY';
select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER where C_MKTSEGMENT = 'HOUSEHOLD';
select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER where C_MKTSEGMENT = 'BUILDING';
select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER where C_MKTSEGMENT = 'BUILDING';


-- Second set of queries following the same pattern.
-- Pattern = C_NAME and C_NATIONKEY from customers
-- with two WHERE-conditions for C_MKTSEGMENT and C_NATIONKEY
select C_NAME, C_NATIONKEY from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER where C_MKTSEGMENT = 'BUILDING' and C_NATIONKEY = 21;
select C_NAME, C_NATIONKEY from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER where C_MKTSEGMENT = 'MACHINERY' and C_NATIONKEY = 9;

-- Unet session query tag
alter session unset query_tag;

-------------------------------
-- Challenge output view

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
with tagged_queries as (
  select
      QUERY_TEXT
    , TOTAL_ELAPSED_TIME
  from table(INFORMATION_SCHEMA.QUERY_HISTORY())
  where QUERY_TAG = 'CH_FROSTY_FRIDAY_CHALLENGE_70'
    and QUERY_TEXT not ilike '%alter session unset query_tag%'
)
, matched_queries as (
  select *
  from tagged_queries
  match_recognize(
    measures
        classifier() as CLASSIFIER
      , coalesce(first(QUERY_TEXT), QUERY_TEXT) as SAMPLE_QUERY
      -- Considered putting the count in here
      -- but wanted to avoid coalesce in the row count.
      -- Was easier to match all rows instead and aggregate
    all rows per match
    pattern (ALL_COLUMNS* SPECIFIC_COLUMNS*)
    define
        ALL_COLUMNS as
              QUERY_TEXT ilike 'select * from%'
          and QUERY_TEXT ilike '%where%C_MKTSEGMENT = %'
      , SPECIFIC_COLUMNS as
              QUERY_TEXT ilike 'select%C_NAME%from%'
          and QUERY_TEXT ilike 'select%C_NATIONKEY%from%'
          and QUERY_TEXT ilike '%where%C_MKTSEGMENT = %'
          and QUERY_TEXT ilike '%where%C_NATIONKEY = %'
  )
)
select
    SAMPLE_QUERY
  , COUNT(*) as QUERY_COUNT
  , SUM(TOTAL_ELAPSED_TIME) as SUM_ELAPSED_TIME
from matched_queries
group by all
order by
    QUERY_COUNT desc
  , SUM_ELAPSED_TIME desc
;

-- Query the view
select * from CHALLENGE_OUTPUT
;
