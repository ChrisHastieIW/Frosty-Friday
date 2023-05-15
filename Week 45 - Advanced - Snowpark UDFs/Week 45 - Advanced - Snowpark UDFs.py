
# Frosty Friday Challenge
# Week 45 - Advanced - Snowpark UDFs
# https://frostyfriday.org/2023/05/12/week-45-advanced/

##################################################################
## Import required modules

## Import InterWorks_Snowpark submodule to simplify creating Snowpark sessions
from shared.interworks_snowpark.interworks_snowpark_python.snowpark_session_builder import build_snowpark_session_via_parameters_json as build_snowpark_session

## Import specific Snowpark features
from snowflake.snowpark import session as snowpark_session_object
from snowflake.snowpark.types import StringType
from snowflake.snowpark.functions import call_udf, col

##################################################################
## Configure the environment

## Function to configure the environment
## in Snowflake
def configure_snowflake_environment(
      snowpark_session: snowpark_session_object
    , stage_name: str
  ) :
  
  ### Create and use the schema
  snowpark_session.sql(f'''
      create or replace schema WEEK_45
    ''').collect()
  snowpark_session.use_schema("WEEK_45")

  ### Create the stage
  snowpark_session.sql(f'''
      create or replace stage "{stage_name}"
    ''').collect()

## Function to create challenge data table(s) in Snowflake
def create_challenge_data(snowpark_session: snowpark_session_object) :
  
  ### Create and use the schema
  snowpark_session.sql(f'''
      CREATE OR REPLACE TABLE WEBSITE_CLICKS (
            ID INTEGER
          , USER_ID INTEGER
          , PAGE_URL STRING
          , CLICK_TIME TIMESTAMP
          , CLICK_LOCATION STRING
        )
      AS
      SELECT * FROM VALUES
          (1, 101, 'https://www.example.com/home', '2023-05-12 08:00:00', '<div id="header" class="header">')
        , (2, 102, 'https://www.example.com/products', '2023-05-12 08:05:00', '<main class="content">')
        , (3, 101, 'https://www.example.com/about', '2023-05-12 08:10:00', '<footer class="site-footer">')
        , (4, 103, 'https://www.example.com/home', '2023-05-12 08:15:00', '<section class="main-content">')
        , (5, 102, 'https://www.example.com/contact', '2023-05-12 08:20:00', '<header class="site-header">')
    ''').collect()

## Upload UDF input code to stage
def upload_udf_code_to_stage(
      snowpark_session: snowpark_session_object
    , stage_name: str
    , path_to_udf_code_file: str
  ) :
  
  ### Upload the file to the stage
  put_result = snowpark_session.file.put(path_to_udf_code_file, f'@"{stage_name}"', overwrite=True)
  if put_result[0].status != 'UPLOADED':
    raise ValueError(put_result[0].status)
  
##################################################################
## Define the function to register the UDF in Snowflake

def register_udf(
      snowpark_session: snowpark_session_object
    , stage_name: str
    , path_to_udf_code_file: str
  ) :

  udf_code_file_name = path_to_udf_code_file.split("\\")[-1]

  ### Upload UDF to Snowflake
  snowpark_session.udf.register_from_file(
      file_path = f'@"{stage_name}"/{udf_code_file_name}.gz' # Add .gz as file is compressed during upload
    , func_name = "extract_class_value"
    , return_type = StringType()
    , input_types = [StringType()]
    , is_permanent = True
    , name = 'EXTRACT_CLASS_VALUE'
    , replace = True
    , stage_location = f'@"{stage_name}"'
  )

##################################################################
## Register the function to test the solution

def test_solution(
      snowpark_session: snowpark_session_object
  ) :

  clean_data = (
    snowpark_session.table("WEBSITE_CLICKS")
    .withColumn(
        "CLICK_LOCATION",
        call_udf("EXTRACT_CLASS_VALUE", col("CLICK_LOCATION"))
    )
  )
  
  return clean_data

##################################################################
## Define the main function for the challenge

def main() :
  
  ## Build a snowpark session
  snowpark_session = build_snowpark_session()

  ### Lazily written path that 
  ### only works when executing
  ### from the root of the repo
  path_to_udf_code_file = "Week 45 - Advanced - Snowpark UDFs\\inputs\\udf.py"
  stage_name = "WEEK_45_STAGE"

  ## Perform start-up pieces
  configure_snowflake_environment(snowpark_session=snowpark_session, stage_name=stage_name)
  create_challenge_data(snowpark_session)
  upload_udf_code_to_stage(snowpark_session=snowpark_session, stage_name=stage_name, path_to_udf_code_file=path_to_udf_code_file)
  
  ## Register the UDF
  register_udf(snowpark_session=snowpark_session, stage_name=stage_name, path_to_udf_code_file=path_to_udf_code_file)

  ## Test the code
  clean_data = test_solution(snowpark_session)

  clean_data.show()

##################################################################
## Execute the main function

main()
