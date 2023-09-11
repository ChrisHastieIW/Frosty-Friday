
# Frosty Friday Week 62 - Intermediate - Native Apps

The original challenge can be found [here](https://frostyfriday.org/blog/2023/09/08/week-62-intermediate/).

## Deployment

To deploy this solution to your own environment, leverage the following files in the `deployment_files` subdirectory:

- `0 - preparation.sql` - Leverages the standard role for Frosty Friday challenges to create the file format and stage that contains the files for the application
- `1 - deployment.sql` - Leverages an elevated APPLICATION_ADMIN role to deploy the application package and the native application
