
-- Frosty Friday Challenge
-- Week 69 - Intermediate - Snowflake Mystery Functions
-- https://frostyfriday.org/blog/2023/10/27/week-69-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_69;

use schema WEEK_69;

-------------------------------
-- Create challenge data

create or replace table CHALLENGE_DATA(
    SENTENCE_1 varchar
  , SENTENCE_2 varchar
)
as
select *
from values
    ('The cat sat on the', 'The cat sat on thee')
  , ('Rainbows appear after rain', 'Rainbows appears after rain')
  , ('She loves chocolate chip cookies', 'She love chocolate chip cookies')
  , ('Birds fly high in the', 'Birds flies high in the')
  , ('The sun sets in the', 'The sun set in the')
  , ('I really like that song', 'I really liked that song')
  , ('Dogs are truly best friends', 'Dogs are truly best friend')
  , ('Books are a source of', 'Book are a source of')
  , ('The moon shines at night', 'The moons shine at night')
  , ('Walking is good for health', 'Walking is good for the health')
  , ('Children love to play', 'Children love to play')
  , ('Music is a universal language', 'Music is a universal language')
  , ('Winter is coming soon', 'Winter is coming soon')
  , ('Happiness is a choice', 'Happiness is a choice')
  , ('Travel broadens the mind', 'Travel broadens the mind')
  , ('Dogs are our closest companions', 'Cats are solitary creatures')
  , ('Books are portals to new worlds', 'Movies depict various realities')
  , ('The moon shines brightly at night', 'The sun blazes hotly at noon')
  , ('Walking is beneficial for health', 'Running can be hard on knees')
  , ('Children love to play outside', 'Children love to play')
  , ('Music transcends cultural boundaries', 'Music is a universal language')
  , ('Winter is cold and snowy', 'Winter is coming soon')
  , ('Happiness comes from within', 'Happiness is a choice')
  , ('Traveling opens up perspectives', 'Travel broadens the mind')
;

-- View challenge data
select * from CHALLENGE_DATA;

-------------------------------
-- Challenge output view

-- Create the view
create or replace view CHALLENGE_OUTPUT
as
select
    SENTENCE_1
  , SENTENCE_2
  , jarowinkler_similarity(SENTENCE_1, SENTENCE_2) as SCORE
from CHALLENGE_DATA
;

-- Query the view
select * from CHALLENGE_OUTPUT
order by SCORE desc
;
