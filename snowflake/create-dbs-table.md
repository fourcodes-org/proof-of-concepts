'''sql
USE ROLE ACCOUNTADMIN;
-- create first database which will contain the data to be shared
CREATE DATABASE C7_R3;

-- creation of a table which will hold the customer data.
CREATE TABLE CUSTOMER
(
  CUST_ID NUMBER,
  CUST_NAME STRING
);

-- if you like you can populate this table with a thousand rows of dummy data 
INSERT INTO CUSTOMER
SELECT
    SEQ8() AS CUST_ID,
	RANDSTR(10,RANDOM()) AS CUST_NAME
FROM TABLE(GENERATOR(ROWCOUNT => 1000));


-- create a new share object
CREATE SHARE share_cust_database;

-- grant usage on the database & schema containging the view
GRANT USAGE ON DATABASE C7_R3 TO SHARE share_cust_database;
GRANT USAGE ON SCHEMA C7_R3.public TO SHARE share_cust_database;

-- grant select on all tables that exist in the database's pubic schema
GRANT SELECT ON ALL TABLES IN SCHEMA C7_R3.public TO SHARE share_cust_database;

-- allow consumer account access on the Share
-- to find the consumer_account_number look at the URL of the snowflake
-- instance of the consumer. So if the URL is https://drb98231.us-east-1.snowflakecomputing.com/console#/internal/worksheet
-- the consumer account_number is drb98231
ALTER SHARE share_cust_database ADD ACCOUNT=<consumer_account_name_here>;

-- describe the share to see what is contained in the share
DESC SHARE share_cust_database;



_create another table and share_


```sql
USE ROLE ACCOUNTADMIN;
USE C7_R3;
-- creation of another table which will hold the customer address data.
CREATE TABLE CUSTOMER_ADDRESS
(
  CUST_ID NUMBER,
  CUST_ADDRESS STRING
);

-- Optionally if you like you can populate this table with a thousand rows of dummy data 
INSERT INTO CUSTOMER_ADDRESS
SELECT
    SEQ8() AS CUST_ID,
	RANDSTR(50,RANDOM()) AS CUST_ADDRESS
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

-- describe the share to see what is contained in the share
DESC SHARE share_cust_database;

-- redo grant select on ALL tables that exist in the database's pubic schema
-- to accomodate the newly created table
-- you can run the below command in a Task on a schedule to ensure
-- any new objects added in the shared database are automatically granted to the share object
GRANT SELECT ON ALL TABLES IN SCHEMA C7_R3.public TO SHARE share_cust_database;


--Let us again check if the new table is now added to the share. 
DESC SHARE share_cust_database;

```
