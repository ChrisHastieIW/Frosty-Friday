
-- Frosty Friday Challenge
-- Week 28 - Intermediate - Marketplace and Ranking
-- https://frostyfriday.org/2023/01/06/week-28-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_28;

use schema WEEK_28;

-------------------------------
-- Create challenge view

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
with covid_data as (
  select distinct "COUNTRY_REGION", "DATE"
  from starschema_covid19.public.ecdc_global
  where last_reported_flag
)
select
    "Country Name" as "COUNTRY"
  , "Date" as "DATE"
  , "Indicator Name"
  , max("Value") as "Value"
from share_daily_weather_data.kndwd_data_pack.noaacd2019r as weather
where "Indicator Name" = 'Mean temperature (Fahrenheit)'
  and exists (
      select 1
      from covid_data
      where covid_data."COUNTRY_REGION" = weather."Country Name"
        and covid_data."DATE" = weather."Date"
    )
group by
    "Country Name"
  , "Date"
  , "Indicator Name"
  , "Stations Name"
qualify 
  rank() over (
    partition by "Country Name", "Date", "Indicator Name" 
    order by "Stations Name" desc
  ) = 1
order by "Country Name" asc
;

-- Query the view
select * from CHALLENGE_OUTPUT;
