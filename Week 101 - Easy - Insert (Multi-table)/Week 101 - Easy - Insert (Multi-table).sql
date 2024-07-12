
-- Frosty Friday Challenge
-- Week 101 - Easy - Insert (Multi-table)
-- https://frostyfriday.org/blog/2024/07/12/week-101-easy/

-------------------------------
-- Environment Configuration

use database "CH_FROSTY_FRIDAY";

use warehouse "WH_CHASTIE";

create or replace schema "WEEK_101";

use schema "WEEK_101";

-------------------------------
-- Challenge Setup Script

-- Creating the destination tables TARGET_1 and TARGET_2
create or replace table "TARGET_1" (
    "PIRATE_NAME" string
  , "BOOTY_AMOUNT" number
  , "RANK" string
  , "SHIP_NAME" string
)
;

create or replace table "TARGET_2" (
    "PIRATE_NAME" string
  , "BOOTY_AMOUNT" number
  , "RANK" string
  , "SHIP_NAME" string
)
;

-- Creating the source table SOURCE with pirate-themed data
create or replace table "SOURCE" (
    "PIRATE_NAME" string
  , "BOOTY_AMOUNT" number
  , "RANK" string
  , "SHIP_NAME" string
)
as
select * from values
    ('Blackbeard', 500, 'Captain', 'Queen Anne\'s Revenge')
  , ('Anne Bonny', 300, 'First Mate', 'Revenge')
  , ('Calico Jack', 200, 'Captain', 'Ranger')
  , ('Henry Morgan', 1000, 'Admiral', 'Oxford')
  , ('Bartholomew Roberts', 400, 'Captain', 'Royal Fortune')
  , ('Mary Read', 150, 'Quartermaster', 'Ranger')
  , ('Stede Bonnet', 50, 'Captain', 'Revenge')
  , ('Charles Vane', 250, 'Captain', 'Lark')
  , ('Jack Sparrow', 800, 'Captain', 'Black Pearl')
  , ('William Kidd', 600, 'Captain', 'Adventure Galley')
;

-------------------------------
-- Challenge Solution

-- Multi-table insert
-- using overwrite for idempotence
insert overwrite all
  when "BOOTY_AMOUNT" > 700
    then into "TARGET_1"
  when "RANK" = 'First Mate'
    then into "TARGET_2"
  when "BOOTY_AMOUNT" < 100
    then
      into "TARGET_1"
      into "TARGET_2"
  else
      into "TARGET_2"
select *
from "SOURCE"
;

-- Validation
select * from "SOURCE";
select * from "TARGET_1";
select * from "TARGET_2";
