
-- Frosty Friday Challenge
-- Week 21 - Basic - Pivoting
-- https://frostyfriday.org/2022/11/04/week-21-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_21;

use schema WEEK_21;

-------------------------------
-- Investigate Challenge Data

-- Generate the challenge data
create or replace table hero_powers (
    hero_name VARCHAR(50)
  , flight VARCHAR(50)
  , laser_eyes VARCHAR(50)
  , invisibility VARCHAR(50)
  , invincibility VARCHAR(50)
  , psychic VARCHAR(50)
  , magic VARCHAR(50)
  , super_speed VARCHAR(50)
  , super_strength VARCHAR(50)
)
as
select * from values
    ('The Impossible Guard', '++', '-', '-', '-', '-', '-', '-', '+')
  , ('The Clever Daggers', '-', '+', '-', '-', '-', '-', '-', '++')
  , ('The Quick Jackal', '+', '-', '++', '-', '-', '-', '-', '-')
  , ('The Steel Spy', '-', '++', '-', '-', '+', '-', '-', '-')
  , ('Agent Thundering Sage', '++', '+', '-', '-', '-', '-', '-', '-')
  , ('Mister Unarmed Genius', '-', '-', '-', '-', '-', '-', '-', '-')
  , ('Doctor Galactic Spectacle', '-', '-', '-', '++', '-', '-', '-', '+')
  , ('Master Rapid Illusionist', '-', '-', '-', '-', '++', '-', '+', '-')
  , ('Galactic Gargoyle', '+', '-', '-', '-', '-', '-', '++', '-')
  , ('Alley Cat', '-', '++', '-', '-', '-', '-', '-', '+')
;

-- View the challenge data
select * from hero_powers;

-------------------------------
-- Pivotted view

-- Create a view which pivots the challenge data
create or replace view hero_power_summary
as
with unpivotted_powers as (
  select *
  from hero_powers
    unpivot (
      power_level for power in (
          flight
        , laser_eyes
        , invisibility
        , invincibility
        , psychic
        , magic
        , super_speed
        , super_strength
      )
    )
), categorised_powers  as (
  select
      hero_name
    , power
    , case power_level
        when '++' then 'MAIN_POWER'
        when '+' then 'SECONDARY_POWER'
      end as categorised_power_level
  from unpivotted_powers
  where categorised_power_level is not null
)
select
    hero_name
  , "'MAIN_POWER'" as MAIN_POWER
  , "'SECONDARY_POWER'" as SECONDARY_POWER
from categorised_powers
  pivot (
      max(power) for categorised_power_level in (
          'MAIN_POWER'
        , 'SECONDARY_POWER'
      )        
    )
;

-- Query the view
select *
from hero_power_summary
;
