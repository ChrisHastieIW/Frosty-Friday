
-- Frosty Friday Challenge
-- Week 97 - Intermediate - Cortex Top_Insights
-- https://frostyfriday.org/blog/2024/05/31/cortex-intermediate/

-------------------------------
-- Environment Configuration

use database "CH_FROSTY_FRIDAY";

use warehouse "WH_CHASTIE";

create or replace schema "WEEK_97";

use schema "WEEK_97";

-------------------------------
-- Challenge Setup Script

-- Create a table named EMPLOYEES
create or replace table "EMPLOYEES" (
    "EMPLOYEE_ID" int autoincrement
  , "LEVEL" varchar(2) default 'L1'
  , "MANAGER_ID" int
  , "BASE_SALARY" int
  , "TIME_WTIH_COMPANY" int
  , "MEASUREMENT_DATE" date
)
;

-- Populate table 1
insert into "EMPLOYEES" ("MANAGER_ID", "BASE_SALARY", "TIME_WTIH_COMPANY", "MEASUREMENT_DATE")
with "CTE__EMPLOYEE_DATA_GENERATOR" as (
  select
      uniform(1, 20, random()) as "MANAGER_ID"
    , case
        when random() < 0.3
          then uniform(3500, 4499, random())
          else uniform(4500, 5500, random())
      end as "BASE_SALARY"
    , uniform(6, 20, random()) as "TIME_WTIH_COMPANY"
    , date_from_parts(2024, 1, 1) as "MEASUREMENT_DATE"
  from table(generator(ROWCOUNT => 1000))
)
select * from "CTE__EMPLOYEE_DATA_GENERATOR"
;

-- Populate table 2
insert into "EMPLOYEES" ("MANAGER_ID", "BASE_SALARY", "TIME_WTIH_COMPANY", "MEASUREMENT_DATE")
with "CTE__MANAGERS" as (
  select
      seq4() as "MANAGER_ID"
    , case
        when seq4() in (10)
          then 'high_negative'
          else 'high_positive'
      end as "IMPACT"
  from table(generator(ROWCOUNT => 20))
)
, "CTE__EMPLOYEE_DATA" as (
    select
        m."MANAGER_ID" as "MANAGER_ID"
      , case
          when RANDOM() < 0.3
            then uniform(4000, 4999, random())
            else uniform(5000, 6000, random())
        end as "BASE_SALARY"
      , case
          WHEN m.impact = 'high_negative'
            then uniform(1, 5, random())
            else uniform(6, 20, random())
        end as "TIME_WTIH_COMPANY"
      , date_from_parts(2024, 10, 10) as "MEASUREMENT_DATE" 
    from table(generator(ROWCOUNT => 1000))
      cross join "CTE__MANAGERS" as m
    order by random()
)
select * from "CTE__EMPLOYEE_DATA"
;

-- Review the table
select * from "EMPLOYEES";

-------------------------------
-- Challenge Solution

with "CTE__INPUTS" as (
  select
      {
        'manager_id': "MANAGER_ID"
      }
      as "CATEGORICAL_DIMENSIONS"
    , {
        -- Base salary can be included or excluded,
        -- and the end result will still highlight
        -- manager 10 as an issue regardless
        'base_salary': "BASE_SALARY"
      }
      as "CONTINUOUS_DIMENSIONS"
    , "TIME_WTIH_COMPANY" as "METRIC"
    , "MEASUREMENT_DATE" >= '2024-10-10' AS "LABEL"
  from "EMPLOYEES"
)
select "TOP_INSIGHTS_OUTPUT".*
from "CTE__INPUTS"
  , table("SNOWFLAKE"."ML"."TOP_INSIGHTS"(
        "CTE__INPUTS"."CATEGORICAL_DIMENSIONS"
      , "CTE__INPUTS"."CONTINUOUS_DIMENSIONS"
      , cast("CTE__INPUTS"."METRIC" as float)
      , "CTE__INPUTS"."LABEL"
    )
    over (partition by 0) -- Tricky line taken from docs example
  ) as "TOP_INSIGHTS_OUTPUT"
-- Optional where clause to tidy up the output
where not "TOP_INSIGHTS_OUTPUT"."MISSING_IN_TEST"
order by "TOP_INSIGHTS_OUTPUT"."SURPRISE" asc
;
