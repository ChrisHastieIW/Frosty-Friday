
-- This is the main SQL script that is
-- used to create the relevant objects
-- to support the native application package

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_75;

use schema WEEK_75;

-------------------------------
-- Stage creation

-- Create the file format that is leveraged
-- by the native app content files
create or replace file format "FF_NATIVE_APP_CONTENT"
  type = 'CSV'
  field_delimiter = '|'
  skip_header = 1
;

-- Create the stage that contains the native app content files
create or replace stage "STG__NATIVE_APP_CONTENT"
  file_format = "FF_NATIVE_APP_CONTENT"
;

-- View files in stage
list @"STG__NATIVE_APP_CONTENT";

-- This is empty to start. We need
-- to upload our various app content
-- files into this stage. This is achieved
-- with the following commands in a local
-- SnowSQL console:

--------------------------- snowsql ---------------------------

-- Connect to snowSQL with any of the following commands:
snowsql -c my_connection
snowsql -a my.account -u my_user -r my_role --private-key-path "path\to\my\ssh\key.p8"

-- Upload the various files with the following commands:
use schema "CH_FROSTY_FRIDAY"."WEEK_75";
remove @"STG__NATIVE_APP_CONTENT"/v1/; -- Empty stage for current version if needed
PUT 'FILE://application_files/manifest.yml' @"STG__NATIVE_APP_CONTENT"/v1/ overwrite=true auto_compress=false;
PUT 'FILE://application_files/README.md' @"STG__NATIVE_APP_CONTENT"/v1/ overwrite=true auto_compress=false;
PUT 'FILE://application_files/scripts/*' @"STG__NATIVE_APP_CONTENT"/v1/scripts/ overwrite=true auto_compress=false;
PUT 'FILE://application_files/streamlit/*' @"STG__NATIVE_APP_CONTENT"/v1/streamlit/ overwrite=true auto_compress=false;

--------------------------- snowsql ---------------------------

-- View files in stage
list @"STG_NATIVE_APP_CONTENT";

-------------------------------
-- Table creation

-- Creates the basic empty table that we will use for the app
create or replace table MY_DEMO_TABLE (
    ID int
  , CATEGORY string
)
as
select * from values
    (1, 'CAT_A')
  , (2, 'CAT_B')
;
