
-- This is the main SQL script that is
-- used to deploy the native application package
-- and native application

-------------------------------
-- Environment

-- Use the application admin role
-- which was created at another time.
-- This role has the following grants:
-- - CREATE APPLICATION PACKAGE
-- - CREATE APPLICATION
use role APPLICATION_ADMIN;

-------------------------------
-- Application package creation

-- Create the application package
create application package if not exists "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_62"
  comment = 'Owned by Chris Hastie. Solution for Frosty Friday challenge 62.'
;

-- View the application package
show application packages like 'APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_62';

-------------------------------
-- Application deployment

-- Add a version to the application package with the uploaded files
alter application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_62"
  add version V1_0 using '@"CH_FROSTY_FRIDAY"."WEEK_62"."STG_NATIVE_APP_CONTENT"'
;

-- View the application package version
show versions in application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_62";

-- Install the application using the version
drop application if exists "APP_CH_FROSTY_FRIDAY_WEEK_62";
create application "APP_CH_FROSTY_FRIDAY_WEEK_62"
  from application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_62"
  using version V1_0
  comment = 'Owned by Chris Hastie. Solution for Frosty Friday challenge 62.'
;
