
# Streamlit interface for the application

## Import required modules
import streamlit as st
from snowflake.snowpark.context import get_active_session

## Retrieve the active Snowpark session.
## This only works when executed from
## within an existing session, such as
## during the execution of a native app

## Define a function for the streamlit app
def streamlit_app() :
  
  ### Write the text
  st.title('Spanish Speaking Countries by Population')

  ### Get the currently active Snowpark session
  session = get_active_session()

  ### Query the view as a Snowflake dataframe
  sf_df_data = session.sql(''' select * from "APP_DATA"."CHALLENGE_DATA" ''')

  ### Execute the query and convert it into a Pandas dataframe
  df_data = sf_df_data.to_pandas()

  ### Display the Pandas dataframe as a Streamlit dataframe
  # st.dataframe(df_data, use_container_width=True)
  
  ### Display the Pandas dataframe as a Streamlit bar chart
  st.bar_chart(data=df_data, x="COUNTRY", y="POPULATION_2023")

## Call the function for the streamlit app
streamlit_app()