
-- Frosty Friday Challenge
-- Week 10 - Hard - Stored Procedures
-- https://frostyfriday.org/2022/08/19/week-10-hard/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_10;

use schema WEEK_10;

-------------------------------
-- Create warehouses

-- Create warehouse
create warehouse if not exists WH_CHASTIE_FROSTY_FRIDAY_WEEK_10
with 
  warehouse_size = xsmall
  auto_suspend = 120
  initially_suspended = true
;

-------------------------------
-- Create landing table

-- Create a table in which to land the data
create or replace table LANDING_TABLE (
    FILE_NAME STRING
  , ROW_NUMBER INT
  , TIMESTAMP TIMESTAMP
  , TRANSACTION_AMOUNT DOUBLE
)
;

-------------------------------
-- Create stage

-- First create stage without file format
-- so we can determine what the file format
-- should be
create or replace stage STG_WEEK_10
    url = 's3://frostyfridaychallenges/challenge_10/'
    -- file_format = <enter_file_format>
;

-- View files in stage
list @STG_WEEK_10;

-------------------------------
-- Investigate files in stage

-- Create a simple file format that will 
-- ingest the full data into a single 
-- field for simple understanding
create or replace file format FF_SINGLE_FIELD
    type = CSV
    field_delimiter = NONE
    record_delimiter = NONE
    skip_header = 0 
;

-- Query the data using the single field
-- file format to understand the contents
select 
    METADATA$FILENAME::STRING as FILE_NAME
  , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
  , $1::VARIANT as CONTENTS
from @STG_WEEK_10
  (file_format => 'FF_SINGLE_FIELD')
order by 
    FILE_NAME
  , ROW_NUMBER
;

-- We can ingest the file with the standard
-- csv file format


-- Create the appropriate file format
create or replace file format FF_CSV_INGESTION
    type = CSV
    field_delimiter = ','
    record_delimiter = '\n'
    skip_header = 1
;

-------------------------------
-- Recreate stage

-- Now recreate the stage with the file format
-- so that it matches the challenge template
create or replace stage STG_WEEK_10
    url = 's3://frostyfridaychallenges/challenge_10/'
    file_format = FF_CSV_INGESTION
;

-- See stage details
DESC STAGE STG_WEEK_10;

-------------------------------
-- Test by ingesting the files into the table

-- Ingest the data
COPY INTO LANDING_TABLE
FROM (
  select 
      METADATA$FILENAME::STRING as FILE_NAME
    , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
    , $1::timestamp as TIMESTAMP
    , $2::double as TRANSACTION_AMOUNT
  from @STG_WEEK_10
)
;

-- Query the results
-- to see load works
SELECT * FROM LANDING_TABLE;

-- Truncate landing table again
-- so we can use stored procedure
TRUNCATE TABLE LANDING_TABLE;

-------------------------------
-- Stored procedure

-- To create this stored procedure,
-- I followed the same process as in
-- my blog post:

-- Definitive Guide to Python
-- Stored Procedures in the Snowflake UI

-- https://interworks.com/blog/2022/08/16/a-definitive-guide-to-python-stored-procedures-in-the-snowflake-ui/

-- Create the stored procedure
CREATE OR REPLACE PROCEDURE dynamic_warehouse_data_load(
      stage_name string
    , table_name string
  )
  returns string not null
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python', 'pandas')
  handler = 'dynamic_warehouse_data_load_py'
as
$$

# Import required modules
import pandas
import snowflake.snowpark
import json

# Define function to retrieve the URL
# of the stage, that will need to be
# stripped from file paths during dynamic load
def retrieve_stage_url(
      snowpark_session : snowflake.snowpark.Session
    , stage_name : str
  ):
  
  ## Return DESC of stage
  stage_description_sf_df = snowpark_session.sql(f'''
      DESC STAGE {stage_name}
    ''').collect()
  
  ## Cannot use to_pandas() as the
  ## Snowflake dataframe came from session.sql()
  ## but did not come from a SELECT statement.
  ## Instead, use list comprehension to
  ## retrieve the URL list (which is how
  ## Snowflake stored the URL in this output)
  url_list = [
      row.as_dict()["property_value"] 
      for row in stage_description_sf_df 
      if row.as_dict()["property"] == 'URL'
    ]

  ## Retrieve the URL from the URL list
  stage_url = json.loads(url_list[0])[0]
  
  return stage_url

# Define function to LIST files
# in the stage and determine their size
def retrieve_files_list(
      snowpark_session : snowflake.snowpark.Session
    , stage_name : str
  ):
  
  ## Return LIST of stage
  ## as Snowflake dataframe
  stage_list_sf_df = snowpark_session.sql(f'''
      LIST '@{stage_name}'
    ''').collect()
  
  ## Cannot use to_pandas() as the
  ## Snowflake dataframe came from session.sql()
  ## but did not come from a SELECT statement.
  ## Instead, use list comprehension to
  ## retrieve specific file details
  files_list = [
      {
          "name" : row.as_dict()["name"]
        , "size" : row.as_dict()["size"]
      } 
      for row in stage_list_sf_df
    ]
  
  return files_list

