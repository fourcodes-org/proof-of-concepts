_snowflake docs_


_DEFAULT ROLES_

```conf
1.ACCOUNTADMIN
2.ORGADMIN
3.PUBLIC
4.SECURITYADMIN
5.SYSADMIN
6.USERADMIN
```

_create the warehouse_

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

_Create the database in the name of `COOKBOOK`_

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


_create the secondry admin  use_

```sql
USE ROLE SECURITYADMIN;

CREATE USER SECONDARY_ACCOUNT_ADMIN 
PASSWORD = 'password123' 
DEFAULT_ROLE = "ACCOUNTADMIN" 
MUST_CHANGE_PASSWORD = TRUE;

GRANT ROLE "ACCOUNTADMIN" TO USER SECONDARY_ACCOUNT_ADMIN;
```


_view existing roles_

![image](https://github.com/januo-org/proof-of-concepts/assets/57703276/0bcb8b7e-0128-4a8b-b021-f873c46a0ff7)
