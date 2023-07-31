
-- Frosty Friday Challenge
-- Week 56 - Intermediate - UDF & Alerts
-- https://frostyfriday.org/2023/07/28/week-56-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_56;

use schema WEEK_56;

-------------------------------
-- Challenge code - Staging and prep

-- Stage creation
create or replace stage STG_WEEK_56
  url='s3://frostyfridaychallenges/challenge_56/';
;

-------------------------------
-- Investigate files in stage

-- View files in stage
list @STG_WEEK_56;

-- Create a simple file format that will 
-- ingest the full data into a single 
-- field for simple understanding
create or replace file format FF_SINGLE_FIELD
    type = CSV
    field_delimiter = NONE
    record_delimiter = '\n'
    skip_header = 0 
;

-- Query the data using the single field
-- file format to understand the contents
select
    metadata$filename::string as FILE_NAME
  , metadata$file_row_number as ROW_NUMBER
  , $1::variant as CONTENTS
from @STG_WEEK_56
  (file_format => 'FF_SINGLE_FIELD')
order by 
    FILE_NAME
  , ROW_NUMBER
;

-- Files seems to contain the following fields 
-- without any text qualifiers or similar complications.
-- id
-- reaction

-------------------------------
-- Ingest the files into a table

-- Create the appropriate file format
create or replace file format FF_CSV_INGESTION
    type = CSV
    field_delimiter = ','
    record_delimiter = '\n'
    skip_header = 1
;

-- Create a table in which to land the data
create or replace table RAW_DATA (
    FILE_NAME string
  , ROW_NUMBER int
  , ID int
  , REACTION string
)
;

-- Ingest the data
COPY INTO RAW_DATA
FROM (
  select 
      metadata$filename::string as FILE_NAME
    , metadata$file_row_number as ROW_NUMBER
    , $1::int as ID
    , $2::string as REACTION
  from @STG_WEEK_56
    (file_format => 'FF_CSV_INGESTION')
)
;

-- Query the results
select *
from RAW_DATA
;

-------------------------------
-- Challenge code - UDF

-- The first challenge is to
-- figure out the UDF that can
-- perform emoji translation.

-- A quick Google tells us that the "best"
-- packages for this are Emot and Emoji, neither
-- of which are supported by Snowflake at this time.
-- The full list of supported packages is here:
-- https://repo.anaconda.com/pkgs/snowflake/

-- We could manually define the emoji mapping,
-- but that won't prepare us for new emojis
-- unless we go through the whole set. We could
-- figure out how to manually ingest one of these
-- packages as imports for our UDF, but
-- the nice tool for this is in private preview
-- and I don't want to mess around too much with
-- embedded directories to import.
-- I thought I'd try this anyway, and began by 
-- downloading the full emoji package from
-- https://pypi.org/project/emoji/#files
-- and having a look inside. Fortunately, I found
-- a great emoji mapping inside a file called
-- data_dict.py and can use that in my own UDF.

-- Create the stage to hold the package
create or replace stage STG_WEEK_56_PYTHON_PACKAGES;

-- View files in stage
list @STG_WEEK_56_PYTHON_PACKAGES;

-- This is empty to start, so we
-- need to upload the data_dict.py
-- file into this stage. We avoid
-- any compression to make it easier
-- to read in the UDF. This is achieved
-- with the following commands in a local
-- SnowSQL console:
/* --snowsql
snowsql -a my.account -u my_user -r my_role --private-key-path "path\to\my\ssh\key.p8"
PUT
  'FILE://C:/My/Path/To/emoji_files/data_dict.py'
  @CH_FROSTY_FRIDAY.WEEK_56.STG_WEEK_56_PYTHON_PACKAGES/emoji_files
  AUTO_COMPRESS=FALSE
;
*/

-- View files in stage
list @STG_WEEK_56_PYTHON_PACKAGES;

-- Create the UDF
create or replace function TRANSLATE_EMOJI (input_emoji varchar)
  returns varchar
  language python
  runtime_version = '3.8'
  imports = ('@STG_WEEK_56_PYTHON_PACKAGES/emoji_files/data_dict.py')
  handler = 'translate_emoji'
as
$$
## Import the required modules 
import sys
import importlib.util
    
## Retrieve the Snowflake import directory
IMPORT_DIRECTORY_NAME = "snowflake_import_directory"
import_dir = sys._xoptions[IMPORT_DIRECTORY_NAME]

## Import the required external module using the importlib.util library
module_spec = importlib.util.spec_from_file_location('emoji', import_dir + 'data_dict.py')
emoji = importlib.util.module_from_spec(module_spec)
module_spec.loader.exec_module(emoji)
emoji_mapping_dict = emoji.__dict__["EMOJI_DATA"]

## Define the main function.
def translate_emoji(input_emoji: str):
  
  ### Apply a .strip() to the input as
  ### there was a record in the data with
  ### an erroneous space
  input_emoji = input_emoji.strip()

  ### Check if input is an emoji in our
  ### provided list of emojis, and retrieve
  ### the mapping. If no match, return None
  if input_emoji in emoji_mapping_dict.keys() :
    translated_response = emoji_mapping_dict[input_emoji]["en"]
  else :
    translated_response = None

  ### Return the final output
  return translated_response
$$
;

-- Test the UDF
select distinct
    trim(REACTION) -- Removes the data error for a clean "distinct" selection
  , TRANSLATE_EMOJI(REACTION) -- Tests the core UDF
  , TRANSLATE_EMOJI('blah') -- Tests a missing entry
from RAW_DATA
;

-------------------------------
-- Challenge code - View leveraging UDF

-- Create a view to output the response
create or replace view CHALLENGE_OUTPUT
as
select
    ID
  , REACTION
  , TRANSLATE_EMOJI(REACTION) as TRANSLATED_REACTION
from RAW_DATA
;

-- Query the view
select * from CHALLENGE_OUTPUT;


-------------------------------
-- Create alert for new emojis

-- Create the alert
create or replace alert ALERT_NEW_EMOJI
  warehouse = WH_CHASTIE
  schedule = 'USING CRON 0 0 * * SUN UTC'
if (
  exists (
    select *
    from CHALLENGE_OUTPUT
    where TRANSLATED_REACTION is NULL
  )
)
then
  call SYSTEM$SEND_EMAIL (
    'EMAILS_CH',
    'REDACTED',
    'Alert: Frosty Friday Week 56 triggered!',
    'Looks like there is a new emoji in the input data for Frosty Friday challenge 56!'
  )
;

-- Describe the alert
desc alert ALERT_NEW_EMOJI;

-- Activate the alert
alter alert ALERT_NEW_EMOJI resume;

-- Disable the alert to avoid the inevitable spam going forwards
alter alert ALERT_NEW_EMOJI suspend;

