
-- Frosty Friday Challenge
-- Week 14 - Basic - JSON
-- https://frostyfriday.org/2022/09/16/week-14-basic/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_14;

use schema WEEK_14;

-------------------------------
-- Create table for the challenge

-- Create empty table
CREATE OR REPLACE TABLE TESTING_DATA (
    superhero_name varchar(50),
    country_of_residence varchar(50),
    notable_exploits varchar(150),
    superpower varchar(100),
    second_superpower varchar(100),
    third_superpower varchar(100)
);

-- Populate with values
insert into TESTING_DATA
select *
from values
    ('Superpig', 'Ireland', 'Saved head of Irish Farmer\'s Association from terrorist cell', 'Super-Oinks', NULL, NULL)
  , ('Señor Mediocre', 'Mexico', 'Defeated corrupt convention of fruit lobbyists by telling anecdote that lasted 33 hours, with 16 tangents that lead to 17 resignations from the board', 'Public speaking', 'Stamp collecting', 'Laser vision')
  , ('The CLAW', 'USA', 'Horrifically violent duel to the death with mass murdering super villain accidentally created art installation last valued at $14,450,000 by Sotheby\'s', 'Back scratching', 'Extendable arms', NULL)
  , ('Il Segreto', 'Italy', NULL, NULL, NULL, NULL)
  , ('Frosty Man', 'UK', 'Rescued a delegation of data engineers from a DevOps conference', 'Knows, by memory, 15 definitions of an obscure codex known as "the data mesh"', 'can copy and paste from StackOverflow with the blink of an eye', NULL)
;

-- View testing data
select * from TESTING_DATA;

-------------------------------
-- View with SUPERHERO_JSON

-- Create the view
create or replace view JSON_VIEW
as
select
  TO_JSON(
    OBJECT_CONSTRUCT(
        'country_of_residence', country_of_residence
      , 'superhero_name', superhero_name
      , 'superpowers', ARRAY_CONSTRUCT_COMPACT(
            superpower
          , second_superpower
          , third_superpower
        )
    )
  ) as superhero_json
from TESTING_DATA
;

-- Query the view
select * from JSON_VIEW;
