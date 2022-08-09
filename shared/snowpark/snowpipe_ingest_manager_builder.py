
# Build Snowpipe ingest manager for Snowflake

## Import snowpipe module
from snowflake.ingest import SimpleIngestManager

## Define function to build a snowpipe ingest manager
## leveraging a locally-stored JSON file
## containing Snowflake connection parameters
def build_snowpipe_ingest_manager_via_parameters_json(
      snowflake_connection_parameters_json_filepath: str = 'snowflake_connection_parameters.json'
    , target_pipe_name : str = None
  ):

  from .leverage_snowflake_connection_parameters_dictionary import import_snowflake_connection_parameters_from_local_json

  snowflake_connection_parameters = import_snowflake_connection_parameters_from_local_json(snowflake_connection_parameters_json_filepath, private_key_output_format = 'snowpipe')

  snowpipe_ingest_manager = SimpleIngestManager(
      account=snowflake_connection_parameters["account"]
    , host=f'{snowflake_connection_parameters["account"]}.snowflakecomputing.com'
    , user=snowflake_connection_parameters["user"]
    , pipe=target_pipe_name
    , private_key=snowflake_connection_parameters["private_key"]
  )

  return snowpipe_ingest_manager

## Define function to build a snowpipe ingest manager
## leveraging a Streamlit secrets file
## containing Snowflake connection parameters
def build_snowpipe_ingest_manager_via_streamlit_secrets(
    target_pipe_name : str = None
  ):

  from .leverage_snowflake_connection_parameters_dictionary import import_snowflake_connection_parameters_from_streamlit_secrets

  snowflake_connection_parameters = import_snowflake_connection_parameters_from_streamlit_secrets(private_key_output_format = 'snowpipe')

  snowpipe_ingest_manager = SimpleIngestManager(
      account=snowflake_connection_parameters["account"]
    , host=f'{snowflake_connection_parameters["account"]}.snowflakecomputing.com'
    , user=snowflake_connection_parameters["user"]
    , pipe=target_pipe_name
    , private_key=snowflake_connection_parameters["private_key"]
  )

  return snowpipe_ingest_manager

## Define function to build a snowpipe ingest manager
## leveraging environment variables
## containing Snowflake connection parameters
def build_snowpipe_ingest_manager_via_environment_variables(
    target_pipe_name : str = None
  ):

  from .leverage_snowflake_connection_parameters_dictionary import import_snowflake_connection_parameters_from_environment_variables

  snowflake_connection_parameters = import_snowflake_connection_parameters_from_environment_variables(private_key_output_format = 'snowpipe')

  snowpipe_ingest_manager = SimpleIngestManager(
      account=snowflake_connection_parameters["account"]
    , host=f'{snowflake_connection_parameters["account"]}.snowflakecomputing.com'
    , user=snowflake_connection_parameters["user"]
    , pipe=target_pipe_name
    , private_key=snowflake_connection_parameters["private_key"]
  )

  return snowpipe_ingest_manager
