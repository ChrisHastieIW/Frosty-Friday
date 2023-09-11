
# Streamlit interface for the application

## Import required modules
import streamlit as st

## Retrieve the active Snowpark session.
## This only works when executed from
## within an existing session, such as
## during the execution of a native app

## Define a function for the streamlit app
def streamlit_app() :
  
  ### Write the text
  st.title(':snowflake: Hello World! :snowflake:')

## Call the function for the streamlit app
streamlit_app()