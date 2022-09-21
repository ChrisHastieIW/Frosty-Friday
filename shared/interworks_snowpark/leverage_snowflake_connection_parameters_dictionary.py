
# Leverage a snowflake_connection_parameters dictionary

''' 

This Python script is configured to ingest a snowflake_connection_parameters
dictionary and use it to establish connections to Snowflake.

More information is found in the corresponding README.md in the repository

'''

## Import required modules
import json
from .serialize_private_key import *
from .imported_snowflake_parameter_mapping import imported_snowflake_parameter_mapping

## Define function to retrieve a
## parameter if it has been provided
def retrieve_parameter(
      imported_connection_parameters: dict
    , parameter_name: str
    , parameter_placeholder_value: str
  ):

  if parameter_name in imported_connection_parameters.keys() :
    if imported_connection_parameters[parameter_name] is not None \
      and len(imported_connection_parameters[parameter_name]) > 0 \
      and imported_connection_parameters[parameter_name] != 'None' \
      and imported_connection_parameters[parameter_name] != parameter_placeholder_value \
      :
      return imported_connection_parameters[parameter_name]
    else:
      return None
  else:
    return None

## Define function to build list of all
## parameters and iterate through it
## to retrieve any that have been provided
## and error if critical entries are missing
def retrieve_core_snowflake_connection_parameters(
    imported_connection_parameters: dict
  ):

  ### Define empty object to return
  provided_parameters = {}
  
  ### Iterate through mapped list of parameters
  ### to retrieve any that have been provided
  for current_parameter in imported_snowflake_parameter_mapping:
    retrieved_parameter_value = retrieve_parameter(
        imported_connection_parameters = imported_connection_parameters
      , parameter_name = current_parameter["parameter_imported_name"]
      , parameter_placeholder_value = current_parameter["parameter_placeholder_value"]
      )
    
    if retrieved_parameter_value != None :
      provided_parameters[current_parameter["parameter_snowflake_name"]] = retrieved_parameter_value

    elif current_parameter["parameter_required_flag"] == 1 :
      raise ValueError(f'{current_parameter["parameter_imported_name"]} must be provided in imported connection parameters')

  return provided_parameters

def retrieve_snowflake_private_key_parameter(
      imported_connection_parameters: dict
    , private_key_output_format: str = 'snowpark'
  ):

  '''
  private_key_output_format options are:
  - Snowpark : Intended for creating Snowpark sessions
  - Snowpipe : Intended for creating Snowpipe SimpleIngestManager objects
  '''

  ### Define empty variables that will be populated by the function
  private_key = None
  private_key_passphrase = None

  ### If appropriate, leverage passphrase
  if "private_key_passphrase" in imported_connection_parameters.keys() :
    if imported_connection_parameters["private_key_passphrase"] is not None \
      and len(imported_connection_parameters["private_key_passphrase"]) > 0 \
      and imported_connection_parameters["private_key_passphrase"] != "None" \
      and imported_connection_parameters["private_key_passphrase"] != "<passphrase>" \
      :
      private_key_passphrase = imported_connection_parameters["private_key_passphrase"]

  ### If appropriate, serialize private key from path
  if "private_key_path" in imported_connection_parameters.keys() :
    if imported_connection_parameters["private_key_path"] is not None \
      and len(imported_connection_parameters["private_key_path"]) > 0 \
      and imported_connection_parameters["private_key_path"] != "None" \
      and imported_connection_parameters["private_key_path"] != "path\\to\\private\\key" \
      :
      private_key = serialize_private_key_from_path(
            private_key_path = imported_connection_parameters["private_key_path"]
          , private_key_passphrase = private_key_passphrase
          , private_key_output_format = private_key_output_format
        )
  
  ### Return value if appropriate, otherwise continue checking other keys
  if private_key is not None:
    return private_key
    
  ### If appropriate, serialize private key from plain text
  if "private_key_plain_text" in imported_connection_parameters.keys() :
    if imported_connection_parameters["private_key_plain_text"] is not None \
      and len(imported_connection_parameters["private_key_plain_text"]) > 0 \
      and imported_connection_parameters["private_key_plain_text"] != "None" \
      and imported_connection_parameters["private_key_plain_text"] != "-----BEGIN PRIVATE KEY-----\nprivate\nkey\nas\nplain\ntext\n-----END PRIVATE KEY-----" \
      :
      private_key = serialize_encoded_private_key(
            private_key_encoded = imported_connection_parameters["private_key_plain_text"].encode()
          , private_key_passphrase = private_key_passphrase
          , private_key_output_format = private_key_output_format
        )
  
  ### Return value if appropriate, otherwise continue checking other keys
  if private_key is not None:
    return private_key
  else :
    return None

