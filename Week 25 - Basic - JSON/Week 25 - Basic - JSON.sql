
-- Frosty Friday Challenge
-- Week 25 - Basic - JSON
-- https://frostyfriday.org/2022/11/30/week-25-beginner/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_25;

use schema WEEK_25;

-------------------------------
-- Create stage

create or replace stage STG_WEEK_25
  URL = 's3://frostyfridaychallenges/challenge_25/'
;

-- View files in stage
list @STG_WEEK_25;

-------------------------------
-- Ingest raw data

-- Create empty table
CREATE OR REPLACE TABLE WEATHER_RAW (
    raw_json variant
)
;

-- Populate with values
copy into WEATHER_RAW
from @STG_WEEK_25
file_format = (type='JSON')
;

-- Investigate raw data
select * from WEATHER_RAW;

select
  *
from WEATHER_RAW
  , lateral flatten (raw_json)
;

-- distinct keys at different levels
select distinct key
from WEATHER_RAW
  , lateral flatten (raw_json)
;

select distinct sources_2.key
from WEATHER_RAW
  , lateral flatten (raw_json:sources) as sources
  , lateral flatten (sources.value) as sources_2
;

select distinct weather_2.key
from WEATHER_RAW
  , lateral flatten (raw_json:weather) as weather
  , lateral flatten (weather.value) as weather_2
;


-------------------------------
-- Parsed views

-- Create the view of sources
create or replace view SOURCES_PARSED
as
select
    sources.value:distance as distance
  , sources.value:dwd_station_id::string as dwd_station_id
  , sources.value:first_record::timestamp as first_record
  , sources.value:height as height
  , sources.value:id as id
  , sources.value:last_record::timestamp as last_record
  , sources.value:lat as lat
  , sources.value:observation_type::string as observation_type
  , sources.value:lon as lon
  , sources.value:station_name::string as station_name
  , sources.value:wmo_station_id::string as wmo_station_id
from WEATHER_RAW
  , lateral flatten (raw_json:sources) as sources
;

-- Create the view for weather
create or replace view WEATHER_PARSED
as
select
    weather.value:cloud_cover as cloud_cover
  , weather.value:condition::string as condition
  , weather.value:dew_point as dew_point
  , weather.value:icon::string as icon
  , weather.value:precipitation as precipitation
  , weather.value:source_id as source_id
  , weather.value:sunshine as sunshine
  , weather.value:timestamp::timestamp as timestamp
  , weather.value:wind_direction as wind_direction
  , weather.value:wind_gust_direction as wind_gust_direction
  , weather.value:wind_gust_speed as wind_gust_speed
  , weather.value:fallback_source_ids as fallback_source_ids
  , weather.value:pressure_msl as pressure_msl
  , weather.value:visibility as visibility
  , weather.value:temperature as temperature
  , weather.value:wind_speed as wind_speed
  , weather.value:relative_humidity as relative_humidity
from WEATHER_RAW
  , lateral flatten (raw_json:weather) as weather
;

-- Query the views
select * from SOURCES_PARSED;
select * from WEATHER_PARSED;


-------------------------------
-- Aggregate views

-- Create the aggregated view for weather
create or replace view WEATHER_AGG
as
select
    date_trunc('day', timestamp) as date
  , array_agg(distinct icon) as icon_array
  , avg(temperature) as avg_temperature
  , sum(precipitation) as total_precipitation
  , avg(wind_speed) as avg_wind
  , avg(relative_humidity) as avg_humidity
from WEATHER_PARSED
group by
    date
;

-- Query the view
select * from WEATHER_AGG;