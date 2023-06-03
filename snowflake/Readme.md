_snowflake docs_

**_Snowflake Architecture_**

Snowflake’s architecture is a hybrid of traditional shared-disk and shared-nothing database architectures. Similar to shared-disk architectures, Snowflake uses a central data repository for persisted data that is accessible from all compute nodes in the platform. But similar to shared-nothing architectures, Snowflake processes queries using MPP (massively parallel processing) compute clusters where each node in the cluster stores a portion of the entire data set locally. This approach offers the data management simplicity of a shared-disk architecture, but with the performance and scale-out benefits of a shared-nothing architecture.

![image](https://github.com/januo-org/proof-of-concepts/assets/57703276/2d147070-db49-4793-85f7-6c97e2c5073b)


**_Snowflake’s unique architecture consists of three key layers:_**

1. Database Storage
2. Query Processing
3. Cloud Services

**_Database Storage_**

When data is loaded into Snowflake, Snowflake reorganizes that data into its internal optimized, compressed, columnar format. Snowflake stores this optimized data in cloud storage.

Snowflake manages all aspects of how this data is stored — the organization, file size, structure, compression, metadata, statistics, and other aspects of data storage are handled by Snowflake. The data objects stored by Snowflake are not directly visible nor accessible by customers; they are only accessible through SQL query operations run using Snowflake.

**_Query Processing_**

Query execution is performed in the processing layer. Snowflake processes queries using “virtual warehouses”. Each virtual warehouse is an MPP compute cluster composed of multiple compute nodes allocated by Snowflake from a cloud provider.

Each virtual warehouse is an independent compute cluster that does not share compute resources with other virtual warehouses. As a result, each virtual warehouse has no impact on the performance of other virtual warehouses.

**_Cloud Services_**

The cloud services layer is a collection of services that coordinate activities across Snowflake. These services tie together all of the different components of Snowflake in order to process user requests, from login to query dispatch. The cloud services layer also runs on compute instances provisioned by Snowflake from the cloud provider.

**_Services managed in this layer include:_**

1. Authentication
2. Infrastructure management
3. Metadata management
4. Query parsing and optimization
5. Access control


**_default roles_**

```conf
1.ACCOUNTADMIN
2.ORGADMIN
3.PUBLIC
4.SECURITYADMIN
5.SYSADMIN
6.USERADMIN
```

_view existing roles_

```sql
SHOW ROLES;
```
![image](https://github.com/januo-org/proof-of-concepts/assets/57703276/0bcb8b7e-0128-4a8b-b021-f873c46a0ff7)

**_create the warehouse_**

A virtual warehouse, often referred to simply as a “warehouse”, is a cluster of compute resources in Snowflake. Virtual warehouses are required when performing select or other operations requiring compute resources.


A SQL worksheet should be made to carry out the SQL statement to create the SQL `WAREHOUSE`.

```sql
USE ROLE SYSADMIN;

CREATE WAREHOUSE ETL_WH
WAREHOUSE_SIZE = XSMALL
MAX_CLUSTER_COUNT = 3
MIN_CLUSTER_COUNT = 1
SCALING_POLICY = ECONOMY
AUTO_SUSPEND = 300 -- suspend after 5 minutes (300 seconds) of inactivity
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE
COMMENT = 'Virtual Warehouse for ETL workloads. Auto scales between 1 and 3 clusters depending on the workload';
```

**_Create the database in the name of `COOKBOOK`_**

```sql
CREATE DATABASE COOKBOOK;

USE DATABASE COOKBOOK;
CREATE TABLE MY_FIRST_TABLE
(
    ID STRING,
    NAME STRING
);

SELECT * FROM MY_FIRST_TABLE;
```

In the navigation pane, choose `Data`. Choose `Database`. you may see your database name `COOKBOOK`

![image](https://github.com/januo-org/proof-of-concepts/assets/57703276/9c8bf151-c972-4152-888c-7fc506615c7f)


_create the secondry admin user to login from web console_

```sql
USE ROLE SECURITYADMIN;

CREATE USER SECONDARY_ACCOUNT_ADMIN 
PASSWORD = 'password123' 
DEFAULT_ROLE = "ACCOUNTADMIN" 
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE "ACCOUNTADMIN" TO USER SECONDARY_ACCOUNT_ADMIN;
```


_manage database_

```sql
# use the system admin role
USE ROLE SYSADMIN;

# create the development database
CREATE DATABASE development_database COMMENT = 'This is development database';

# Show databases
SHOW DATABASES LIKE 'development_database';

# create the production database
CREATE DATABASE production_database DATA_RETENTION_TIME_IN_DAYS = 15 COMMENT = 'This is critical production database';

# Show databases
SHOW DATABASES LIKE 'production_database';

# create the temporary database
CREATE TRANSIENT DATABASE temporary_database  DATA_RETENTION_TIME_IN_DAYS = 0 COMMENT = 'Temporary database for ETL processing';

# Show databases
SHOW DATABASES LIKE 'temporary_database';

# If you want to change the temporary database data retention you may execute the command
ALTER DATABASE temporary_database SET DATA_RETENTION_TIME_IN_DAYS = 1;

# Show databases
SHOW DATABASES LIKE 'temporary_database';
```
