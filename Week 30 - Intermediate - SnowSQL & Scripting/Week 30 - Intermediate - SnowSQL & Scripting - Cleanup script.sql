
----------------------------------------
-- Instructions

-- The following script will automatically remove
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
-- -f <Relative path to this cleanup script, for example "Week 30 - Intermediate - SnowSQL & Scripting\Week 30 - Intermediate - SnowSQL & Scripting - Cleanup script.sql">
-- <<OPTIONAL| -D db_prefix=<your database prefix, for example CH_FF_W30> >>
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
-- -f <Relative path to this cleanup script, for example "Week 30 - Intermediate - SnowSQL & Scripting\Week 30 - Intermediate - SnowSQL & Scripting - Cleanup script.sql">
-- -D db_prefix=<your database prefix, for example CH_FF_W30>
----------------------
;


----------------------------------------
-- Script

drop database if exists "&{db_prefix}_DEVELOPMENT";
drop database if exists "&{db_prefix}_TESTING";
drop database if exists "&{db_prefix}_ACCEPTANCE";
drop database if exists "&{db_prefix}_PRODUCTION";

drop warehouse if exists "WH_&{db_prefix}";

drop user if exists "&{db_prefix}_SECURITY_USER";
drop user if exists "&{db_prefix}_DEV_USER";
drop user if exists "&{db_prefix}_REGULAR_USER";

drop role if exists "&{db_prefix}_SECURITY_ROLE";
drop role if exists "&{db_prefix}_DEV_ROLE";
