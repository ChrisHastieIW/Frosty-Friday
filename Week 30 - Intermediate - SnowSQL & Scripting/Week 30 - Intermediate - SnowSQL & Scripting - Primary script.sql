
----------------------------------------
-- Instructions

-- The following script will automatically create
-- a set of databases, roles, users and a warehouse
-- in Snowflake. To execute this script, leverage
-- a snowsql command in the command line in the following
-- format, which has been expanded for ease of reading
-- and for descriptive comments

-- The following example snowsql command leverages a bespoke config file.
-- Not providing an optional value will leverage the value in the config file.

----------------------
-- snowsql
-- --config "<Path to the bespoke config file storing default variable values>"
-- -f <Relative path to this primary script, for example "Week 30 - Intermediate - SnowSQL & Scripting\Week 30 - Intermediate - SnowSQL & Scripting - Primary script.sql">
-- <<OPTIONAL| -D db_prefix=<your database prefix, for example CH_FF_W30> >>
-- <<OPTIONAL| -D password_prefix=<your password prefix, for example CH_FF_W30_PSWD> >>
-- <<OPTIONAL| -D secondary_script_path=<Relative path to the secondary script, for example "Week 30 - Intermediate - SnowSQL & Scripting\Week 30 - Intermediate - SnowSQL & Scripting - Secondary script.sql"> >>
----------------------

-- The following example snowsql command does not leverage a config file
-- for if you prefer to do everything in one place. This does not allow
-- the user to fall back to default variable values if they are not provided.

----------------------
-- snowsql
-- -a <Your account identifier. Honors $SNOWSQL_ACCOUNT>
-- -u <Username to connect to Snowflake. Honors $SNOWSQL_USER>
-- -r <Role name to use. Honors $SNOWSQL_ROLE. Must have access to create all the required objects>
-- --private-key-path "<Path to private key file used for authentication. Authenticate another way if you wish>"
-- -o variable_substitution=true
-- -f <Relative path to this primary script, for example "Week 30 - Intermediate - SnowSQL & Scripting\Week 30 - Intermediate - SnowSQL & Scripting - Primary script.sql">
-- -D db_prefix=<your database prefix, for example CH_FF_W30>
-- -D password_prefix=<your password prefix, for example CH_FF_W30_PSWD>
-- -D secondary_script_path=<Relative path to the secondary script, for example "Week 30 - Intermediate - SnowSQL & Scripting\Week 30 - Intermediate - SnowSQL & Scripting - Secondary script.sql">
----------------------
;


----------------------------------------
-- Script

create or replace database "&{db_prefix}_DEVELOPMENT";
create or replace database "&{db_prefix}_TESTING";
create or replace database "&{db_prefix}_ACCEPTANCE";
create or replace database "&{db_prefix}_PRODUCTION";

create or replace schema "&{db_prefix}_DEVELOPMENT"."SECURITY";
create or replace schema "&{db_prefix}_TESTING"."SECURITY";
create or replace schema "&{db_prefix}_ACCEPTANCE"."SECURITY";
create or replace schema "&{db_prefix}_PRODUCTION"."SECURITY";

create or replace warehouse "WH_&{db_prefix}"
with
  WAREHOUSE_SIZE = XSMALL
  INITIALLY_SUSPENDED = TRUE
;

create or replace user "&{db_prefix}_SECURITY_USER"
  PASSWORD = '&{password_prefix}123sec'
  DEFAULT_SECONDARY_ROLES = ( 'ALL' )
;
create or replace user "&{db_prefix}_DEV_USER"
  PASSWORD = '&{password_prefix}123dev'
  DEFAULT_SECONDARY_ROLES = ( 'ALL' )
;
create or replace user "&{db_prefix}_REGULAR_USER"
  PASSWORD = '&{password_prefix}123reg'
  DEFAULT_SECONDARY_ROLES = ( 'ALL' )
;

create or replace role "&{db_prefix}_SECURITY_ROLE";
create or replace role "&{db_prefix}_DEV_ROLE";

grant usage on database "&{db_prefix}_PRODUCTION" to role "PUBLIC";
grant usage on schema "&{db_prefix}_PRODUCTION"."PUBLIC" to role "PUBLIC";

