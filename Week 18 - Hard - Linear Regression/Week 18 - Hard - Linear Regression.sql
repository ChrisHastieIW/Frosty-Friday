
-- Frosty Friday Challenge
-- Week 18 - Hard - Linear Regression
-- https://frostyfriday.org/2022/10/14/week-18-linear-regression/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_18;

use schema WEEK_18;

-------------------------------
-- Investigate Challenge Data

-- Sample the data
SELECT "Date", "Value"
FROM "SHARE_ECONOMY_DATA_ATLAS"."ECONOMY"."BEANIPA"
WHERE "Table Name" = 'Price Indexes For Personal Consumption Expenditures By Major Type Of Product'
  AND "Indicator Name" = 'Personal consumption expenditures (PCE)'
  AND "Frequency" = 'A'
ORDER BY "Date"
;

------------------------------------------------------------------
-- Create the UDTF

CREATE OR REPLACE FUNCTION GENERATE_LINEAR_REGRESSION_PREDICTIONS (
      INPUT_YEAR INT
    , INPUT_MEASURE FLOAT
    , INPUT_PERIODS_TO_FORECAST INT  
  )
  returns TABLE (
        YEAR INT
      , TYPE TEXT
      , MEASURE FLOAT
    )
  language python
  runtime_version = '3.8'
  packages = ('pandas', 'scikit-learn')
  handler = 'generate_linear_regression_predictions'
as
$$

# Import modules
import pandas
from sklearn.linear_model import LinearRegression
from datetime import date

# Define handler class
class generate_linear_regression_predictions :

  ## Define __init__ method that acts
  ## on full partition before rows are processed
  def __init__(self) :
    # Create empty list to store inputs
    self._data = []
  
  ## Define process method that acts
  ## on each individual input row
  def process(
        self
      , input_year: date
      , input_measure: float
      , input_periods_to_forecast: int
    ) :

    # Ingest rows into pandas DataFrame
    data = [input_year, 'ACTUAL', input_measure]
    self._data.append(data)
    self._periods_to_forecast = input_periods_to_forecast

  ## Define end_partition method that acts
  ## on full partition after rows are processed
  def end_partition(self) :

    # Convert inputs to DataFrame
    df_input = pandas.DataFrame(data=self._data, columns=["YEAR", "TYPE", "MEASURE"])

    # Determine inputs for linear regression model
    # x = pandas.DatetimeIndex(df_input["DATE"]).year.to_numpy().reshape(-1, 1)
    x = df_input["YEAR"].to_numpy().reshape(-1, 1)
    y = df_input["MEASURE"].to_numpy()

    # Create linear regression model
    model = LinearRegression().fit(x, y)

    # Determine forecast range
    periods_to_forecast = self._periods_to_forecast
    # Leverage list comprehension to generate desired years
    list_of_years_to_predict = [df_input["YEAR"].iloc[-1] + x + 1 for x in range(periods_to_forecast)]
    
    prediction_input = [[x] for x in list_of_years_to_predict]
    
    # Generate predictions and create a df
    predicted_values = model.predict(prediction_input)
    predicted_values_formatted = pandas.to_numeric(predicted_values).round(2).astype(float)
    df_predictions = pandas.DataFrame(
        data=predicted_values_formatted
      , columns=["MEASURE"]
    )

    # Create df for prediction year
    df_prediction_years = pandas.DataFrame(
        data=list_of_years_to_predict
      , columns=["YEAR"]
    )

    # Create df for prediction type
    prediction_type_list = ["PREDICTION" for x in list_of_years_to_predict]
    df_prediction_type = pandas.DataFrame(
        data=prediction_type_list
      , columns=["TYPE"]
    )

    # Combine predicted dfs into single df
    df_predictions_combined = pandas.concat([df_prediction_years, df_prediction_type, df_predictions], axis = 1) \
      [["YEAR", "TYPE", "MEASURE"]]

    # Adjust test index to align with
    # the end of the training data
    df_predictions.index += len(df_input)

    # Combine predicted values with original
    df_output = pandas.concat([df_input, df_predictions_combined], axis = 0) \
      [["YEAR", "TYPE", "MEASURE"]]

    # Output the result
    return list(df_output.itertuples(index=False, name=None))

    '''
    Alternatively, the output could be returned
    by iterating through the rows and yielding them
    for index, row in df_output.iterrows() :
      yield(row[0], row[1], row[2], row[3])
    '''

$$
;

------------------------------------------------------------------
-- Testing

-- Use CTE to reduce input data then query the UDTF
with input as (
  SELECT 
      'Forced' as PARTITION
    , YEAR("Date") AS "Year"
    , "Value" as "PCE"
  FROM "SHARE_ECONOMY_DATA_ATLAS"."ECONOMY"."BEANIPA"
  WHERE "Table Name" = 'Price Indexes For Personal Consumption Expenditures By Major Type Of Product'
    AND "Indicator Name" = 'Personal consumption expenditures (PCE)'
    AND "Frequency" = 'A'
    AND "Date" >= '1972-01-01'
    AND "Date" < '2021-01-01' 
  ORDER BY "Date" ASC
)
select
    "YEAR"
  , "TYPE"
  , "MEASURE"
from input
  , table(
      GENERATE_LINEAR_REGRESSION_PREDICTIONS("Year", "PCE", 5) 
      over (
        partition by "PARTITION"
        order by "Year" asc
      )
    )
where "YEAR" >= 2015 -- Only interested in final records
;

------------------------------------------------------------------
-- Not seeing challenge values

/*
The challenge expects a 2021 value of 116.23 for this prediction, whilst I see a value of 116.22.

Comparing the results and values with the original Snowflake Quick Starts code
https://github.com/Snowflake-Labs/sfquickstarts/blob/master/site/sfguides/src/data_apps_summit_lab/assets/project_files/my_snowpark_pce.ipynb
it appears the original data itself has changed in very small volumes.
For example, the actual value for 2019 is now 109.933 when it used to be 109.922

I believe this means my solution is correct and the input data itself has simply changed since the challenge was encoded.
*/