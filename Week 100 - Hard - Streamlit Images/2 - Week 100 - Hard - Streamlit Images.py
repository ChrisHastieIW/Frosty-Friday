
# Frosty Friday Challenge
# Week 100 - Hard - Streamlit Images
# https://frostyfriday.org/blog/2024/07/05/week-100-hard/

# First be sure to complete the SQL component to create the table!
# You could do this as part of the streamlit and do the ingestion
# there, but that would involve external access for the Streamlit
# which feels overly complex for this specific challenge.

## Import Streamlit and Snowflake packages
import streamlit as st
from snowflake.snowpark.context import get_active_session

## Title and intro
st.title("Frosty Friday Week 100! :balloon:")
st.write(
  """The original challenge can be found [here](https://frostyfriday.org/blog/2024/07/05/week-100-hard/).

  I've had a lot of fun with Frosty Fridays over the last 2 years and look forward to continuing!
  """
)

## Retrieve the current session
snowflake_session = get_active_session()

## Retrieve the hex-encoded images from the table,
## retrieving the data into a Pandas dataframe
df_images = snowflake_session.table('"IMAGES"').to_pandas()

## Iterate over the rows in the table to print
## the image into the Streamlit canvas,
## using list comprehension for concurrency
st.image(
    image = [
      bytes.fromhex(image_bytes)
      for image_bytes in df_images["IMAGE_BYTES"]
    ]
  , caption = [
      f'''Another gorgeous pet, from file {file_name}'''
      for file_name in df_images["FILE_NAME"]
    ]
)