grant usage on database "&{db_prefix}_DEVELOPMENT" to role "&{db_prefix}_DEV_ROLE";
grant usage on database "&{db_prefix}_TESTING" to role "&{db_prefix}_DEV_ROLE";
grant usage on database "&{db_prefix}_ACCEPTANCE" to role "&{db_prefix}_DEV_ROLE";
grant usage on database "&{db_prefix}_PRODUCTION" to role "&{db_prefix}_DEV_ROLE";
grant usage, create table, create view on schema "&{db_prefix}_DEVELOPMENT"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant usage, create table, create view on schema "&{db_prefix}_TESTING"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant usage, create table, create view on schema "&{db_prefix}_ACCEPTANCE"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant usage, create table, create view on schema "&{db_prefix}_PRODUCTION"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on future tables in schema "&{db_prefix}_DEVELOPMENT"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on future tables in schema "&{db_prefix}_TESTING"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on future tables in schema "&{db_prefix}_ACCEPTANCE"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on future tables in schema "&{db_prefix}_PRODUCTION"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on future views in schema "&{db_prefix}_DEVELOPMENT"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on future views in schema "&{db_prefix}_TESTING"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on future views in schema "&{db_prefix}_ACCEPTANCE"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on future views in schema "&{db_prefix}_PRODUCTION"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on all tables in schema "&{db_prefix}_DEVELOPMENT"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on all tables in schema "&{db_prefix}_TESTING"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on all tables in schema "&{db_prefix}_ACCEPTANCE"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on all tables in schema "&{db_prefix}_PRODUCTION"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on all views in schema "&{db_prefix}_DEVELOPMENT"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on all views in schema "&{db_prefix}_TESTING"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on all views in schema "&{db_prefix}_ACCEPTANCE"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";
grant select on all views in schema "&{db_prefix}_PRODUCTION"."PUBLIC" to role "&{db_prefix}_DEV_ROLE";

grant usage on schema "&{db_prefix}_DEVELOPMENT"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant usage on schema "&{db_prefix}_TESTING"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant usage on schema "&{db_prefix}_ACCEPTANCE"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant usage on schema "&{db_prefix}_PRODUCTION"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant usage, create table, create view on schema "&{db_prefix}_DEVELOPMENT"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant usage, create table, create view on schema "&{db_prefix}_TESTING"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant usage, create table, create view on schema "&{db_prefix}_ACCEPTANCE"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant usage, create table, create view on schema "&{db_prefix}_PRODUCTION"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on future tables in schema "&{db_prefix}_DEVELOPMENT"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on future tables in schema "&{db_prefix}_TESTING"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on future tables in schema "&{db_prefix}_ACCEPTANCE"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on future tables in schema "&{db_prefix}_PRODUCTION"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on future views in schema "&{db_prefix}_DEVELOPMENT"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on future views in schema "&{db_prefix}_TESTING"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on future views in schema "&{db_prefix}_ACCEPTANCE"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on future views in schema "&{db_prefix}_PRODUCTION"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on all tables in schema "&{db_prefix}_DEVELOPMENT"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on all tables in schema "&{db_prefix}_TESTING"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on all tables in schema "&{db_prefix}_ACCEPTANCE"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on all tables in schema "&{db_prefix}_PRODUCTION"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on all views in schema "&{db_prefix}_DEVELOPMENT"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on all views in schema "&{db_prefix}_TESTING"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on all views in schema "&{db_prefix}_ACCEPTANCE"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";
grant select on all views in schema "&{db_prefix}_PRODUCTION"."SECURITY" to role "&{db_prefix}_SECURITY_ROLE";

grant role "&{db_prefix}_DEV_ROLE" to role "&{db_prefix}_SECURITY_ROLE";

grant role "&{db_prefix}_DEV_ROLE" to user "&{db_prefix}_DEV_USER";
grant role "&{db_prefix}_SECURITY_ROLE" to user "&{db_prefix}_SECURITY_USER";

-- Execute the secondary script
use schema "&{db_prefix}_DEVELOPMENT"."PUBLIC";
!source &{secondary_script_path}