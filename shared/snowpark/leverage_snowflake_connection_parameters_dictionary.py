
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
    if len(imported_connection_parameters[parameter_name]) > 0 \
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
def retrieve_snowflake_connection_parameters(
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
      raise ValueError(f'{current_parameter["parameter_imported_name"]} must be provided in JSON file')

  return provided_parameters


def retrieve_snowflake_connection_parameters_from_imported_snowflake_connection_parameters(
    imported_connection_parameters: dict
  ):

  ### Define empty variables that will be populated with JSON
  snowflake_connection_parameters = {}

  ### Populate snowflake_connection_parameters from imported_connection_parameters
  snowflake_connection_parameters = retrieve_snowflake_connection_parameters(imported_connection_parameters)

  ### If appropriate, serialize private key from path, leveraging passphrase if needed
  if "private_key_path" in imported_connection_parameters.keys() :
    if len(imported_connection_parameters["private_key_path"]) > 0 \
      and imported_connection_parameters["private_key_path"] != "None" \
      and imported_connection_parameters["private_key_path"] != "path\\to\\private\\key" \
      :
      snowflake_connection_parameters["private_key"] = serialize_private_key_from_path(
            private_key_path = imported_connection_parameters["private_key_path"]
          , private_key_passphrase = imported_connection_parameters["private_key_passphrase"]
        )
      ### Remove password if this was provided as well
      snowflake_connection_parameters.pop("password", None)
    ### Otherwise error if password was not provided
    elif "password" not in snowflake_connection_parameters.keys() :
      raise ValueError('Either private_key_path or password must be provided in JSON file')
  ### Otherwise error if password was not provided
  elif "password" not in snowflake_connection_parameters.keys() :
    raise ValueError('Either private_key_path or password must be provided in JSON file')

  return snowflake_connection_parameters

def leverage_snowflake_connection_parameters_json(
    snowflake_connection_parameters_json_filepath: str = 'snowflake_connection_parameters.json'
  ):

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
  snowflake_connection_parameters = retrieve_snowflake_connection_parameters_from_imported_snowflake_connection_parameters(imported_connection_parameters)

  return snowflake_connection_parameters

def leverage_snowflake_connection_parameters_streamlit_secrets():

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
  snowflake_connection_parameters = retrieve_snowflake_connection_parameters_from_imported_snowflake_connection_parameters(imported_connection_parameters)

  return snowflake_connection_parameters