
-- Frosty Friday Challenge
-- Week 20 - Hard - Stored Procedures
-- https://frostyfriday.org/2022/10/28/week-20-hard/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_20;

drop schema if exists WEEK_20_CLONE;
drop schema if exists WEEK_20_CLONE_2;

use schema WEEK_20;

------------------------------------------------------------------
-- Create the stored procedure to clone a schema within a database with all grants

-- Create the stored procedure
CREATE OR REPLACE PROCEDURE CLONE_SCHEMA_WITH_GRANTS(
      SOURCE_DATABASE STRING
    , SOURCE_SCHEMA STRING
    , DESTINATION_DATABASE STRING
    , DESTINATION_SCHEMA STRING
    , CUSTOM_STATEMENT STRING
  )
  returns string not null
  language python
  runtime_version = '3.8'
  packages = ('snowflake-snowpark-python', 'pandas')
  handler = 'clone_schema_with_grants'
  execute as caller
as
$$

# Import module for inbound Snowflake session
from snowflake.snowpark import session as snowpark_session

# Import required modules
import pandas as pd

# Define function to clone the schema
def clone_schema(
      snowpark_session: snowpark_session
    , source_database: str
    , source_schema: str
    , destination_database: str
    , destination_schema: str
    , custom_statement:str
  ):

  custom_statement_string = ''
  if custom_statement and len(custom_statement) > 0 :
    custom_statement_string = custom_statement
  ## Execute SQL to clone the schema
  ## using ''' for a multi-line string input
  snowpark_session.sql(f'''
      CREATE SCHEMA IF NOT EXISTS "{destination_database}"."{destination_schema}"
        CLONE "{source_database}"."{source_schema}"
        {custom_statement_string}
    ''').collect()
  
  return

# Define function to create the destination database if it does not exist
def create_destination_database(
      snowpark_session: snowpark_session
    , destination_database: str
  ):

  ## Create destination database
  ## using ''' for a multi-line string input
  snowpark_session.sql(f'''
      CREATE DATABASE IF NOT EXISTS "{destination_database}"
    ''').collect()
  
  return destination_database

# Define function to retrieve list of grants on schema
def retrieve_schema_grants(
      snowpark_session: snowpark_session
    , source_database: str
    , source_schema: str
  ):
  
  ## Retrieve grants on schema
  ## using ''' for a multi-line string input
  sf_df_schema_grants = snowpark_session.sql(f'''
      SHOW GRANTS ON SCHEMA "{source_database}"."{source_schema}"
    ''')

  df_schema_grants = pd.DataFrame(data=sf_df_schema_grants.collect())

  schema_grants_list = df_schema_grants.to_dict('records')
  
  return schema_grants_list

# Define function to create the destination database if it does not exist
def grant_privilege_on_schema(
      snowpark_session: snowpark_session
    , destination_database: str
    , destination_schema: str
    , schema_grant: dict
  ):

  if schema_grant["privilege"] != 'OWNERSHIP' :
    ## Grant specific privilege
    ## using ''' for a multi-line string input
    snowpark_session.sql(f'''
        GRANT {schema_grant["privilege"]} ON SCHEMA "{destination_database}"."{destination_schema}" TO ROLE "{schema_grant["grantee_name"]}"
      ''').collect()
  else :
    ## Grant ownership privilege and maintain current grants
    ## using ''' for a multi-line string input
    snowpark_session.sql(f'''
        GRANT {schema_grant["privilege"]} ON SCHEMA "{destination_database}"."{destination_schema}" TO ROLE "{schema_grant["grantee_name"]}" COPY CURRENT GRANTS
      ''').collect()
  
  return destination_database
  
# Define main function to clone a schema with grants
def clone_schema_with_grants(
      snowpark_session: snowpark_session
    , source_database: str
    , source_schema: str
    , destination_database: str
    , destination_schema: str
    , custom_statement:str
  ):

  ## Execute function to create the destination database
  ## if it does not already exist
  create_destination_database(
        snowpark_session = snowpark_session
      , destination_database = destination_database
    )

  ## Execute function to clone the schema
  clone_schema(
        snowpark_session = snowpark_session
      , source_database = source_database
      , source_schema = source_schema
      , destination_database = destination_database
      , destination_schema = destination_schema
      , custom_statement = custom_statement
    )

  ## Execute function to get list of schema grants
  schema_grants_list = retrieve_schema_grants(
        snowpark_session = snowpark_session
      , source_database = source_database
      , source_schema = source_schema
    )

  ## Loop over views in list
  for schema_grant in schema_grants_list :

    ### Execute function to build schema grant
    grant_privilege_on_schema(
          snowpark_session = snowpark_session
        , destination_database = destination_database
        , destination_schema = destination_schema
        , schema_grant = schema_grant
      )
  
  return 'Complete'
$$
;

------------------------------------------------------------------
-- Testing

call CLONE_SCHEMA_WITH_GRANTS(
      'CH_FROSTY_FRIDAY'
    , 'WEEK_20'
    , 'CH_FROSTY_FRIDAY'
    , 'WEEK_20_CLONE'
    , NULL
  )
;

show grants on schema WEEK_20_CLONE;

-- Wait 1 minute before running this one
call CLONE_SCHEMA_WITH_GRANTS(
      'CH_FROSTY_FRIDAY'
    , 'WEEK_20'
    , 'CH_FROSTY_FRIDAY'
    , 'WEEK_20_CLONE_2'
    , 'AT(OFFSET => -60)'
  )
;

show grants on schema WEEK_20_CLONE_2;