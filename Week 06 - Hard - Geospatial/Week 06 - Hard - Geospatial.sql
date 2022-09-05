
-- Frosty Friday Challenge
-- Week 6 - Hard - Geospatial
-- https://frostyfriday.org/2022/07/22/week-6-hard/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_6;

use schema WEEK_6;

-------------------------------
-- Create internal stage

create or replace stage STG_WEEK_6
;

-- View files in stage
list @STG_WEEK_6;

-- This is empty to start, so we
-- need to upload our two input
-- file into this stage. This is achieved
-- with the following commands in a local
-- SnowSQL console:
/* --snowsql
snowsql -a my.account -u my_user -r my_role --private-key-path "path\to\my\ssh\key.p8"
PUT 'FILE://C:/My/Path/To/nations_and_regions.csv' @CH_FROSTY_FRIDAY.WEEK_6.STG_WEEK_6;
PUT 'FILE://C:/My/Path/To/westminster_constituency_points.csv' @CH_FROSTY_FRIDAY.WEEK_6.STG_WEEK_6;
*/

-- View files in stage
list @STG_WEEK_6;

-------------------------------
-- Investigate files in stage

-- Create a simple file format that will 
-- ingest the full data into a single 
-- field for simple understanding
create or replace file format FF_SINGLE_FIELD
    type = CSV
    field_delimiter = NONE
    record_delimiter = NONE
    skip_header = 0 
;

-- Query the data using the single field
-- file format to understand the contents
select 
    METADATA$FILENAME::STRING as FILE_NAME
  , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
  , $1::VARIANT as CONTENTS
from @STG_WEEK_6
  (file_format => 'FF_SINGLE_FIELD')
order by 
    FILE_NAME
  , ROW_NUMBER
;

-- Both files seems to match the same format.
-- We can ingest the files with the same standard
-- csv file format


-------------------------------
-- Ingest the files into a table

-- Create the appropriate file format
create or replace file format FF_CSV_INGESTION
    type = CSV
    field_delimiter = ','
    record_delimiter = '\n'
    field_optionally_enclosed_by = '"' -- Had to add this after westminster_constituency_points originally failed to ingest
    skip_header = 1
;

-----------------------
-- Nations and Regions

-- Create a table in which to land the data
create or replace table NATIONS_AND_REGIONS (
    FILE_NAME STRING
  , ROW_NUMBER INT
  , NATION_OR_REGION_NAME STRING
  , TYPE STRING
  , SEQUENCE_NUM INT
  , LONGITUDE FLOAT
  , LATITUDE FLOAT
  , PART INT
)
;

-- Ingest the data
COPY INTO NATIONS_AND_REGIONS
FROM (
  select 
      METADATA$FILENAME::STRING as FILE_NAME
    , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
    , $1::string as NATION_OR_REGION_NAME
    , $2::string as TYPE
    , $3::int as SEQUENCE_NUM
    , $4::float as LONGITUDE
    , $5::float as LATITUDE
    , $6::int as PART
  from @STG_WEEK_6/nations_and_regions
    (file_format => 'FF_CSV_INGESTION')
)
;

-- Query the results
SELECT *
FROM NATIONS_AND_REGIONS
WHERE NATION_OR_REGION_NAME = 'East Midlands'
ORDER BY 
    FILE_NAME
  , ROW_NUMBER
;


-----------------------
-- Westminster Constituencies

-- Create a table in which to land the data
create or replace table WESTMINSTER_CONSTITUENCY_POINTS (
    FILE_NAME STRING
  , ROW_NUMBER INT
  , CONSTITUENCY STRING
  , POINT_SEQUENCE_NUM INT
  , LONGITUDE FLOAT
  , LATITUDE FLOAT
  , PART INT
)
;

-- Ingest the data
COPY INTO WESTMINSTER_CONSTITUENCY_POINTS
FROM (
  select 
      METADATA$FILENAME::STRING as FILE_NAME
    , METADATA$FILE_ROW_NUMBER as ROW_NUMBER
    , $1::string as CONSTITUENCY
    , $2::int as POINT_SEQUENCE_NUM
    , $3::float as LONGITUDE
    , $4::float as LATITUDE
    , $5::int as PART
  from @STG_WEEK_6/westminster_constituency_points
    (file_format => 'FF_CSV_INGESTION')
)
;

-- Query the results
SELECT *
FROM WESTMINSTER_CONSTITUENCY_POINTS
ORDER BY 
    FILE_NAME
  , ROW_NUMBER
;

-------------------------------
-- Polygon Table for Regions

-- Chosen a table instead of a view
-- so that we can enforce the order of
-- points and thus choose the order
-- in which they are collected and placed
-- in the line during ST_COLLECT() and
-- during ST_MAKELINE()

