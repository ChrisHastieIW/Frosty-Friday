
-- Frosty Friday Challenge
-- 43 - Intermediate - JSON & Python Worksheets
-- https://frostyfriday.org/2023/04/28/week-43-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

create or replace schema WEEK_43;

use schema WEEK_43;

-------------------------------
-- Create table for challenge

create or replace table CHALLENGE_INPUT
as 
select
parse_json('{
  "company_name": "Superhero Staffing Inc.",
  "company_website": "https://www.superherostaffing.com",
  "location": {
    "address": "123 Hero Lane",
    "city": "Metropolis",
    "state": "Superstate",
    "zip": "98765",
    "country": "United Superlands"
  },
  "superheroes": [
    {
      "id": "1",
      "name": "Captain Incredible",
      "real_name": "John Smith",
      "powers": [
        "Super Strength",
        "Flight",
        "Invulnerability"
      ],
      "role": "CEO",
      "years_of_experience": 10
    },
    {
      "id": "2",
      "name": "Mystic Sorceress",
      "real_name": "Jane Doe",
      "powers": [
        "Magic",
        "Teleportation",
        "Telekinesis"
      ],
      "role": "CTO",
      "years_of_experience": 8
    },
    {
      "id": "3",
      "name": "Speedster",
      "real_name": "Jim Brown",
      "powers": [
        "Super Speed",
        "Time Manipulation",
        "Phasing"
      ],
      "role": "COO",
      "years_of_experience": 6
    },
    {
      "id": "4",
      "name": "Telepathic Titan",
      "real_name": "Sarah Johnson",
      "powers": [
        "Telepathy",
        "Mind Control",
        "Telekinesis"
      ],
      "role": "CFO",
      "years_of_experience": 9
    }
  ]
}
') as json;

-- View challenge input
select * from challenge_input;

-- Rest of challenge in 43b
