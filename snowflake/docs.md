
_create warehouse_


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

_manage db schema and tables_

```sql

CREATE DATABASE IF NOT EXISTS gino;

USE DATABASE gino;

CREATE schema if not exists users;

-- # switch to schema
USE schema users;
USE gino.users;

-- # create the new table
CREATE TABLE if not exists users.customers (
  id              INT NOT NULL,
  last_name       VARCHAR(100) ,
  first_name      VARCHAR(100),
  email           VARCHAR(100),
  company         VARCHAR(100),
  phone           VARCHAR(100),
  address1        VARCHAR(150),
  address2        VARCHAR(150),
  city            VARCHAR(100),
  state           VARCHAR(100),
  postal_code     VARCHAR(15),
  country         VARCHAR(50)
);

-- # clone the existing schemas
CREATE SCHEMA ADD_USERS CLONE USERS;

-- # list the all schemas under the db
SHOW SCHEMAS;

-- # switch to schema
use schema ADD_USERS;

-- # clone the existing db
CREATE DATABASE add_gino CLONE gino;

-- clone the existing table 
CREATE TABLE add_customers CLONE customers;
```
