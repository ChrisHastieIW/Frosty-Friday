
-- Frosty Friday Challenge
-- Week 17 - Intermediate - Spatial
-- https://frostyfriday.org/2022/10/07/week-17-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_17;

use schema WEEK_17;

-------------------------------
-- Investigate Challenge Data

-- Sample the node view
select * from SHARE_OPEN_STREET_MAP__NEW_YORK.NEW_YORK.V_OSM_NY_NODE
limit 100
;

-- Required field "ADDR_CITY" is not present
-- and we need it to filter to Brooklyn.
-- The "TAGS" field however seems to contain a list
-- that sometimes contains an object with address details.
-- A little bit of parsing yields the following query
-- that targets Brooklyn nodes
select NODE.*
from SHARE_OPEN_STREET_MAP__NEW_YORK.NEW_YORK.V_OSM_NY_NODE as NODE
  , lateral flatten(NODE.TAGS, OUTER => TRUE, MODE => 'ARRAY') as tags_member
where tags_member.value:"key"::string = 'addr:city'
  and tags_member.value:"value"::string = 'Brooklyn'
limit 100
;

-- Only one type, nothing to clearly state a "central" node.
select distinct type from SHARE_OPEN_STREET_MAP__NEW_YORK.NEW_YORK.V_OSM_NY_NODE;

-- Also attempted to investigate further tag values but found nothing of note.
select distinct 
    tags_member.value:"key"::string
  , tags_member.value:"value"::string
from SHARE_OPEN_STREET_MAP__NEW_YORK.NEW_YORK.V_OSM_NY_NODE as NODE
  , lateral flatten(NODE.TAGS, OUTER => TRUE, MODE => 'ARRAY') as tags_member
where tags_member.value:"value"::string ilike '%central%'
  and tags_member.value:"key"::string not in ('name', 'website', 'addr:street', 'wikipedia', 'name:fr', 'official_name', 'short_name', 'source_ref', 'image', 'inscription', 'email', 'operator', 'name:en', 'addr:city', 'name:es', 'addr:housename')
order by 1
;

-------------------------------
-- View of Brooklyn Nodes

-- Create a view of all nodes within Brooklyn
create or replace view BROOKLYN_NODES
as
select 
    NODE.ID
  , NODE.LON
  , NODE.LAT
  , NODE.COORDINATES
from SHARE_OPEN_STREET_MAP__NEW_YORK.NEW_YORK.V_OSM_NY_NODE as NODE
  , lateral flatten(NODE.TAGS, OUTER => TRUE, MODE => 'ARRAY') as tags_member
where tags_member.value:"key"::string = 'addr:city'
  and tags_member.value:"value"::string = 'Brooklyn'
;

-- Query the view
select *
from BROOKLYN_NODES
limit 100
;

-------------------------------
-- Table of Proximity Nodes

-- Create a table that cross joins
-- our potential central nodes from Brooklyn
-- with our full list of nodes.
-- Filter with qualify to restrict to entries
-- that match at least 4 times (itself + 3).
-- Takes 10 mins on M
create or replace table BROOKLYN_PROXIMITY_NODES
as
select 
    NODE.ID
  , NODE.LON
  , NODE.LAT
  , NODE.COORDINATES
  , BROOKLYN_NODES.ID AS CENTRAL_NODE_ID
  , BROOKLYN_NODES.LON AS CENTRAL_NODE_LON
  , BROOKLYN_NODES.LAT AS CENTRAL_NODE_LAT
  , BROOKLYN_NODES.COORDINATES AS CENTRAL_NODE_COORDINATES
  , st_distance(NODE.COORDINATES, BROOKLYN_NODES.COORDINATES) AS DISTANCE_BETWEEN_NODES
from SHARE_OPEN_STREET_MAP__NEW_YORK.NEW_YORK.V_OSM_NY_NODE as NODE
  cross join BROOKLYN_NODES
where st_dwithin(NODE.COORDINATES, BROOKLYN_NODES.COORDINATES, 750)
qualify count(*) over (partition by BROOKLYN_NODES.ID) >= 4
;

-- Query the table
select *
from BROOKLYN_PROXIMITY_NODES
limit 100
;

-------------------------------
-- Table of Groups

-- Aggregate the set of proximity nodes
-- and store as a table to ease processing.
-- Takes 10 secs on M
create or replace table GROUPS
as
select
    CENTRAL_NODE_ID AS GROUP_ID
  , array_agg(ID) AS NODE_IDS
  , st_collect(COORDINATES) AS NODE_COORDINATES
from BROOKLYN_PROXIMITY_NODES
group by
    CENTRAL_NODE_ID
;

-- Query the table
select *
from GROUPS
limit 100
;

-------------------------------
-- Table of Group Boundaries

-- Process the aggregated groups
-- to create the boundary line and polygon.
-- Would have liked to use ST_ENVELOPE,
-- however this has been deprecated by Snowflake:
-- https://docs.snowflake.com/en/sql-reference/functions/st_envelope.html
-- Takes 20 secs on M
create or replace table GROUP_BOUNDARIES
as
select
    GROUP_ID
  , NODE_IDS
  , NODE_COORDINATES
  , st_xmin(NODE_COORDINATES) AS MIN_LON
  , st_xmax(NODE_COORDINATES) AS MAX_LON
  , st_ymin(NODE_COORDINATES) AS MIN_LAT
  , st_ymax(NODE_COORDINATES) AS MAX_LAT
  , st_makepoint(MAX_LON, MAX_LAT) AS CORNER_TOP_RIGHT
  , st_makepoint(MIN_LON, MAX_LAT) AS CORNER_TOP_LEFT
  , st_makepoint(MAX_LON, MIN_LAT) AS CORNER_BOTTOM_RIGHT
  , st_makepoint(MIN_LON, MIN_LAT) AS CORNER_BOTTOM_LEFT
  , st_makeline(
        CORNER_TOP_LEFT
      , st_makeline(
          CORNER_TOP_RIGHT
          , st_makeline(
                CORNER_BOTTOM_RIGHT
              , st_makeline(
                    CORNER_BOTTOM_LEFT
                  , CORNER_TOP_LEFT
                )
            )
        )
    ) AS BOUNDING_LINE
  , st_makepolygon(BOUNDING_LINE) AS BOUNDING_POLYGON
from GROUPS
;

-- Query the table
select *
from GROUP_BOUNDARIES
limit 100
;

-------------------------------
-- View of Group Boundaries in WKT

-- Query specific fields from the table
create or replace view GROUP_BOUNDARIES_WKT
as
select
    GROUP_ID
  , NODE_IDS
  , NODE_COORDINATES
  , BOUNDING_LINE
  , BOUNDING_POLYGON
  , st_aswkt(BOUNDING_LINE) as BOUNDING_LINE_WKT
  , st_aswkt(BOUNDING_POLYGON) as BOUNDING_POLYGON_WKT
from GROUP_BOUNDARIES
;

-- Query the view
select *
from GROUP_BOUNDARIES_WKT
limit 100
;

-- Retrieve single multipolygon from view to populate WKT plotting tool
select st_aswkt(st_collect(BOUNDING_POLYGON)) as BOUNDING_POLYGONS_WKT
from GROUP_BOUNDARIES_WKT
;