create or replace table NATIONS_AND_REGIONS_POINTS_IN_ORDER
as
select 
    NATION_OR_REGION_NAME
  , TYPE
  , PART
  , SEQUENCE_NUM
  , ST_MAKEPOINT( LONGITUDE, LATITUDE ) as GEO_POINT
from NATIONS_AND_REGIONS
order by
    NATION_OR_REGION_NAME
  , TYPE
  , PART
  , SEQUENCE_NUM
;

create or replace table NATIONS_AND_REGIONS_POLYGONS
as
with starting_points as (
  select 
      NATION_OR_REGION_NAME
    , TYPE
    , PART
    , GEO_POINT as STARTING_POINT
  from NATIONS_AND_REGIONS_POINTS_IN_ORDER
  where SEQUENCE_NUM = 0
)
, collected_point as (
  select 
      NATION_OR_REGION_NAME
    , TYPE
    , PART
    , ST_COLLECT(GEO_POINT) as COLLECTED_POINTS_IN_ORDER
  from NATIONS_AND_REGIONS_POINTS_IN_ORDER
  where SEQUENCE_NUM != 0
  group by
      NATION_OR_REGION_NAME
    , TYPE
    , PART
)
, polygons_in_parts as (
  select 
      cp.NATION_OR_REGION_NAME
    , cp.TYPE
    , cp.PART
    , ST_MAKEPOLYGON(
        ST_MAKELINE(
            sp.STARTING_POINT
          , cp.COLLECTED_POINTS_IN_ORDER
        )
      ) as POLYGON
  from collected_point as cp
    inner join starting_points as sp
      on  cp.NATION_OR_REGION_NAME = sp.NATION_OR_REGION_NAME
      and cp.TYPE = sp.TYPE
      and cp.PART = sp.PART
)
select 
    NATION_OR_REGION_NAME
  , TYPE
  , ST_COLLECT(POLYGON) as POLYGON
from polygons_in_parts
group by 
    NATION_OR_REGION_NAME
  , TYPE
;

select *
from NATIONS_AND_REGIONS_POLYGONS
;

-------------------------------
-- Polygon Table for Westminster Constituencies 

-- Chosen a table instead of a view
-- so that we can enforce the order of
-- points and thus choose the order
-- in which they are collected and placed
-- in the line during ST_COLLECT() and
-- during ST_MAKELINE()

create or replace table WESTMINSTER_CONSTITUENCY_POINTS_IN_ORDER
as
select 
    CONSTITUENCY
  , PART
  , POINT_SEQUENCE_NUM
  , ST_MAKEPOINT( LONGITUDE, LATITUDE ) as GEO_POINT
from WESTMINSTER_CONSTITUENCY_POINTS
order by
    CONSTITUENCY
  , PART
  , POINT_SEQUENCE_NUM
;


create or replace table WESTMINSTER_CONSTITUENCY_POLYGONS
as
with starting_points as (
  select 
      CONSTITUENCY
    , PART
    , GEO_POINT as STARTING_POINT
  from WESTMINSTER_CONSTITUENCY_POINTS_IN_ORDER
  where POINT_SEQUENCE_NUM = 0
)
, collected_point as (
  select 
      CONSTITUENCY
    , PART
    , ST_COLLECT(GEO_POINT) as COLLECTED_POINTS_IN_ORDER
  from WESTMINSTER_CONSTITUENCY_POINTS_IN_ORDER
  where POINT_SEQUENCE_NUM != 0
  group by
      CONSTITUENCY
    , PART
)
, polygons_in_parts as (
  select 
      cp.CONSTITUENCY
    , cp.PART
    , ST_MAKEPOLYGON(
        ST_MAKELINE(
            sp.STARTING_POINT
          , cp.COLLECTED_POINTS_IN_ORDER
        )
      ) as POLYGON
  from collected_point as cp
    inner join starting_points as sp
      on  cp.CONSTITUENCY = sp.CONSTITUENCY
      and cp.PART = sp.PART
)
select 
    CONSTITUENCY
  , ST_COLLECT(POLYGON) as POLYGON
from polygons_in_parts
group by 
    CONSTITUENCY
;

select *
from WESTMINSTER_CONSTITUENCY_POLYGONS
;


-------------------------------
-- Identify Intersecting Constituencies

-- NATIONS_AND_REGIONS_POLYGONS
-- WESTMINSTER_CONSTITUENCY_GEO_POINTS

create or replace view intersecting_constituencies
as
select
    NATION_OR_REGION_NAME
  , COUNT(wc.CONSTITUENCY) as INTERSECTING_CONSTITUENCIES
from NATIONS_AND_REGIONS_POLYGONS AS nar
  cross join WESTMINSTER_CONSTITUENCY_POLYGONS as wc
where ST_INTERSECTS(nar.POLYGON, wc.POLYGON)
group by
    NATION_OR_REGION_NAME
order by
    NATION_OR_REGION_NAME
;

-- Query the view
select *
from intersecting_constituencies
;
  