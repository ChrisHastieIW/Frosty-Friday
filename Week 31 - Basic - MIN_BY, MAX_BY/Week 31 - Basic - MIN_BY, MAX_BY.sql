
-- Frosty Friday Challenge
-- Week 31 - Basic - MIN_BY, MAX_BY
-- https://frostyfriday.org/2023/01/27/week-31-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_31;

use schema WEEK_31;

-------------------------------
-- Create challenge data

create or replace table CHALLENGE_DATA(
    id int
  , hero_name string
  , villains_defeated number
)
as
select * from values
    (1, 'Pigman', 5)
  , (2, 'The OX', 10)
  , (3, 'Zaranine', 4)
  , (4, 'Frostus', 8)
  , (5, 'Fridayus', 1)
  , (6, 'SheFrost', 13)
  , (7, 'Dezzin', 2.3)
  , (8, 'Orn', 7)
  , (9, 'Killder', 6)
  , (10, 'PolarBeast', 11)
;

-------------------------------
-- Create view with MIN_BY and MAX_BY

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
select
    max_by(hero_name, villains_defeated) as best_hero
  , min_by(hero_name, villains_defeated) as worst_hero
from CHALLENGE_DATA
;

-- Query the views
select * from CHALLENGE_OUTPUT;
