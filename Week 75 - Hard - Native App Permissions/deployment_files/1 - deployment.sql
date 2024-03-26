
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
create application package if not exists "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_75"
  comment = 'Owned by Chris Hastie. Solution for Frosty Friday challenge 75.'
;

-- View the application package
show application packages like 'APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_75';

-------------------------------
-- Application deployment

-- Add a version to the application package using staged files
-- Only needed if version does not already exist
alter application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_75"
  add version V1_0 using '@"CH_FROSTY_FRIDAY"."WEEK_75"."STG__NATIVE_APP_CONTENT"/v1/'
;

-- Drop the version if needed
-- alter application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_75"
--   drop version V1_0
-- ;

-- Patch an existing version of the application package using staged files
alter application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_75"
  add patch for version V1_0 using '@"CH_FROSTY_FRIDAY"."WEEK_75"."STG__NATIVE_APP_CONTENT"/v1/'
;

-- View the application package version
show versions in application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_75";

-- Drop existing application if desired
-- drop application if exists "APP_CH_FROSTY_FRIDAY_WEEK_75";

-- Install the application using the version
create application if not exists "APP_CH_FROSTY_FRIDAY_WEEK_75"
  from application package "APP_PACKAGE_CH_FROSTY_FRIDAY_WEEK_75"
  using version V1_0
  comment = 'Owned by Chris Hastie. Solution for Frosty Friday challenge 75.'
;

-- Upgrade the application using the version
alter application "APP_CH_FROSTY_FRIDAY_WEEK_75"
  upgrade using version V1_0
;
