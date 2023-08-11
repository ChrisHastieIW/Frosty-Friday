
-- Frosty Friday Challenge
-- Week 58 - Basic - replace select
-- https://frostyfriday.org/2023/08/11/week-58-basic/

-------------------------------
-- Challenge code

with measurements as (
  select
      $1::int as HEIGHT
    , $2::int as WEIGHT
    , $3::int as AGE
    , $4::varchar as GENDER
    , $5::int as ID
  from values
      (41, 178, 74, 'other', 1)
    , (188, 145, 87, 'other', 2)
    , (215, 725, 30, 'male', 3)
    , (159, 48, 116, 'female', 4)
    , (243, 204, 6, 'other', 5)
    , (232, 306, 30, 'male', 6)
    , (261, 602, 62, 'other', 7)
    , (143, 829, 113, 'female', 8)
    , (62, 190, 86, 'male', 9)
    , (249, 15, 73, 'male', 10)
)
select
    * replace(
        AGE - 1 as AGE
      , WEIGHT::float * 1.1 as WEIGHT
      , iff(GENDER = 'other', 'unknown', GENDER) as GENDER
    )
from measurements
;
