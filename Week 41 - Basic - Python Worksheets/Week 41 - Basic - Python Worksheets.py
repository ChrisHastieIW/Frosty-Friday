
# Frosty Friday Challenge
# Week 41 - Basic - Python Worksheets
# https://frostyfriday.org/2023/04/14/week-41-basic/

## Import Snowpark module
import snowflake.snowpark as snowpark

## Define handler function
def main(session: snowpark.Session): 

    ### Define individual statements to return
    statement_1 = "We love Frosty Friday"
    statement_2 = "Python worksheets are cool"

    ### Lazy way to create the list of tuples
    ### since we know each statement has the
    ### same number of words
    statement_tuples = tuple(zip(
          statement_1.split(" ")
        , statement_2.split(" ")
      ))

    ### Feed statements into a Snowflake dataframe
    dataframe = session.create_dataframe(
          statement_tuples
        , schema=["STATEMENT1", "STATEMENT2"]
      )

    ### Return value will appear in the Results tab.
    return dataframe