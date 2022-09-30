
-- Frosty Friday Challenge
-- Week 4 - Hard - JSON Parsing
-- https://frostyfriday.org/2022/09/30/week-16-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_16;

use schema WEEK_16;

-------------------------------
-- Challenge Setup Code

create or replace file format json_ff
  type = json
  strip_outer_array = TRUE
;
    
create or replace stage week_16_frosty_stage
  url = 's3://frostyfridaychallenges/challenge_16/'
  file_format = json_ff
;

create or replace table challenge_data 
as
select 
  t.$1:word::text WORD
  , t.$1:url::text URL
  , t.$1:definition::variant DEFINITION
from @week_16_frosty_stage (
    file_format => 'json_ff'
  , pattern=>'.*week16.*'
  ) t
;

-------------------------------
-- Investigate Challenge Data

select * from challenge_data
where word in ('label', 'Christmas')
;

-------------------------------
-- View of Parsed Data

create or replace view PARSED_DATA
as
select
    WORD
  , URL
  , meanings.value:"partOfSpeech"::string as PART_OF_SPEECH
  , meanings.value:"synonyms"::string as GENERAL_SYNONYMS
  , meanings.value:"antonyms"::string as GENERAL_ANTONYMS
  , definitions.value:"definition"::string AS DEFINITION
  , definitions.value:"example"::string AS EXAMPLE_IF_APPLICABLE
  , definitions.value:"synonyms"::string AS DEFINITIONAL_SYNONYMS
  , definitions.value:"antonyms"::string AS DEFINITIONAL_ANTONYMS
from challenge_data
  , LATERAL FLATTEN(DEFINITION, OUTER => TRUE, MODE => 'ARRAY') as list_member
  , LATERAL FLATTEN(list_member.value:"meanings", OUTER => TRUE, MODE => 'ARRAY') as meanings
  , LATERAL FLATTEN(meanings.value:"definitions", OUTER => TRUE, MODE => 'ARRAY') as definitions
;

-- Query the view
select * 
from PARSED_DATA
where WORD like 'l%'
;

-- Test counts
select
    count(word)
  , count(distinct word)
from PARSED_DATA
;
