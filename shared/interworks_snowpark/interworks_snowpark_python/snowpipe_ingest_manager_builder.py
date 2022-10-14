
# Build Snowpipe ingest manager for Snowflake

## Import snowpipe module
from snowflake.ingest import SimpleIngestManager
from snowflake.ingest import StagedFile

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

## Define function to trigger a snowpipe ingestion
def trigger_snowpipe_ingestion(
      snowpipe_ingest_manager: SimpleIngestManager
    , relative_file_path: str = None
  ):
  """
  Download dataframe from Azure Blob Storage for given url
  Keyword arguments:
  snowpipe_ingest_manager -- the snowpipe ingest manager object that connects to the destination Snowflake pipe
  relative_file_path -- the file path of the file to ingest within blob storage, relative to the Snowflake stage target directory (default None)

  eg: retrieve_snowpipe_ingest_manager(snowpipe_ingest_manager=my_snowpipe_ingest_manager, relative_file_path="my/target/file/path.csv.gz")
  """
  try:

    if all([snowpipe_ingest_manager]):
          
      staged_file_list = []
      staged_file_list.append(
        StagedFile(relative_file_path, None)  # file size is optional but recommended, pass None if not available
      )
      snowpipe_response = snowpipe_ingest_manager.ingest_files(staged_file_list)

      # This means Snowflake has received file and will start loading
      assert(snowpipe_response['responseCode'] == 'SUCCESS')

    else:
      raise ValueError('Aborting Snowpipe connnection as function input is missing')

  except Exception as e:
    raise ValueError(e)
