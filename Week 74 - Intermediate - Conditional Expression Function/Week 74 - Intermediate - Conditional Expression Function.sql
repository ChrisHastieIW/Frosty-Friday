
-- Frosty Friday Challenge
-- Week 74 - Intermediate - Conditional Expression Function
-- https://frostyfriday.org/blog/2023/12/01/week-74-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_74;

use schema WEEK_74;

-------------------------------
-- Challenge Setup Script

-- None provided.

-- Challenge states that dates can be in any of the following formats:
-- - YYYY-MM-DD
-- - DD/MM/YYYY
-- - Incorrect information such as 453921,
--   which I think can be ignored as I cannot
--   think of a relevant mapping. If it's an
--   Excel-style date then that would be
--   3142-10-16, which seems incorrect

-- Create table based on image in the challenge
create or replace table INPUTS (
    BIRTHDATE varchar
)
as
select * from values
    ('22/09/1968')
  , ('1968-09-22')
  , ('1968-09-22')
  , ('1968-09-22')
  , ('1968-09-22')
  , ('1968-09-22')
  , ('1968-09-22')
  , ('1968-09-22')
  , ('22/09/1968')
  , ('27/08/1985')
  , ('30/07/1967')
  , ('1985-08-27')
;

-- Query the table
select * from INPUTS;

-------------------------------
-- Challenge Solution

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
select
    COALESCE(
        TRY_TO_DATE(BIRTHDATE, 'YYYY-MM-DD')
      , TRY_TO_DATE(BIRTHDATE, 'DD/MM/YYYY')
    ) as BIRTHDATE
from INPUTS
;

-- Query the view
select * from CHALLENGE_OUTPUT
;
