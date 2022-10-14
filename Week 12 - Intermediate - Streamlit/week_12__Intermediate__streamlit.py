
# Frosty Friday Challenge
# Week 12 - Intermediate - Streamlit
# https://frostyfriday.org/2022/09/02/week-12-intermediate/

## Import required modules
import streamlit
import pandas
from io import BytesIO 
from shared.interworks_snowpark.interworks_snowpark_python.snowpark_session_builder import build_snowpark_session_via_streamlit_secrets

## Build a snowpark session using Streamlit secrets
snowpark_session = build_snowpark_session_via_streamlit_secrets()

## Define a function to retrieve the data objects from Snowflake.
## According to https://docs.streamlit.io/library/get-started/main-concepts
## under "Caching", the decorator @streamlit.cache will cache the results of the function
@streamlit.cache 
def retrieve_data_objects() :

  ## Read tables from information schema into 
  ## a Snowflake dataframe then convert it into 
  ## a Pandas dataframe
  tables_df_sf = snowpark_session.sql('''
    SELECT DISTINCT 
        REPLACE(TABLE_SCHEMA, 'WEEK_12_') AS TABLE_SCHEMA
      , TABLE_NAME
    FROM CH_FROSTY_FRIDAY.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA ILIKE 'WEEK_12%'
    ORDER BY
        TABLE_SCHEMA
      , TABLE_NAME
  ''')
  tables_df_pd = tables_df_sf.to_pandas()

  schemas_df = tables_df_pd["TABLE_SCHEMA"].unique()

  return tables_df_pd, schemas_df

### Build the sidebar
def build_sidebar() :
  
  streamlit.sidebar.image('https://interworks.com/logo/logos/pngs/white/IWstacked.png')
  sidebar_text = '''# Instructions:
    - Select the schema from the available.
    - Then select the table which will automatically update to reflect your schema choice.
    - Check that the table corresponds to that which you want to ingest into.
    - Select the file you want to ingest.
    - You should see an upload success message detailing how many rows were ingested.
  '''
  for line in sidebar_text.split('\n') :
    streamlit.sidebar.write(line)

def upload_files(
      schema: str
    , table: str  
  ) :

  ### Create Streamlit file uploader object
  uploaded_files = streamlit.file_uploader(label = f"Select file to ingest into {schema}.{table}", type = ["csv"], accept_multiple_files = True)

  ### Write waiting message until files are uploaded
  if uploaded_files is None or len(uploaded_files) == 0 :
    streamlit.write("Awaiting file(s) to upload...")
  else :

    ### Iterate through uploaded files
    for uploaded_file in uploaded_files:
      try :
        #### Read the file into a Bytes object
        bytes_data = BytesIO(uploaded_file.getvalue())

        #### Read the bytes data into a pandas dataframe
        uploaded_df = pandas.read_csv(bytes_data, sep = ',', header = 0, quotechar = '"')

        #### Upload the data into the Snowflake table
        snowpark_session.write_pandas(
            df = uploaded_df
          , table_name = table
          , schema = f'WEEK_12_{schema}'
          , database = 'CH_FROSTY_FRIDAY'
          , quote_identifiers = False
        )

        #### Send the success message.
        streamlit.write(f'Your upload of file "{uploaded_file.name}" was a success. You uploaded {len(uploaded_df)} rows.')

      except Exception as e:
        streamlit.write(f'Error during upload of file "{uploaded_file.name}"\n\n{e}')

## Call the cached function retrieve_data_objects() to populate our variables
tables_df, schemas_df = retrieve_data_objects()

## Define a function for the streamlit app
def streamlit_app() :

  ### Build the sidebar
  build_sidebar()
  
  ### Write the title (apparently this supports Markdown!)
  streamlit.write('# Manual CSV to Snowflake Table Uploader')

  ### Build schema toggle
  schema_toggle = streamlit.radio(label = 'Select schema:', options = schemas_df)

  ### Define filter tables dataframe
  ### using schema toggle selection
  filtered_tables_df = tables_df[tables_df["TABLE_SCHEMA"] == schema_toggle]["TABLE_NAME"]

  ### Build table toggle
  table_toggle = streamlit.radio(label = 'Select table to upload to:', options = filtered_tables_df)

  ### Upload files
  upload_files(schema = schema_toggle, table = table_toggle)

## Call the function for the streamlit app
streamlit_app()