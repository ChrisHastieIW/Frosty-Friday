# The Snowpark package is required for Python Worksheets. 
# You can add more packages by selecting them using the Packages control and then importing them.

# Frosty Friday Challenge
# Week 66 - Intermediate - Snowpark
# https://frostyfriday.org/blog/2023/10/06/week-66-intermediate/

## Import required packages
import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col
    
## Define main function
def main(session: snowpark.Session): 

    ### Define the variables we are using,
    ### which could be passed into this if
    ### we made a SProc instead.
    ### We use the fully qualified name (FQN)
    ### of the table for simplicity
    table_fqn = '"SNOWFLAKE"."ACCOUNT_USAGE"."TABLES"'

    ### Read the table into a Snowflake dataframe
    df_raw = session.table(table_fqn)

    ### Filter the dataframe to the desired values
    df_filtered = df_raw \
      .filter(col("IS_TRANSIENT") == "NO")\
      .filter(col("DELETED").isNull())\
      .filter(col("ROW_COUNT") > 0)

    ## Aggregate to the desired results
    df_agg = df_filtered.groupBy("TABLE_CATALOG") \
      .count() \
      .rename({
          col("TABLE_CATALOG"): "DATABASE"
        , col("COUNT"): "TABLES"
       })
    
    ### Return the final dataframe
    return df_agg
