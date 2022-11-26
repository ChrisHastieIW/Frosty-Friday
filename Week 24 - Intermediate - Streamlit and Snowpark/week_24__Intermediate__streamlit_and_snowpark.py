
# Frosty Friday Challenge
# Week 24 - Intermediate - Streamlit and Snowpark
# https://frostyfriday.org/2022/11/25/week-24-intermediate/

## Import required modules
import streamlit
import pandas
from shared.interworks_snowpark.interworks_snowpark_python.snowpark_session_builder import build_snowpark_session_via_streamlit_secrets
import snowflake.snowpark

## Build a snowpark session using Streamlit secrets
snowpark_session = build_snowpark_session_via_streamlit_secrets()

## Define function to execute a SHOW command in Snowflake
def execute_show_command(object_type: str) :

  ### Return nothing if object type is "None",
  ### otherwise execute SHOW command
  if object_type == "None" :
    df_show_results = pandas.DataFrame()

  elif object_type == "Grants" :
    #### Execute the SHOW command for the object into
    #### a Snowflake dataframe then convert it into 
    #### a Pandas dataframe
    sf_df_show_results = snowpark_session.sql(f'''
        SHOW {object_type.upper()} ON ACCOUNT 
      ''')
    df_show_results = pandas.DataFrame(data=sf_df_show_results.collect())

  else:
    #### Execute the SHOW command for the object into
    #### a Snowflake dataframe then convert it into 
    #### a Pandas dataframe
    sf_df_show_results = snowpark_session.sql(f'''
        SHOW {object_type.upper()} IN ACCOUNT 
      ''')
    df_show_results = pandas.DataFrame(data=sf_df_show_results.collect())

  ### Only return results if resultset is not empty
  if len(df_show_results) > 0 :
    return df_show_results
  else :
    return ''

## Build the sidebar
def build_sidebar() :
  
  ### Insert header image
  streamlit.sidebar.image('https://interworks.com/logo/logos/pngs/white/IWstacked.png')

  ### Define list of object types for dropdown
  object_types = ["None", "Shares", "Roles", "Grants", "Users", "Warehouses", "Databases", "Schemas", "Tables", "Views"]

  ### Build the dropdown box for object types
  selected_object_type = streamlit.sidebar.selectbox(
      label = 'Select which account info you would like to see'
    , options = object_types
  )

  ### Pad sidebar (cheat as I can't figure out how to make footer text)
  for x in range(len(object_types)*2):
    streamlit.sidebar.write('')

  ### Insert footer text
  streamlit.sidebar.write(f"App created using Snowpark version {snowflake.snowpark.__version__}")
  streamlit.sidebar.write(f"App created using streamlit version {streamlit.__version__}")

  return selected_object_type

## Define a function for the streamlit app
def streamlit_app() :

  ### Build the sidebar
  selected_object_type = build_sidebar()
  
  ### Write the title and text
  streamlit.title('# Snowflake Account Info App')
  streamlit.write('Use this app to quickly see high-level info about your Snowflake account')

  ### Execute the relevant SHOW command in Snowflake
  df_show_results = execute_show_command(selected_object_type)

  ### Write the SHOW results into streamlit
  streamlit.write(df_show_results)

## Call the function for the streamlit app
streamlit_app()