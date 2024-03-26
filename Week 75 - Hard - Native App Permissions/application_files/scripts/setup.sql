create application role if not exists app_role;
create or alter versioned schema app_schema;
grant usage on schema app_schema to application role app_role;
create or replace streamlit app_schema.streamlit from '/streamlit' main_file='streamlit.py';

-------------------------------
-- App Config

create or replace procedure "APP_SCHEMA"."UPDATE_REFERENCE"(REF_NAME string, OPERATION string, REF_OR_ALIAS string)
  returns string
  language SQL
  as
	$$
    BEGIN
      case (OPERATION)
        when 'ADD' then
          select system$set_reference(:REF_NAME, :REF_OR_ALIAS);
        when 'REMOVE' then
          select system$remove_reference(:REF_NAME);
        when 'CLEAR' then
          select system$remove_reference(:REF_NAME);
      else
        return 'unknown operation: ' || OPERATION;
      end case;
      return NULL;
    END;
  $$
;

grant usage on streamlit app_schema.streamlit to application role app_role;
grant usage on procedure app_schema.update_reference(string, string, string) to application role app_role;
