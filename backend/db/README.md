# Database Migration Management with Flyway

This directory (`backend/db/`) contains the configuration and SQL migration scripts for the Affiliates application's database, managed with Flyway.

## Prerequisites

1.  **Install Flyway CLI**:
    *   Download the Flyway command-line tool from [flywaydb.org](https://flywaydb.org/documentation/usage/commandline#download-and-installation).
    *   Unzip the downloaded file to a location on your system.
    *   Add the directory where you unzipped Flyway to your system's `PATH` environment variable so you can run the `flyway` command from any location.

2.  **Configure Database Connection**:
    *   Edit the `flyway.conf` file located in this same directory (`backend/db/`).
    *   Complete the following fields with your Azure SQL Database details (you will get these values after deploying the infrastructure with Terraform or if you already have an existing database):
        *   `flyway.url`: The JDBC connection string for your Azure SQL Database. Example:
            `jdbc:sqlserver://<your-server>.database.windows.net:1433;databaseName=<your-database>;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;`
        *   `flyway.user`: The username to access the database (e.g., the `sql_admin_login` you configured in Terraform).
        *   `flyway.password`: The password for the database user.
            **SECURITY WARNING!** For production environments, do not store passwords in plain text directly in `flyway.conf`. Consider using environment variables. Flyway allows this, for example: `flyway.password=${env.FLYWAY_DB_PASSWORD}`. Then, you will need to define the `FLYWAY_DB_PASSWORD` environment variable on the system where you run Flyway.

## Migration Scripts

*   SQL migration scripts are located in the `migration/` subdirectory.
*   They must follow Flyway's naming convention: `V<VERSION>__<DESCRIPTION>.sql` (e.g., `V1__Create_Database.sql`, `V2__Add_Email_Index.sql`).
*   Flyway executes these scripts in order to apply changes to the database schema.

## Useful Flyway Commands

Run the following commands from this directory (`backend/db/`) in your terminal:

1.  **Info (`info`)**:
    Displays the status of all migrations (applied, pending, etc.). It's useful to see what has been executed and what is pending.
    ```powershell
    flyway info
    ```

2.  **Migrate (`migrate`)**:
    Applies all pending migrations to the database. This will update your database schema to the latest state defined by the scripts in `migration/`.
    ```powershell
    flyway migrate
    ```

3.  **Validate (`validate`)**:
    Compares applied migrations (recorded in your database's `flyway_schema_history` table) with local migration scripts. Helps detect inconsistencies.
    ```powershell
    flyway validate
    ```

4.  **Clean (`clean`)**:
    **WARNING!** This command will delete ALL objects (tables, views, etc.) in the schemas configured in `flyway.conf` (usually the `dbo` schema for SQL Server if no other is specified). It also deletes the `flyway_schema_history` table. **ONLY USE IN DEVELOPMENT OR TEST ENVIRONMENTS AND IF YOU KNOW WHAT YOU ARE DOING.**
    ```powershell
    flyway clean
    ```

5.  **Repair (`repair`)**:
    Repairs the `flyway_schema_history` table in case of problems with failed migrations that have left the metadata table in an inconsistent state.
    ```powershell
    flyway repair
    ```

## Typical Workflow

1.  Create a new SQL file in `migration/` with the desired schema changes (e.g., `V2__Add_New_Column.sql`).
2.  Run `flyway migrate` to apply the changes to your development database.
3.  Test your application with the changes.
4.  Once validated, these scripts will be applied in other environments (staging, production) as part of your deployment process.
