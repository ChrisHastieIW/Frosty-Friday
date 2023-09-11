
-------------------------------
-- Environment Configuration

create application role "APP_PUBLIC";
create or alter versioned schema "STREAMLIT";
grant usage on schema "STREAMLIT" to application role "APP_PUBLIC";

-------------------------------
-- Streamlit Interface

create streamlit "STREAMLIT"."STREAMLIT_INTERFACE"
  from '/streamlit'
  main_file = '/streamlit_interface.py'
;

grant usage on streamlit "STREAMLIT"."STREAMLIT_INTERFACE" to application role "APP_PUBLIC";