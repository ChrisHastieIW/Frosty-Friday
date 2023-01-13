
# Frosty Friday Challenge
# Week 29 - Intermediate - Registering UDFs
# https://frostyfriday.org/2023/01/13/week-29-intermediate/

##################################################################
## Import required modules

## Import InterWorks_Snowpark submodule to simplify creating Snowpark sessions
from shared.interworks_snowpark.interworks_snowpark_python.snowpark_session_builder import build_snowpark_session_via_parameters_json as build_snowpark_session

## Import module for inbound Snowflake session
from snowflake.snowpark import session as snowpark_session_object
from snowflake.snowpark.functions import col
from snowflake.snowpark.udf import UserDefinedFunction as snowpark_udf

## Import other modules
import pandas
from datetime import date

##################################################################
## Define the start-up functions

## Function to build the general infrastructure
## in Snowflake
def build_infrastructure(snowpark_session: snowpark_session_object) :
  snowpark_session.sql(f'''
      create or replace schema WEEK_29
    ''').collect()
  snowpark_session.sql(f'''
      use schema WEEK_29
    ''').collect()

## Function to build the start-up code
## provided in the challenge
def start_up_code(snowpark_session: snowpark_session_object) :
  snowpark_session.sql(f'''
      create or replace file format FROSTY_CSV
        type = csv
        skip_header = 1
        field_optionally_enclosed_by = '"'
    ''').collect()

  snowpark_session.sql(f'''
      create or replace stage W29_STAGE
        url = 's3://frostyfridaychallenges/challenge_29/'
        file_format = FROSTY_CSV
    ''').collect()
    
  snowpark_session.sql(f'''
      list @W29_STAGE
    ''').collect()
    
  snowpark_session.sql(f'''
      create or replace table WEEK_29
      as
      select
          t.$1::int as id
        , t.$2::varchar(100) as first_name
        , t.$3::varchar(100) as surname
        , t.$4::varchar(250) as email
        , t.$5::datetime as start_date 
      from @W29_STAGE (pattern=>'.*start_dates.*') t
    ''').collect()

##################################################################
## Define the function to determine the fiscal year

def determine_fiscal_year(input_date: date):
  if input_date.month >= 5 :
    fiscal_year = input_date.year + 1
  else :
    fiscal_year = input_date.year
  return fiscal_year

##################################################################
## Define the function to register the UDF in Snowflake

def register_udf(snowpark_session: snowpark_session_object) :

  ### Add packages and data types
  from snowflake.snowpark.types import DateType, IntegerType

  ### Create the stage to store the UDF
  snowpark_session.sql(f'''
      create or replace stage W29_STAGE_UDF
    ''').collect()

  ### Upload UDF to Snowflake
  fiscal_year = snowpark_session.udf.register(
      func = determine_fiscal_year
    , return_type = IntegerType()
    , input_types = [DateType()]
    , is_permanent = True
    , name = 'FISCAL_YEAR'
    , replace = True
    , stage_location = '@W29_STAGE_UDF'
  )

  return fiscal_year

##################################################################
## Register the function to test the solution

def test_solution(
      snowpark_session: snowpark_session_object
    , fiscal_year: snowpark_udf
  ) :

  ### Retrieve the data from the table
  data = snowpark_session.table("WEEK_29").select(
        col("id")
      , col("first_name")
      , col("surname")
      , col("email")
      , col("start_date")
      , fiscal_year("start_date").alias("fiscal_year")
    )

  data.show()

  data.group_by("fiscal_year").agg(col("*"), "count").show()

##################################################################
## Define the main function for the challenge

def main() :
  
  ## Build a snowpark session
  snowpark_session = build_snowpark_session()

  ## Perform start-up pieces
  build_infrastructure(snowpark_session)
  start_up_code(snowpark_session)
  
  ## Register the UDF
  fiscal_year = register_udf(snowpark_session)

  ## Test the code
  test_solution(snowpark_session, fiscal_year)

##################################################################
## Execute the main function

main()