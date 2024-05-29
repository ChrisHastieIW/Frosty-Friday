
-- Frosty Friday Challenge
-- Week 94 - Intermediate - Execute immediate from
-- https://frostyfriday.org/blog/2024/05/17/week-94-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema "WEEK_94";

use schema "WEEK_94";

-------------------------------
-- Challenge Setup Script

-- Create the stage
create or replace stage "SETUP_STAGE";

-------------------------------
-- Challenge Solution

-- Upload file to stage
-- Using the VSCode extension, we can run this directly
-- without needing to outsource to SnowSQL!
put 'FILE://Week 94 - Intermediate - Execute immediate from/setup_env_made_by_intern.sql' @"SETUP_STAGE" overwrite=true auto_compress=false;

-- View files in stage
list @"SETUP_STAGE";

-- Execute immediate from
execute immediate
from '@SETUP_STAGE/setup_env_made_by_intern.sql'
  using (deployment_type => 'prod')
;
