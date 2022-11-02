
# Build Snowpark sessions for Snowflake

## Import session module
from snowflake.snowpark import Session

## Define function to build a Snowpark session
def build_snowpark_session_from_connection_parameters(
    snowflake_connection_parameters: dict
  ) :

  ### Create session to connect to Snowflake
  snowpark_session = Session.builder.configs(snowflake_connection_parameters).create()

  return snowpark_session

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
  snowpark_session = build_snowpark_session_from_connection_parameters(snowflake_connection_parameters)

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
  snowpark_session = build_snowpark_session_from_connection_parameters(snowflake_connection_parameters)

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
  snowpark_session = build_snowpark_session_from_connection_parameters(snowflake_connection_parameters)

  return snowpark_session

## Define function to build a Snowpark session
## leveraging an inbound dictionary argument
## containing Snowflake connection parameters
def build_snowpark_session_via_parameters_object(
    imported_connection_parameters: dict
  ):

  '''
  imported_connection_parameters is expected in the following format:
  {
    "account": "<account>[.<region>][.<cloud provider>]",
    "user": "<username>",
    "default_role" : "<default role>", // Enter "None" if not required
    "default_warehouse" : "<default warehouse>", // Enter "None" if not required
    "default_database" : "<default database>", // Enter "None" if not required
    "default_schema" : "<default schema>", // Enter "None" if not required
    "private_key_path" : "path\\to\\private\\key", // Enter "None" if not required, in which case private key plain text or password will be used
    "private_key_plain_text" : "-----BEGIN PRIVATE KEY-----\nprivate\nkey\nas\nplain\ntext\n-----END PRIVATE KEY-----", // Not best practice but may be required in some cases. Ignored if private key path is provided
    "private_key_passphrase" : "<passphrase>", // Enter "None" if not required
    "password" : "<password>" // Enter "None" if not required, ignored if private key path or private key plain text is provided
  }
  '''

  ### Import required module
  from .leverage_snowflake_connection_parameters_dictionary import retrieve_snowflake_connection_parameters

  ### Generate Snowflake connection parameters from the relevant source
  snowflake_connection_parameters = retrieve_snowflake_connection_parameters(imported_connection_parameters, private_key_output_format = 'snowpark')

  ### Create session to connect to Snowflake
  snowpark_session = build_snowpark_session_from_connection_parameters(snowflake_connection_parameters)

  return snowpark_session
