
# Frosty Friday Challenge
# 43 - Intermediate - JSON & Python Worksheets
# https://frostyfriday.org/2023/04/14/week-41-basic/

## Import Snowpark module
from snowflake.snowpark import Session as snowpark_session
from snowflake.snowpark.functions import col
from snowflake.snowpark.types import StringType, IntegerType

## Define handler function
def main(snowflake_session: snowpark_session):

    table_challenge_input = '"WEEK_43"."CHALLENGE_INPUT"'

    ### Retrieve challenge input
    sf_df_challenge_input = snowflake_session.table(table_challenge_input)

    ### Flatten the input's JSON value
    ### into an output dataframe, retrieving
    ### and type-casting the desired fields
    ### before finally aliasing them
    sf_df_challenge_output = sf_df_challenge_input\
      .join_table_function(
          "flatten"
        , col("JSON").__getitem__("superheroes")
      )\
      .select(
          col("VALUE").__getitem__("id").cast(IntegerType()).alias("ID")
        , col("JSON").__getitem__("company_name").cast(StringType()).alias("COMPANY_NAME")
        , col("JSON").__getitem__("company_website").cast(StringType()).alias("COMPANY_WEBSITE")
        , col("JSON").__getitem__("location").__getitem__("address").cast(StringType()).alias("ADDRESS")
        , col("JSON").__getitem__("location").__getitem__("city").cast(StringType()).alias("CITY")
        , col("JSON").__getitem__("location").__getitem__("country").cast(StringType()).alias("COUNTRY")
        , col("JSON").__getitem__("location").__getitem__("state").cast(StringType()).alias("STATE")
        , col("JSON").__getitem__("location").__getitem__("zip").cast(StringType()).alias("ZIP")
        , col("VALUE").__getitem__("name").cast(StringType()).alias("NAME")
        , col("VALUE").__getitem__("powers").alias("POWERS")
        , col("VALUE").__getitem__("real_name").cast(StringType()).alias("REAL_NAME")
        , col("VALUE").__getitem__("role").cast(StringType()).alias("ROLE")
        , col("VALUE").__getitem__("years_of_experience").cast(IntegerType()).alias("YEARS_OF_EXPERIENCE")
      )

    ### Show the output in the Python output log
    sf_df_challenge_output.show()
    
    ### Return the output
    return sf_df_challenge_output