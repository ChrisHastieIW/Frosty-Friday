
-- Frosty Friday Challenge
-- Week 63 - Hard - Query Profiling
-- https://frostyfriday.org/blog/2023/09/15/week-63-hard/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_63;

use schema WEEK_63;

-------------------------------
-- Start-up Code

-- The below code has been modified from
-- the original start-up code to make it
-- a bit easier to read.

-- Base numbers view
create or replace view BASE_NUMBERS
as
select
  row_number() over (order by seq8()) as VALUE
from table(generator(rowcount => 40))
;

-- Create table T1
create or replace table T1 (
  VALUE char(1)
)
as
    select 'a'
    from BASE_NUMBERS where VALUE <= 10

  union all

    select 'b'
    from BASE_NUMBERS where VALUE <= 20

  union all

    select 'c'
    from BASE_NUMBERS where VALUE <= 30

  union all

    select 'd'
    from BASE_NUMBERS where VALUE <= 20
;

-- Create table t2 and insert one 'b' value
create or replace table T2 (
  VALUE char(1)
)
as
select $1
from values
    ('b')
;

-- Create table T3 and insert ten 'c' values
create or replace table T3 (
  VALUE char(1)
)
as
    select 'c'
    from BASE_NUMBERS where VALUE <= 10
;

-- Create table t4 and insert one 'd' value
create or replace table T4 (
  VALUE char(1)
)
as
select $1
from values
    ('d')
;

-------------------------------
-- Generate the Query to Check

-- Execute the query
select *
from T1
  left join T2 using (VALUE)
  left join T3 using (VALUE)
  left join T4 using (VALUE)
;

-- Store the last query ID:
set target_query_id = (select last_query_id());

-- Preview the variable to confirm
select $target_query_id;

-------------------------------
-- Challenge Code

-- Write a query that leverages the
-- get_query_operator_stats function
-- to identify explosive joins
with all_join_details as (
  select
      OPERATOR_ATTRIBUTES:"equality_join_condition" as EQUALITY_JOIN_CONDITION
    , OPERATOR_STATISTICS:"input_rows"::int as INPUT_ROW_COUNT
    , OPERATOR_STATISTICS:"output_rows"::int as OUTPUT_ROW_COUNT

    -- Calculate ROW_MULTIPLIER with a contingency
    -- to avoid dividing by zero
    , case when INPUT_ROW_COUNT = 0
        then 0
        else OUTPUT_ROW_COUNT / INPUT_ROW_COUNT
      end as ROW_MULTIPLIER
      
  from table(get_query_operator_stats($target_query_id))
  where OPERATOR_TYPE = 'Join'
)
select
    EQUALITY_JOIN_CONDITION as GUILTY_JOIN
  , ROW_MULTIPLIER
from all_join_details
where ROW_MULTIPLIER > 1
;

-- Put this query into a UDF
create or replace function IDENTIFY_EXPLOSIVE_JOINS(target_query_id string)
  returns table (
      GUILTY_JOIN variant
    , ROW_MULTIPLIER number(38,6)
  )
as
$$
with all_join_details as (
  select
      OPERATOR_ATTRIBUTES:"equality_join_condition" as EQUALITY_JOIN_CONDITION
    , OPERATOR_STATISTICS:"input_rows"::int as INPUT_ROW_COUNT
    , OPERATOR_STATISTICS:"output_rows"::int as OUTPUT_ROW_COUNT

    -- Calculate ROW_MULTIPLIER with a contingency
    -- to avoid dividing by zero
    , case when INPUT_ROW_COUNT = 0
        then 0
        else OUTPUT_ROW_COUNT / INPUT_ROW_COUNT
      end as ROW_MULTIPLIER
      
  from table(get_query_operator_stats(TARGET_QUERY_ID))
  where OPERATOR_TYPE = 'Join'
)
select
    EQUALITY_JOIN_CONDITION as GUILTY_JOIN
  , ROW_MULTIPLIER
from all_join_details
where ROW_MULTIPLIER > 1
$$
;

-- Test the UDF
select *
from table(IDENTIFY_EXPLOSIVE_JOINS($target_query_id))
;
