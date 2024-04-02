
-- Frosty Friday Challenge
-- Week 87 - Basic - Cortex
-- https://frostyfriday.org/blog/2024/03/29/week-87-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_87;

use schema WEEK_87;

-------------------------------
-- Challenge Setup Script

create or replace table "WEEK_87"
as
select
    'Happy Easter' as "GREETING"
  , array_construct('DE', 'FR', 'IT', 'ES', 'PL', 'RO', 'JA', 'KO', 'PT') as "LANGUAGE_CODES"
;

-------------------------------
-- Challenge Solution

select
    "GREETING"
  , "SNOWFLAKE"."CORTEX"."TRANSLATE"(
        "GREETING"
      , 'en'
      , codes.value::string
    ) as "TRANSLATED_GREETING"
from "WEEK_87"
  , lateral flatten ("LANGUAGE_CODES") as codes
;
