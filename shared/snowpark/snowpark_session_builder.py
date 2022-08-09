
# Build Snowpark sessions for Snowflake

## Import session module
from snowflake.snowpark import Session

## Define function to build a Snowpark session
## leveraging a locally-stored JSON file
## containing Snowflake connection parameters
def build_snowpark_session_via_parameters_json(
    snowflake_connection_parameters_json_filepath: str = 'snowflake_connection_parameters.json'
  ):

  ### Import required module
  from .leverage_snowflake_connection_parameters_dictionary import import_snowflake_connection_parameters_from_local_json

  ### Generate Snowflake connection parameters from the relevant source
  snowflake_connection_parameters = import_snowflake_connection_parameters_from_local_json(snowflake_connection_parameters_json_filepath, private_key_output_format = 'snowpark')

  ### Create session to connect to Snowflake
  snowpark_session = Session.builder.configs(snowflake_connection_parameters).create()

  return snowpark_session

## Define function to build a Snowpark session
## leveraging a streamlit secrets file
## containing Snowflake connection parameters
def build_snowpark_session_via_streamlit_secrets():
  
  ### Import required module
  from .leverage_snowflake_connection_parameters_dictionary import import_snowflake_connection_parameters_from_streamlit_secrets

  ### Generate Snowflake connection parameters from the relevant source
  snowflake_connection_parameters = import_snowflake_connection_parameters_from_streamlit_secrets(private_key_output_format = 'snowpark')

  ### Create session to connect to Snowflake
  snowpark_session = Session.builder.configs(snowflake_connection_parameters).create()

  return snowpark_session

## Define function to build a Snowpark session
## leveraging environment variables
## containing Snowflake connection parameters
def build_snowpark_session_via_environment_variables():
  
  ### Import required module
  from .leverage_snowflake_connection_parameters_dictionary import import_snowflake_connection_parameters_from_environment_variables

  ### Generate Snowflake connection parameters from the relevant source
  snowflake_connection_parameters = import_snowflake_connection_parameters_from_environment_variables(private_key_output_format = 'snowpark')

  ### Create session to connect to Snowflake
  snowpark_session = Session.builder.configs(snowflake_connection_parameters).create()

  return snowpark_session