def retrieve_snowflake_connection_parameters(
      imported_connection_parameters: dict
    , private_key_output_format: str = 'snowpark'
  ):

  '''
  private_key_output_format options are:
  - Snowpark : Intended for creating Snowpark sessions
  - Snowpipe : Intended for creating Snowpipe SimpleIngestManager objects
  '''

  ### Define empty variables that will be populated with JSON
  snowflake_connection_parameters = {}

  ### Populate snowflake_connection_parameters from imported_connection_parameters
  snowflake_connection_parameters = retrieve_core_snowflake_connection_parameters(imported_connection_parameters)

  snowflake_private_key = retrieve_snowflake_private_key_parameter(imported_connection_parameters, private_key_output_format)

  ### If aa private key was identified, leverage it and remove the old password
  if snowflake_private_key is not None :
    snowflake_connection_parameters["private_key"] = snowflake_private_key
    ### Remove password if this was provided as well
    snowflake_connection_parameters.pop("password", None)
  ### Otherwise error if password was not provided
  elif "password" not in snowflake_connection_parameters.keys() :
    raise ValueError('Either private_key_path, private_key_plain_text or password must be provided in imported connection parameters')

  return snowflake_connection_parameters

def import_snowflake_connection_parameters_from_local_json(
      snowflake_connection_parameters_json_filepath: str = 'snowflake_connection_parameters.json'
    , private_key_output_format: str = 'snowpark'
  ):

  '''
  private_key_output_format options are:
  - Snowpark : Intended for creating Snowpark sessions
  - Snowpipe : Intended for creating Snowpipe SimpleIngestManager objects
  '''

  ### Define empty variables that will be populated with JSON
  imported_connection_parameters = {}
  snowflake_connection_parameters = {}

  ### Attempt to ingest JSON file
  try:
    with open(snowflake_connection_parameters_json_filepath) as f:
      imported_connection_parameters = json.load(f)
  
  except Exception as e:
    raise ValueError(f'Error reading JSON file from {snowflake_connection_parameters_json_filepath}') from e

  ### Populate snowflake_connection_parameters from imported_connection_parameters
  snowflake_connection_parameters = retrieve_snowflake_connection_parameters(imported_connection_parameters, private_key_output_format)

  return snowflake_connection_parameters

def import_snowflake_connection_parameters_from_streamlit_secrets(
    private_key_output_format: str = 'snowpark'
  ):

  '''
  private_key_output_format options are:
  - Snowpark : Intended for creating Snowpark sessions
  - Snowpipe : Intended for creating Snowpipe SimpleIngestManager objects
  '''

  ### Define empty variables that will be populated with JSON
  imported_connection_parameters = {}
  snowflake_connection_parameters = {}

  ### Attempt to leverage Streamlit secrets file
  try:
    import streamlit
    imported_connection_parameters = streamlit.secrets["snowflake_connection_parameters"]
  
  except Exception as e:
    raise ValueError('Error reading Streamlit secrets file') from e

  ### Populate snowflake_connection_parameters from imported_connection_parameters
  snowflake_connection_parameters = retrieve_snowflake_connection_parameters(imported_connection_parameters, private_key_output_format)

  return snowflake_connection_parameters

def import_snowflake_connection_parameters_from_environment_variables(
    private_key_output_format: str = 'snowpark'
  ):

  '''
  private_key_output_format options are:
  - Snowpark : Intended for creating Snowpark sessions
  - Snowpipe : Intended for creating Snowpipe SimpleIngestManager objects
  '''

  ### Define empty variable that will be populated with JSON
  snowflake_connection_parameters = {}

  ### Define imported connection parameters using environment variables
  import os
  imported_connection_parameters = {
      "account" : os.getenv("SNOWFLAKE_ACCOUNT")
    , "user" : os.getenv("SNOWFLAKE_USER")
    , "default_role" : os.getenv("SNOWFLAKE_DEFAULT_ROLE")
    , "default_warehouse" : os.getenv("SNOWFLAKE_DEFAULT_WAREHOUSE")
    , "default_database" : os.getenv("SNOWFLAKE_DEFAULT_DATABASE")
    , "default_schema" : os.getenv("SNOWFLAKE_DEFAULT_SCHEMA")
    , "private_key_path" : os.getenv("SNOWFLAKE_PRIVATE_KEY_PATH")
    , "private_key_plain_text" : os.getenv("SNOWFLAKE_PRIVATE_KEY_PLAIN_TEXT")
    , "private_key_passphrase" : os.getenv("SNOWFLAKE_PRIVATE_KEY_PASSPHRASE")
    , "password" : os.getenv("SNOWFLAKE_PASSWORD")
  }

  ### Populate snowflake_connection_parameters from imported_connection_parameters
  snowflake_connection_parameters = retrieve_snowflake_connection_parameters(imported_connection_parameters, private_key_output_format)

  return snowflake_connection_parameters