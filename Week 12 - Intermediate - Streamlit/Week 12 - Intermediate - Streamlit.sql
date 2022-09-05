
-- Frosty Friday Challenge
-- Week 12 - Intermediate - Streamlit
-- https://frostyfriday.org/2022/09/02/week-12-intermediate/

-------------------------------
-- Environment Configuration

use database CH_FROSTY_FRIDAY;

use warehouse WH_CHASTIE;

-------------------------------
-- Create required objects

create or replace schema WEEK_12_world_bank_metadata;

create or replace table WEEK_12_world_bank_metadata.country_metadata
(
    country_code varchar(3),
    region string,
    income_group string
);

create or replace schema WEEK_12_world_bank_economic_indicators;

create or replace table WEEK_12_world_bank_economic_indicators.gdp
(
    country_name string,
    country_code varchar(3),
    year int,
    gdp_usd double
);

create or replace table WEEK_12_world_bank_economic_indicators.gov_expenditure
(
    country_name string,
    country_code varchar(3),
    year int,
    gov_expenditure_pct_gdp double
);

create or replace schema WEEK_12_world_bank_social_indiactors;

create or replace table WEEK_12_world_bank_social_indiactors.life_expectancy
(
    country_name string,
    country_code varchar(3),
    year int,
    life_expectancy float
);

create or replace table WEEK_12_world_bank_social_indiactors.adult_literacy_rate
(
    country_name string,
    country_code varchar(3),
    year int,
    adult_literacy_rate float
);

create or replace table WEEK_12_world_bank_social_indiactors.progression_to_secondary_school
(
    country_name string,
    country_code varchar(3),
    year int,
    progression_to_secondary_school float
);