# Define a statement to determine
# the relative path for each
# file in the files list
def add_relative_path_to_files_list(
      files_list: list
    , stage_url : str
  ) :

  ## Use list comprension and dict key addition
  ## to add the relative path for each file,
  ## which is the name without the prefixed URL
  files_list_with_relative_paths = [
      {
          **specific_file
        , **{"relative_path" : specific_file["name"].replace(stage_url, "")}
      } 
      for specific_file in files_list
    ]
    
  return files_list_with_relative_paths

# Define function to execute COPY INTO
# statement for a given file.
# Unfortunately this approach currently fails
# as Python SProcs do not support changing warehouses
def dynamic_data_load_fails(
      snowpark_session : snowflake.snowpark.Session
    , stage_name : str
    , table_name : str
    , file_dict : dict
  ):
  
  ## Determine the correct warehouse
  ## using SMALL warehouse for files
  ## over 10KB (i.e. 10000B)
  snowflake_warehouse = 'WH_CHASTIE_FROSTY_FRIDAY_XS'
  if file_dict["size"] > 10000 :
    snowflake_warehouse = 'WH_CHASTIE_FROSTY_FRIDAY_S'
    
  ## Use desired warehouse attempt 1
  ## which seems to fail from a Snowflake error
  # snowpark_session.use_warehouse(snowflake_warehouse)
  
  ## Use desired warehouse attempt 2
  ## which also seems to fail
  # snowpark_session.sql(f'''
  #     USE WAREHOUSE {snowflake_warehouse}
  #   ''').collect()
  
  ## Execute data load
  ingestion_sf_df = snowpark_session.sql(f'''
    COPY INTO {table_name}
    FROM (
      select 
          METADATA$FILENAME::STRING as FILE_NAME
        , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
        , $1::timestamp as TIMESTAMP
        , $2::double as TRANSACTION_AMOUNT
      from '@{stage_name}/{file_dict["relative_path"]}
    )
  ''').collect()
  
  ## Determine rows loaded
  rows_loaded = ingestion_sf_df[0].as_dict()["rows_loaded"]
  
  return rows_loaded
  
# Define function to execute COPY INTO
# statement for a given file
def dynamic_data_load(
      snowpark_session : snowflake.snowpark.Session
    , stage_name : str
    , table_name : str
    , file_dict : dict
  ):
  
  ## Determine the current warehouse
  current_warehouse  = snowpark_session.get_current_warehouse()
  
  ## Determine warehouse size for challenge
  ## for files over 10KB (i.e. 10000B)
  warehouse_size = 'XSMALL'
  if file_dict["size"] > 10000 :
    warehouse_size = 'SMALL'
    
  ## Modify warehouse size
  snowpark_session.sql(f'''
      ALTER WAREHOUSE {current_warehouse}
      SET WAREHOUSE_SIZE = {warehouse_size}
    ''').collect()
      
  ## Execute data load
  ingestion_sf_df = snowpark_session.sql(f'''
      COPY INTO {table_name}
      FROM (
        select 
            METADATA$FILENAME::STRING as FILE_NAME
          , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
          , $1::timestamp as TIMESTAMP
          , $2::double as TRANSACTION_AMOUNT
        from '@{stage_name}/{file_dict["relative_path"]}'
      )
    ''').collect()
  
  ## Determine rows loaded
  rows_loaded = ingestion_sf_df[0].as_dict()["rows_loaded"]
  
  return rows_loaded
  
# Define main function for the stored procedure
def dynamic_warehouse_data_load_py(
      snowpark_session : snowflake.snowpark.Session
    , stage_name : str
    , table_name : str
  ):
  
  ## Retrieve the URL of the stage,
  ## that will need to be stripped from 
  ## file paths during dynamic load
  stage_url = retrieve_stage_url(
        snowpark_session = snowpark_session
      , stage_name = stage_name
    )
  
  ## Retrieve the list of files in the stage
  files_list = retrieve_files_list(
        snowpark_session = snowpark_session
      , stage_name = stage_name
    )
   
  ## Determine the relative path for each
  ## file in the files list
  files_list_with_relative_paths = add_relative_path_to_files_list(
        files_list = files_list
      , stage_url = stage_url
    )

  ## Define count of total rows loaded
  total_rows_loaded = 0
  
  ## Iterative through the files in the
  ## files list and execute the data load,
  ## adding result to total rows loaded
  for file_dict in files_list_with_relative_paths :
    total_rows_loaded += dynamic_data_load(
        snowpark_session = snowpark_session
      , stage_name = stage_name
      , table_name = table_name
      , file_dict = file_dict
    )
  
  return f'{total_rows_loaded} rows were added'
$$
;

-- Call the stored procedure with the correct warehouse
USE WAREHOUSE WH_CHASTIE_FROSTY_FRIDAY_WEEK_10;
call dynamic_warehouse_data_load('STG_WEEK_10', 'LANDING_TABLE');

-- Validate against query history
select *
from table(information_schema.QUERY_HISTORY_BY_WAREHOUSE())
;

-- Validate against copy history
select *
from table(information_schema.COPY_HISTORY(
       TABLE_NAME => 'LANDING_TABLE'
     , START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
  ))
;