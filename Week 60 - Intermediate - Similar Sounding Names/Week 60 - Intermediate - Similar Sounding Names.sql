
-- Frosty Friday Challenge
-- Week 60 - Intermediate - Similar Sounding Names
-- https://frostyfriday.org/blog/2023/08/25/week-60-intermediate/

-------------------------------
-- Challenge code

with challenge_input as (
  select
      $1::varchar as "NAME"
  from values
      ('John Smith')
    , ('Jon Smyth')
    , ('Jane Doe')
    , ('Jan Do')
    , ('Michael Johnson')
    , ('Mike Johnson')
    , ('Sarah Williams')
    , ('Sara Williams')
    , ('Robert Brown')
    , ('Roberto Brown')
    , ('Emily White')
    , ('Emilie Whyte')
    , ('David Lee')
    , ('Davey Li')
)
, challenge_input_numbered as (
  select
      -- Generate a row number without changing the order
      row_number() over (order by seq8()) as "ROW_NUMBER"
    , "NAME"
  from challenge_input
)
select
    l."ROW_NUMBER" as "ROW_TO_CHECK"
  , r."ROW_NUMBER" as "ROW_CHECKED_AGAINST"
  , l."NAME" as "NAME_TO_CHECK"
  , r."NAME" as "NAME_CHECKED_AGAINST"
  , soundex(l."NAME") = soundex(r."NAME") as "SOUNDS_SIMILAR"
from challenge_input_numbered as l
  cross join challenge_input_numbered as r
where l."ROW_NUMBER" < r."ROW_NUMBER"
;
