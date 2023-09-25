
-- Frosty Friday Challenge
-- Week 64 - Hard - XML Parsing
-- https://frostyfriday.org/blog/2023/09/22/semaine-64-hard/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_64;

use schema WEEK_64;

-------------------------------
-- Create challenge data

create or replace file format FF_PARQUET
  type = 'parquet'
;

create or replace stage STG_FROSTY_FRIDAY_CHALLENGES
  url = 's3://frostyfridaychallenges'
;

create or replace table CHALLENGE_DATA
as
select
    parse_xml($1:"DATA") as RAW_XML
from @STG_FROSTY_FRIDAY_CHALLENGES/challenge_64/french_monarchs.parquet
  (file_format => FF_PARQUET)
;

-- View challenge data
select * from CHALLENGE_DATA;

-------------------------------
-- Parsed view

-- Important things to remember when parsing XML:
-- - "$" retrieves the value of the element
-- - "@" retrieves the name of the element
-- - XMLGET allows you to retrieve a child of an element

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
select
    dynasties.value:"@name"::string as DYNASTY
  , XMLGET(monarchs.value, 'Name'):"$"::string as NAME
  , XMLGET(monarchs.value, 'Reign'):"$"::string as REIGN
  , XMLGET(monarchs.value, 'Succession'):"$"::string as SUCCESSION
  , XMLGET(monarchs.value, 'LifeDetails'):"$"::string as LIFE_DETAILS
from CHALLENGE_DATA
  , lateral flatten ("RAW_XML":"$") as dynasties
  , lateral flatten (to_array(dynasties.value:"$"::variant)) as monarchs
;

-- Query the view
select * from CHALLENGE_OUTPUT;
