
-- This is the main SQL script that is
-- used to create the relevant objects
-- to support the native application package

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_68;

use schema WEEK_68;

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
create or replace stage "STG_NATIVE_APP_CONTENT"
  file_format = "FF_NATIVE_APP_CONTENT"
;

-- View files in stage
list @"STG_NATIVE_APP_CONTENT";

-- This is empty to start. We need
-- to upload our various app content
-- files into this stage. This is achieved
-- with the following commands in a local
-- SnowSQL console:
/* --snowsql

-- Connect to snowSQL with any of the following commands:
snowsql -c my_connection
snowsql -a my.account -u my_user -r my_role --private-key-path "path\to\my\ssh\key.p8"

-- Upload the various files with the following commands:
PUT 'FILE:///C:/My/Path/To/application_files/manifest.yml' @"CH_FROSTY_FRIDAY"."WEEK_68"."STG_NATIVE_APP_CONTENT" overwrite=true auto_compress=false;
PUT 'FILE:///C:/My/Path/To/application_files/scripts/setup.sql' @"CH_FROSTY_FRIDAY"."WEEK_68"."STG_NATIVE_APP_CONTENT"/scripts overwrite=true auto_compress=false;
PUT 'FILE:///C:/My/Path/To/application_files/streamlit/streamlit_interface.py' @"CH_FROSTY_FRIDAY"."WEEK_68"."STG_NATIVE_APP_CONTENT"/streamlit overwrite=true auto_compress=false;
PUT 'FILE:///C:/My/Path/To/README.md' @"CH_FROSTY_FRIDAY"."WEEK_68"."STG_NATIVE_APP_CONTENT" overwrite=true auto_compress=false;

*/

-- View files in stage
list @"STG_NATIVE_APP_CONTENT";


