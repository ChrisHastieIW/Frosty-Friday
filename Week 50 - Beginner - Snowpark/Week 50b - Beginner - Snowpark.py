# The Snowpark package is required for Python Worksheets. 
# You can add more packages by selecting them using the Packages control and then importing them.

# Frosty Friday Challenge
# Week 50 - Beginner - Snowpark
# https://frostyfriday.org/2023/06/16/week-50-beginner/

## Import required packages
import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col
import pandas as pd

## Define function to filter the values using Python
def filter_using_python(
      session: snowpark.Session
    , table_fqn: str
    , filter_column: str
    , filter_value: str
  ): 

    ### Convert the table into a dataframe 
    df_table = session.table(table_fqn)

    ### Filter the dataframe to the desired value
    df_filtered = df_table.filter(col(filter_column) == filter_value)

    ### The above can also be done in a single statement
    ### and we can use \ to spread over multiple lines
    df_filtered_alternative = session.table(table_fqn)\
      .filter(col(filter_column) == filter_value)
      
    ### Print the dataframe to standard output
    print('Filtered dataframe from Python:')
    df_filtered.show()
      
    ### Print the alternative dataframe to standard output
    print('Alternative filtered dataframe from Python:')
    df_filtered_alternative.show()

    ### Return the filtered dataframe
    return df_filtered

## Define function to filter the values using SQL
def filter_using_sql(
      session: snowpark.Session
    , table_fqn: str
    , filter_column: str
    , filter_value: str
  ): 

    ### Execute the query, using:
    ### - ''' for a multi-line string input,
    ### - f''' to allow the use of variables
    df_filtered = session.sql(f'''
        select *
        from {table_fqn}
        where "{filter_column}" = '{filter_value}'
      ''')
      
    ### Print the dataframe to standard output
    print('Filtered dataframe from SQL:')
    df_filtered.show()

    ### Return the filtered dataframe
    return df_filtered

## Define main function
def main(session: snowpark.Session): 

    ### Define the variables we are using,
    ### which could be passed into this if
    ### we made a SProc instead.
    ### We use the fully qualified name (FQN)
    ### of the table for simplicity
    table_fqn = '"CH_FROSTY_FRIDAY"."WEEK_50"."CHALLENGE_DATA"'
    filter_column = 'LAST_NAME'
    filter_value = 'Deery'

    ### Execute the function to filter using Python
    df_filtered_from_python = filter_using_python(
        session = session
      , table_fqn = table_fqn
      , filter_column = filter_column
      , filter_value = filter_value
    )

    ### Execute the function to filter using SQL
    df_filtered_from_sql = filter_using_sql(
        session = session
      , table_fqn = table_fqn
      , filter_column = filter_column
      , filter_value = filter_value
    )
    
    ### Return the filtered dataframe from Python
    ### as the overall result of the Python script
    return df_filtered_from_python
