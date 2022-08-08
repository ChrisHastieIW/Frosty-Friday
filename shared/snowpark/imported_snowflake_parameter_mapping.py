
# Mapping to determine how imported parameters
# from local JSON or Streamlit secrets should
# be ingested
imported_snowflake_parameter_mapping = [
    {
        "parameter_imported_name" : "account"
      , "parameter_snowflake_name" : "account"
      , "parameter_placeholder_value" : "<account>[.<region>][.<cloud provider>]"
      , "parameter_required_flag" : 1
    }
  , {
        "parameter_imported_name" : "user"
      , "parameter_snowflake_name" : "user"
      , "parameter_placeholder_value" : "<username>"
      , "parameter_required_flag" : 1
    }
  , {
        "parameter_imported_name" : "default_role"
      , "parameter_snowflake_name" : "role"
      , "parameter_placeholder_value" : "<default role>"
      , "parameter_required_flag" : 0
    }
  , {
        "parameter_imported_name" : "default_warehouse"
      , "parameter_snowflake_name" : "warehouse"
      , "parameter_placeholder_value" : "<default warehouse>"
      , "parameter_required_flag" : 0
    }
  , {
        "parameter_imported_name" : "default_database"
      , "parameter_snowflake_name" : "database"
      , "parameter_placeholder_value" : "<default database>"
      , "parameter_required_flag" : 0
    }
  , {
        "parameter_imported_name" : "default_schema"
      , "parameter_snowflake_name" : "schema"
      , "parameter_placeholder_value" : "<default schema>"
      , "parameter_required_flag" : 0
    }
  , {
        "parameter_imported_name" : "password"
      , "parameter_snowflake_name" : "password"
      , "parameter_placeholder_value" : "<password>"
      , "parameter_required_flag" : 0
    }
  ]