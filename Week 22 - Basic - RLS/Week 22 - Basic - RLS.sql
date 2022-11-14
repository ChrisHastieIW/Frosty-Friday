
-- Frosty Friday Challenge
-- Week 22 - Basic - RLS
-- https://frostyfriday.org/2022/11/11/week-22-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_22;

use schema WEEK_22;

-------------------------------
-- Variable Configuration

set var_database = 'CH_FROSTY_FRIDAY';
set var_warehouse = 'WH_CHASTIE';
set var_schema = 'WEEK_22';

set var_role_main = 'CONSULTANT';

set var_role_1 = 'CH_FROSTY_FRIDAY_ROLE_1';
set var_role_2 = 'CH_FROSTY_FRIDAY_ROLE_2';
set var_schema_fqn = concat($var_database, '.', $var_schema);

-------------------------------
-- Challenge Security Elements

use role securityadmin;

-- Roles needed for challenge
create role if not exists identifier($var_role_1);
create role if not exists identifier($var_role_2);

-- Grant roles to self for testing
set current_snowflake_user_identifier = concat('"', current_user(), '"');
grant role identifier($var_role_1) to user identifier($current_snowflake_user_identifier);
grant role identifier($var_role_2) to user identifier($current_snowflake_user_identifier);

-- Enable warehouse usage. Assumes that `public` has access to the warehouse
grant usage on warehouse identifier($var_warehouse) to role identifier($var_role_1);
grant usage on warehouse identifier($var_warehouse) to role identifier($var_role_2);

-- Roles need DB access
grant usage on database identifier($var_database) to role identifier($var_role_1);
grant usage on database identifier($var_database) to role identifier($var_role_2);
-- And schema access
grant usage on schema identifier($var_schema_fqn) to role identifier($var_role_1);
grant usage on schema identifier($var_schema_fqn) to role identifier($var_role_2);
-- And select on views
grant select on all views in schema identifier($var_schema_fqn) to role identifier($var_role_1);
grant select on all views in schema identifier($var_schema_fqn) to role identifier($var_role_2);
grant select on future views in schema identifier($var_schema_fqn) to role identifier($var_role_1);
grant select on future views in schema identifier($var_schema_fqn) to role identifier($var_role_2);

-------------------------------
-- Challenge Start-Up Code

-- Use the standard role in my Snowflake account
use role identifier($var_role_main);
use schema identifier($var_schema_fqn);

-- Generate the challenge data
-- File format to read the CSV
create or replace file format frosty_csv
  type = csv
  field_delimiter = ','
  field_optionally_enclosed_by = '"'
  skip_header = 1
;
    
-- Creates stage to read the CSV
create or replace stage w22_frosty_stage
  url = 's3://frostyfridaychallenges/challenge_22/'
  file_format = frosty_csv
;

-- Create the table from the CSV in S3
create or replace table week22 as
select
    t.$1::int id
  , t.$2::varchar(50) city
  , t.$3::int district
from @w22_frosty_stage (pattern=>'.*sales_areas.*') t
;

-------------------------------
-- Create dynamic data masking for id field

-- Use the standard role in my Snowflake account
use role identifier($var_role_main);
use schema identifier($var_schema_fqn);

-- Create dynamic data masking policy
create or replace masking policy mask_id
as
  (id string)
  returns string ->
    CASE WHEN IS_ROLE_IN_SESSION($var_role_main)
      THEN id
      ELSE uuid_string()
    END
;

-------------------------------
-- Create different secure views

-- Use the standard role in my Snowflake account
use role identifier($var_role_main);
use schema identifier($var_schema_fqn);

-- Method 1: Direct
create or replace secure view secure_cities_1
as
select
    id::string as id
  , city
  , district
from week22
where 
    (
          mod(id, 2) = 1 -- ID is odd
      and IS_ROLE_IN_SESSION($var_role_1)
    )
  or  
    (
          mod(id, 2) = 0 -- ID is even
      and IS_ROLE_IN_SESSION($var_role_2)
    )
  or -- all access for main role
    IS_ROLE_IN_SESSION($var_role_main)
;

-- Mask ID field
alter view secure_cities_1
alter column id
set masking policy mask_id
;

-- Method 2: Direct with field for IS_ROLE_IN_SESSION
create or replace secure view secure_cities_2
as
with security_map as (
  select 
      *
    , CASE mod(id, 2)
        WHEN 1 THEN $var_role_1 
        WHEN 0 THEN $var_role_2
      END as allowed_role
  from week22
)
select
    id::string as id
  , city
  , district
from security_map
where 
    -- all access for main role
    IS_ROLE_IN_SESSION($var_role_main)
  or
    -- columnar IS_ROLE_IN_SESSION
    IS_ROLE_IN_SESSION(allowed_role)
;

-- Mask ID field
alter view secure_cities_2
alter column id
set masking policy mask_id
;

-- Method 3: Direct using 
create or replace secure view secure_cities_3
as
with security_map as (
  select
      id
    , CASE mod(id, 2)
        WHEN 1 THEN $var_role_1 
        WHEN 0 THEN $var_role_2
      END as allowed_role
  from week22
)
select
    id::string as id
  , city
  , district
from week22
where 
    -- all access for main role
    IS_ROLE_IN_SESSION($var_role_main)
  or 
    -- leverage mapping and exists
    exists (
      select 1
      from security_map
      where week22.id = security_map.id
        and IS_ROLE_IN_SESSION(allowed_role)
    )
;

-- Mask ID field
alter view secure_cities_3
alter column id
set masking policy mask_id
;

-- Method 4: Nested access policies
create or replace row access policy row_access_policy_method_4
as
  (id int)
  returns boolean ->
      IS_ROLE_IN_SESSION($var_role_main)
    OR
      (mod(id, 2) = 1 AND IS_ROLE_IN_SESSION($var_role_1))
    OR
      (mod(id, 2) = 0 AND IS_ROLE_IN_SESSION($var_role_2))
;

-- Create plain view
create or replace secure view secure_cities_4a
as
select
    id
  , city
  , district
from week22
;

-- Apply row level security
alter view secure_cities_4a
add row access policy row_access_policy_method_4 on (id)
;

create or replace secure view secure_cities_4
as
select
    id::string as id
  , city
  , district
from secure_cities_4a
;

-- Mask ID field
alter view secure_cities_4
alter column id
set masking policy mask_id
;

-------------------------------
-- Testing

-- Verify full access for main role
use role identifier($var_role_main);
select * from secure_cities_1;
select * from secure_cities_2;
select * from secure_cities_3;
select * from secure_cities_4;

-- Verify odd access for role 1
use role identifier($var_role_1);
select * from secure_cities_1;
select * from secure_cities_2;
select * from secure_cities_3;
select * from secure_cities_4;

-- Verify even access for role 2
use role identifier($var_role_2);
select * from secure_cities_1;
select * from secure_cities_2;
select * from secure_cities_3;
select * from secure_cities_4;

