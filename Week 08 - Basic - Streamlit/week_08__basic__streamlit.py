
# Frosty Friday Challenge
# Week 8 - Basic - Streamlit
# https://frostyfriday.org/2022/08/05/week-8-basic/

## Import required modules
import streamlit as st
import pandas as pd
from shared.interworks_snowpark.interworks_snowpark_python.snowpark_session_builder import build_snowpark_session_via_streamlit_secrets

## Define a function to retrieve the data objects from Snowflake.
## According to https://docs.st.io/library/get-started/main-concepts
## under "Caching", the decorator @st.cache will cache the results of the function
@st.cache 
def retrieve_data_objects() :
  ## Build a snowpark session using Streamlit secrets
  snowpark_session = build_snowpark_session_via_streamlit_secrets()

  ## Read payments table into a Snowflake dataframe
  ## then convert it into a Pandas dataframe
  payments_df_sf = snowpark_session.sql('''
    SELECT 
        PAYMENT_DATE::date as "Payment Date"
      , DATE_TRUNC('week', PAYMENT_DATE)::date as "Payment Week"
      , CARD_TYPE as "Card Type"
      , AMOUNT_SPENT as "Amount Spent"
    FROM CH_FROSTY_FRIDAY.WEEK_8.PAYMENTS
    WHERE YEAR(PAYMENT_DATE) = 2021
  ''')
  payments_df_pd = payments_df_sf.to_pandas()

  ## Frustratingly, it appears that we must convert the date field
  ## into a date object. I have attempted using .infer_objects()
  ## and this also thinks the date field is a string
  payments_df_pd["Payment Date"] = pd.to_datetime(payments_df_pd["Payment Date"], yearfirst=True).dt.date
  payments_df_pd["Payment Week"] = pd.to_datetime(payments_df_pd["Payment Week"], yearfirst=True).dt.date

  ### Note: If we wanted all fields we could have captured the whole table:
  ### payments_df_sf = snowpark_session.table('CH_FROSTY_FRIDAY.WEEK_8.PAYMENTS')

  ## Extract the min and max payment weeks
  min_payment_week = payments_df_pd["Payment Week"].min()
  max_payment_week = payments_df_pd["Payment Week"].max()

  ## Extract the distinct card types
  # card_types = ['All'].extend(payments_df_pd["Card Type"].unique())
  # card_types = payments_df_pd["Card Type"].unique()
  card_types = ["All"] + sorted(list(payments_df_pd["Card Type"].unique()))

  return payments_df_pd, min_payment_week, max_payment_week, card_types

## Call the cached function retrieve_data_objects() to populate our variables
payments_df, min_payment_week, max_payment_week, card_types = retrieve_data_objects()

## Define a function for the streamlit app
def streamlit_app() :

  ### Write a title (apparently this supports Markdown!)
  st.write('# Payments in 2021')

  ### Build the sliders for min and max payment date
  selected_min_payment_week = st.sidebar.slider(
      label = 'Select minimum payment week'
    , min_value = min_payment_week
    , max_value = max_payment_week
    , value = min_payment_week
  )
  selected_max_payment_week = st.sidebar.slider(
      label = 'Select maximum payment week'
    , min_value = min_payment_week
    , max_value = max_payment_week
    , value = max_payment_week
  )

  ### Built date filter
  date_filter = payments_df["Payment Date"].between(selected_min_payment_week, selected_max_payment_week, inclusive="both") 
  
  ### Build the dropdown box for card types
  selected_card_type = st.sidebar.selectbox(
      label = 'Select a card type'
    , options = card_types
  )

  ### Built card type filter
  card_type_filter = ((selected_card_type == "All") | (payments_df["Card Type"] == selected_card_type))

  ### Apply filters to the dataframe
  filtered_payments_df = payments_df[date_filter & card_type_filter]

  ### Group the filtered dataframe for the line chart
  grouped_filtered_payments_df = filtered_payments_df.groupby(["Payment Week"])["Amount Spent"].sum()

  ### Optional - Write table for validation
  # st.write(filtered_payments_df)
  
  ### Draw the line chart
  st.line_chart(grouped_filtered_payments_df)

## Call the function for the streamlit app
streamlit_app()