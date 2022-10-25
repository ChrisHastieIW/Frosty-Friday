
-- Frosty Friday Challenge
-- Week 19 - Basic - Dates - Python
-- https://frostyfriday.org/2022/10/21/week-19-basic/

-- This version of the solution uses a Python UDF
-- and has no requirement for a date scaffold table

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_19;

use schema WEEK_19;

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

CREATE OR REPLACE FUNCTION CALCULATE_BUSINESS_DAYS_PYTHON (
      INPUT_START_DATE DATE
    , INPUT_END_DATE DATE
    , INPUT_INCLUDE_END_DATE BOOLEAN
  )
  returns INT NOT NULL
  language python
  runtime_version = '3.8'
  packages = ('numpy')
  handler = 'calculate_business_days'
as
$$

# Import modules
import numpy
from datetime import date
from datetime import timedelta

# Define handler function
def calculate_business_days(
      input_start_date: date
    , input_end_date: date
    , input_include_end_date: bool
  ) :

  ## Determine calculation's end date
  calc_end_date = input_end_date
  if input_include_end_date :
    calc_end_date = input_end_date + timedelta(days=1)
    
  ## Return number of business days
  return numpy.busday_count(input_start_date, calc_end_date)
$$
;

------------------------------------------------------------------
-- Testing

select
    CALCULATE_BUSINESS_DAYS_PYTHON('2020-11-2', '2020-11-6', true)
  , CALCULATE_BUSINESS_DAYS_PYTHON('2020-11-2', '2020-11-6', false)
;

select
    *
  , CALCULATE_BUSINESS_DAYS_PYTHON(START_DATE, END_DATE, true)
  , CALCULATE_BUSINESS_DAYS_PYTHON(START_DATE, END_DATE, false)
FROM TESTING_DATA
;
