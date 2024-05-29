
-- Frosty Friday Challenge
-- Week 93 - Advanced - External Access
-- https://frostyfriday.org/blog/2024/05/10/week-93-advanced/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_93;

use schema WEEK_93;

-------------------------------
-- Challenge Setup Script

use role ACCOUNTADMIN;

create or replace network rule "EGRESS__FF_93__TREASURY"
  type = HOST_PORT
  mode = EGRESS
  value_list = ('api.fiscaldata.treasury.gov')
  comment = 'Allows traffic to be sent to the API for treasury fiscal data'
;

create or replace external access integration "EAI__FF_93__TREASURY"
  allowed_network_rules = ("EGRESS__FF_93__TREASURY")
  enabled = TRUE
  comment = 'External access integration to support traffic sent to the API for treasury fiscal data'
;

grant usage on integration "EAI__FF_93__TREASURY" to role <my_role>;

use role <my_role>;

create or replace table TREASURY_DATA (
    AVG_INTEREST_RATE_AMT float
  , RECORD_DATE date
  , SECURITY_DESC string
  , SECURITY_TYPE_DESC string
  , SRC_LINE_NBR string
  , API_CALL_START_DATE date
  , API_CALL_END_DATE date
)
;

-------------------------------
-- Challenge Solution

-- Create stored procedure
create or replace procedure "API__FF_93__TREASURY__RETRIEVE_DATA"(
      START_DATE date
    , END_DATE date
  )
  copy grants
  returns variant
  language python
  runtime_version = 3.10
  handler = 'main'
  external_access_integrations = ("EAI__FF_93__TREASURY")
  packages = ('snowflake-snowpark-python', 'requests')
as
$$

## Import module for inbound Snowflake session
from snowflake.snowpark import Session as snowparkSession

## Imports
import _snowflake
import requests
import json
import datetime
import pandas as pd

## Define function to query
## the API.
## Returns an error flag
## and the response JSON
def query_api(
      api_endpoint_url: str
    , page_link: str = ""
  ):
  
  ### Execute API call to trigger job
  response = requests.request("GET", api_endpoint_url+page_link)

  try:
    if response.status_code == 200 :
      return False, response
    else :
      return True, response
  except Exception:
    return True, response
  
## Define function to insert
## records into target table
def insert_into_table(
      snowpark_session: snowparkSession
    , data_as_json: list
    , start_date: datetime.date
    , end_date: datetime.date
  ):
  df_treasury = pd.json_normalize(data_as_json)

  df_treasury.rename(
      columns={
          "avg_interest_rate_amt": "AVG_INTEREST_RATE_AMT"
        , "record_date": "RECORD_DATE"
        , "security_desc": "SECURITY_DESC"
        , "security_type_desc": "SECURITY_TYPE_DESC"
        , "src_line_nbr": "SRC_LINE_NBR"
      }
    , inplace = True
  )

  df_treasury["API_CALL_START_DATE"] = start_date
  df_treasury["API_CALL_END_DATE"] = end_date

  snowpark_session.write_pandas(df_treasury, "TREASURY_DATA")
  
## Define main function
def main(
      snowpark_session: snowparkSession
    , start_date: datetime.date
    , end_date: datetime.date
  ):

  ### Validate inputs
  if start_date is None \
    or end_date is None \
      :
    return "Missing inputs. Must provide all of start_date, end_date"

  ### Convert dates to strings
  start_date_as_string = start_date.strftime('%Y-%m-%d')
  end_date_as_string = end_date.strftime('%Y-%m-%d')

  ### Generate URL to retrieve all projects
  api_endpoint_url = f"https://api.fiscaldata.treasury.gov/services/api/fiscal_service//v2/accounting/od/avg_interest_rates?fields=record_date,security_type_desc,security_desc,avg_interest_rate_amt,src_line_nbr&filter=record_date:gte:{start_date_as_string},record_date:lt:{end_date_as_string}"

  next_page_link = ""
  
  while next_page_link is not None:
  
    ### Execute API call
    error_flag, response = query_api(
          api_endpoint_url = api_endpoint_url
        , page_link = next_page_link
      )

    if error_flag == True:
      return {
            "error_flag": error_flag
          , "response": response
        }
    
    ### Insert page into table
    insert_into_table(
        snowpark_session = snowpark_session
      , data_as_json = response.json()["data"]
      , start_date = start_date
      , end_date = end_date
    )

    next_page_link = response.json()["links"]["next"]

  return {
        "error_flag": False
      , "response": "Complete"
    }

$$
;

-- Test query
call "API__FF_93__TREASURY__RETRIEVE_DATA"(
    '2020-01-01'::date
  , '2024-04-30'::date
)
;

select * from "TREASURY_DATA";
