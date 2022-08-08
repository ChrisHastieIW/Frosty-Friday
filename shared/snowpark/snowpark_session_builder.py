
## Test connection to Snowflake

### Import session module
from snowflake.snowpark import Session

## Define function to test a connection leveraging
## a locally-stored JSON file containing Snowflake
## connection parameters
def build_snowpark_session_via_parameters_json(
    snowflake_connection_parameters_json_filepath: str = 'snowflake_connection_parameters.json'
  ):

  from .leverage_snowflake_connection_parameters_dictionary import leverage_snowflake_connection_parameters_json

  snowflake_connection_parameters = leverage_snowflake_connection_parameters_json(snowflake_connection_parameters_json_filepath)

  ### Create session to connect to Snowflake
  snowpark_session = Session.builder.configs(snowflake_connection_parameters).create()

  return snowpark_session

## Define function to test a connection leveraging
## a locally-stored streamlit secrets file containing 
## Snowflake connection parameters
def build_snowpark_session_via_streamlit_secrets():

  from .leverage_snowflake_connection_parameters_dictionary import leverage_snowflake_connection_parameters_streamlit_secrets

  snowflake_connection_parameters = leverage_snowflake_connection_parameters_streamlit_secrets()

  ### Create session to connect to Snowflake
  snowpark_session = Session.builder.configs(snowflake_connection_parameters).create()

  return snowpark_session
