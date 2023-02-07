
-- Frosty Friday Challenge
-- Week 32 - Basic - Session Security
-- https://frostyfriday.org/2023/02/03/week-32-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_32;

use schema WEEK_32;

-------------------------------
-- Create users

create or replace user temp_ch_frosty_friday_user_1;
create or replace user temp_ch_frosty_friday_user_2;

-------------------------------
-- Create session policies

-- User 1 should have a max idle time of 8 minutes in the old Snowflake UI
create or replace session policy TEMP_CH_FROSTY_FRIDAY_SESSION_POLICY_1
  SESSION_UI_IDLE_TIMEOUT_MINS = 8
;

alter user temp_ch_frosty_friday_user_1
set session policy TEMP_CH_FROSTY_FRIDAY_SESSION_POLICY_1
;

-- User 2 should have a max idle time of 10 minutes in SnowSQL and in their communication with Snowflake from tools like Tableau
create or replace session policy TEMP_CH_FROSTY_FRIDAY_SESSION_POLICY_2
  SESSION_IDLE_TIMEOUT_MINS = 10
;

alter user temp_ch_frosty_friday_user_2
set session policy TEMP_CH_FROSTY_FRIDAY_SESSION_POLICY_2
;

-------------------------------
-- Enforce session policies

alter account set enforce_session_policy = true;

-------------------------------
-- Clean up

alter account set enforce_session_policy = false;

drop user if exists temp_ch_frosty_friday_user_1;
drop user if exists temp_ch_frosty_friday_user_2;