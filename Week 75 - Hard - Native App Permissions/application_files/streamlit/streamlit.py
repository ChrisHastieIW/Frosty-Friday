import streamlit as st
from snowflake.snowpark.context import get_active_session
import snowflake.permissions as permissions
from sys import exit

st.set_page_config(layout="wide")
session = get_active_session()

if hasattr(st.session_state, "permission_granted") \
  and st.session_state["permission_granted"] == True \
    :
  pass
else:
  # If not, trigger the table referencing process
  if permissions.get_reference_associations("target_table") is None \
    or len(permissions.get_reference_associations("target_table")) == 0 \
      :
    st.error("The app needs requires a reference to a target table") 
    permissions.request_reference("target_table")

  # And add a variable in the session to mark that this is done
  else:
    st.session_state["permission_granted"] = True

if not permissions.get_held_account_privileges(["CREATE DATABASE"]):
  st.error("The app needs CREATE DATABASE privileges")
  permissions.request_account_privileges(["CREATE DATABASE"])

st.title("FrostyPermissions!")

check = st.button('Shall we check we have what we need?')
if check:
  if permissions.get_held_account_privileges(["CREATE DATABASE"]) \
    and hasattr(st.session_state, "permission_granted") \
    and st.session_state["permission_granted"] == True \
      : # check for permissions again
    st.success("Yup! Looks like we've got all the permissions we need")
