
-- Frosty Friday Challenge
-- Week 92  - Easy - Strings comparison
-- https://frostyfriday.org/blog/2024/05/03/week-92-easy/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema "WEEK_92";

use schema "WEEK_92";

-------------------------------
-- Challenge Setup Script

-- Create a table named FRUIT_SALAD
create or replace table "FRUIT_SALAD" (
  "FRUITS" varchar(255)
)
as
select * from values
    ('apple')
  , ('apricot')
  , ('banana')
  , ('pineapple')
  , ('oranges')
  , ('kiwi')
  , ('strawberry')
  , ('grape')
  , ('watermelon')
  , ('pear')
  , ('peach')
  -- , ('strawberry') -- Removed dupe
  , ('blueberry')
  , ('mango')
  , ('lemon')
  , ('lime')
  , ('papaya')
  , ('cherry')
  , ('plum')
  , ('fig')
  , ('passion fruit')
  , ('raspberry')
  , ('blackberry')
  , ('nectarine')
  , ('cantaloupe')
  , ('apricot')
  , ('tangerine')
  , ('guava')
  , ('dragon fruit')
;

-- Review the table
select * from "FRUIT_SALAD";

-------------------------------
-- Challenge Solution

-- Leverage the JAROWINKLER_SIMILARITY function
select
    "FRUITS"
from "FRUIT_SALAD"
order by JAROWINKLER_SIMILARITY("FRUITS", 'strawberry') desc
;
