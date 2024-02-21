
-- Frosty Friday Challenge
-- Week 79 - Basic - Login Screen Security
-- https://frostyfriday.org/blog/2024/02/02/week-79-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_79;

use schema WEEK_79;

-------------------------------
-- Part 1 - Account-wide restriction to UI login

-- Create the authentication policy
create authentication policy AUTH_POL__SNOWFLAKE_UI_ONLY
  client_types = ('SNOWFLAKE_UI')
  comment = 'Only allows access through the web interface'
;

-- Apply the authentication policy to the account
alter account set authentication policy = 'AUTH_POL__SNOWFLAKE_UI_ONLY';

-------------------------------
-- Part 2 - User-specific restriction to passwords only

-- Create the authentication policy
create authentication policy AUTH_POL__PASSWORD_ONLY
  authentication_methods = ('PASSWORD')
  comment = 'Only allows login via the username/password authentication method'
;

-- Apply the authentication policy to a user
alter user USER_1 set authentication policy = 'AUTH_POL__SNOWFLAKE_UI_ONLY';
