
-------------------------------
-- Environment Configuration

create application role if not exists "APP_PUBLIC";

-------------------------------
-- Streamlit Interface

create or alter versioned schema "STREAMLIT";
grant usage on schema "STREAMLIT" to application role "APP_PUBLIC";

create streamlit "STREAMLIT"."STREAMLIT_INTERFACE"
  from '/streamlit'
  main_file = '/streamlit_interface.py'
;

grant usage on streamlit "STREAMLIT"."STREAMLIT_INTERFACE" to application role "APP_PUBLIC";

-------------------------------
-- Data to be accessed

create or alter versioned schema "APP_DATA";
grant usage on schema "APP_DATA" to application role "APP_PUBLIC";

create view if not exists "APP_DATA"."CHALLENGE_DATA"
as
select
    "RAW_JSON":"country"::string as "COUNTRY"
  , "RAW_JSON":"density"::float as "DENSITY"
  , "RAW_JSON":"pop2023"::int as "POPULATION_2023"
from "SHARED_DATA"."CHALLENGE_DATA_RAW"
;

grant select on view "APP_DATA"."CHALLENGE_DATA" to application role "APP_PUBLIC";
