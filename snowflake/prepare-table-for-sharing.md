
```sql
CREATE DATABASE C7_R1;

-- creation of a table which will hold the transaction data.
CREATE TABLE TRANSACTIONS
(
  TXN_ID STRING,
  TXN_DATE DATE,
  CUSTOMER_ID STRING,
  QUANTITY DECIMAL(20),
  PRICE DECIMAL(30,2),
  COUNTRY_CD STRING
);

--populate this table with thousand rows of dummy data 
INSERT INTO TRANSACTIONS
SELECT
    UUID_STRING() AS TXN_ID
    ,DATEADD(DAY,UNIFORM(1, 500, RANDOM()) * -1, '2020-10-15') AS TXN_DATE
    ,UUID_STRING() AS CUSTOMER_ID
    ,UNIFORM(1, 10, RANDOM()) AS QUANTITY
    ,UNIFORM(1, 200, RANDOM()) AS PRICE
    ,RANDSTR(2,RANDOM()) AS COUNTRY_CD
FROM TABLE(GENERATOR(ROWCOUNT => 1000));
```

_create share_

```sql
-- You will need to use the ACCOUNTADMIN role to create the share
USE ROLE ACCOUNTADMIN;
CREATE SHARE share_trx_data;

-- grant usage on the database & the schema in which our table is contained
-- this step is necessary to subsequently provide access to the table
GRANT USAGE ON DATABASE C7_R1 TO SHARE share_trx_data;
GRANT USAGE ON SCHEMA C7_R1.public TO SHARE share_trx_data;

-- add the transaction table to the share
-- We have provided SELECT permissions on the shared table so the consumer can 
GRANT SELECT ON TABLE C7_R1.public.transactions TO SHARE share_trx_data;

-- allow consumer account access on the Share
-- to find the consumer_account_number look at the URL of the snowflake
-- instance of the consumer. So if the URL is https://drb98231.us-east-1.snowflakecomputing.com/console#/internal/worksheet
-- the consumer account_number is drb98231
ALTER SHARE share_trx_data ADD ACCOUNT=<consumer_account_name_here>;
```

_consume share_


```sql
-- List the inbound and outbound shares that are currently present in the system
USE ROLE ACCOUNTADMIN;
SHOW SHARES;

-- Find the share details by running describe. 
-- Always use provider_account.share_name
DESC SHARE <provider_account_name_here>.SHARE_TRX_DATA;


-- create a database in consumer snowflake instance based on the share.
CREATE DATABASE SHR_TRANSACTIONS FROM SHARE <provider_account_name_here>.SHARE_TRX_DATA;


--validate that the database is attached to the share.
DESC SHARE <provider_account_name_here>.SHARE_TRX_DATA;


-- query the table to confirm you can select data as a consumer
SELECT * FROM SHR_TRANSACTIONS.PUBLIC.TRANSACTIONS;
```