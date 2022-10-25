
-- Frosty Friday Challenge
-- Week 19 - Basic - Dates - SQL
-- https://frostyfriday.org/2022/10/21/week-19-basic/

-- This version of the solution leverages a SQL UDF

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_19;

use schema WEEK_19;

-------------------------------
-- Construct Date Dimension Table

-- Copied and modified from my recent blog post:
-- https://interworks.com/blog/2022/08/02/using-snowflakes-generator-function-to-create-date-and-time-scaffold-tables/

CREATE OR REPLACE TABLE "DIM_DATE"
AS
-- Leverage ROW_NUMBER to ensure a gap-free sequence.
-- This is a CTE to allow "ROW_NUMBER" to be leveraged in window functions.
WITH "GAPLESS_ROW_NUMBERS" AS (
  SELECT
    ROW_NUMBER() OVER (ORDER BY seq4()) - 1 as "ROW_NUMBER" 
  FROM TABLE(GENERATOR(rowcount => 366 * (2100 - 2000)) ) -- rowcount is 366 days x (2100 - 2000) years to cover leap years. A later filter can remove the spillover days
)
SELECT
    DATEADD('day', "ROW_NUMBER", '2000-01-01'::date) as "DATE" -- Dimension starts on 2000-01-01 but a different value can be entered if desired
  , EXTRACT(year FROM "DATE") as "YEAR"
  , EXTRACT(month FROM "DATE") as "MONTH"
  , EXTRACT(day FROM "DATE") as "DAY"
  , EXTRACT(dayofweek FROM "DATE") as "DAY_OF_WEEK"
  , EXTRACT(dayofyear FROM "DATE") as "DAY_OF_YEAR"
  , EXTRACT(quarter FROM "DATE") as "QUARTER"
  , MIN("DAY_OF_YEAR") OVER (PARTITION BY "YEAR", "QUARTER") as "QUARTER_START_DAY_OF_YEAR"
  , "DAY_OF_YEAR" - "QUARTER_START_DAY_OF_YEAR" + 1 as "DAY_OF_QUARTER"
  , TO_VARCHAR("DATE", 'MMMM') as "MONTH_NAME"
  , TO_VARCHAR("DATE", 'MON') as "MONTH_NAME_SHORT"
  , CASE "DAY_OF_WEEK"
     WHEN 0 THEN 'Sunday'
     WHEN 1 THEN 'Monday'
     WHEN 2 THEN 'Tuesday'
     WHEN 3 THEN 'Wednesday'
     WHEN 4 THEN 'Thursday'
     WHEN 5 THEN 'Friday'
     WHEN 6 THEN 'Saturday'
    END as "DAY_NAME"
  , TO_VARCHAR("DATE", 'DY') as "DAY_NAME_SHORT"
  , "DAY_OF_WEEK" BETWEEN 1 and 5 AS "WORKING_DAY_FLAG"
FROM "GAPLESS_ROW_NUMBERS"
WHERE "YEAR" < 2100 -- WHERE clause then restricts back to desired timeframe since 366 days per year when generating row numbers is too many
;

-- View scaffold table
SELECT * FROM "DIM_DATE";

-------------------------------
-- Investigate Challenge Data

-- Create the data
create or replace table TESTING_DATA (
    id INT
  , start_date DATE
  , end_date DATE
)
as 
select * 
from values
    (1, '11/11/2020', '9/3/2022')
  , (2, '12/8/2020', '1/19/2022')
  , (3, '12/24/2020', '1/15/2022')
  , (4, '12/5/2020', '3/3/2022')
  , (5, '12/24/2020', '6/20/2022')
  , (6, '12/24/2020', '5/19/2022')
  , (7, '12/31/2020', '5/6/2022')
  , (8, '12/4/2020', '9/16/2022')
  , (9, '11/27/2020', '4/14/2022')
  , (10, '11/20/2020', '1/18/2022')
  , (11, '12/1/2020', '3/31/2022')
  , (12, '11/30/2020', '7/5/2022')
  , (13, '11/28/2020', '6/19/2022')
  , (14, '12/21/2020', '9/7/2022')
  , (15, '12/13/2020', '8/15/2022')
  , (16, '11/4/2020', '3/22/2022')
  , (17, '12/24/2020', '8/29/2022')
  , (18, '11/29/2020', '10/13/2022')
  , (19, '12/10/2020', '7/31/2022')
  , (20, '11/1/2020', '10/23/2021')
;

-- View challenge data
SELECT * FROM TESTING_DATA;

------------------------------------------------------------------
-- Create the UDF

CREATE OR REPLACE FUNCTION CALCULATE_BUSINESS_DAYS_SQL (
      INPUT_START_DATE DATE
    , INPUT_END_DATE DATE
    , INPUT_INCLUDE_END_DATE BOOLEAN
  )
  returns INT NOT NULL
as
$$
  SELECT COUNT(*)
  FROM "DIM_DATE"
  WHERE "WORKING_DAY_FLAG"
    AND "DATE" BETWEEN INPUT_START_DATE AND (INPUT_END_DATE - (1 - INPUT_INCLUDE_END_DATE::INT))
$$
;

------------------------------------------------------------------
-- Testing

select
    CALCULATE_BUSINESS_DAYS_SQL('2020-11-2', '2020-11-6', true)
  , CALCULATE_BUSINESS_DAYS_SQL('2020-11-2', '2020-11-6', false)
;

select
    *
  , CALCULATE_BUSINESS_DAYS_SQL(START_DATE, END_DATE, true)
  , CALCULATE_BUSINESS_DAYS_SQL(START_DATE, END_DATE, false)
FROM TESTING_DATA
;
