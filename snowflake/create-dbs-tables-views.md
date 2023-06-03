-- create first database which will contain the customer table
CREATE DATABASE C7_R2_DB1;

-- creation of a table which will hold the customer data.
CREATE TABLE CUSTOMER
(
  CUST_ID NUMBER,
  CUST_NAME STRING
);

--populate this table with a thousand rows of dummy data 
INSERT INTO CUSTOMER
SELECT
    SEQ8() AS CUST_ID,
	RANDSTR(10,RANDOM()) AS CUST_NAME
FROM TABLE(GENERATOR(ROWCOUNT => 1000));


-- create second database which will contain the customer address table
CREATE DATABASE C7_R2_DB2;

-- creation of a table which will hold the customer address data.
CREATE TABLE CUSTOMER_ADDRESS
(
  CUST_ID NUMBER,
  CUST_ADDRESS STRING
);

--populate this table with thousand rows of dummy data 
INSERT INTO CUSTOMER_ADDRESS
SELECT
    SEQ8() AS CUST_ID,
	RANDSTR(50,RANDOM()) AS CUST_ADDRESS
FROM TABLE(GENERATOR(ROWCOUNT => 1000));


-- create a seprate database which will contain a view that joins 
-- the customer & the customer address table
CREATE DATABASE VIEW_SHR_DB;

-- create a view joining customer and customer address table
-- notice the view has to be created as a Secure View since
-- only Secure Views can be shared
CREATE SECURE VIEW CUSTOMER_INFO AS
SELECT CUS.CUST_ID, CUS.CUST_NAME, CUS_ADD.CUST_ADDRESS 
FROM C7_R2_DB1.PUBLIC.CUSTOMER CUS
INNER JOIN C7_R2_DB2.PUBLIC.CUSTOMER_ADDRESS CUS_ADD
ON CUS.CUST_ID = CUS_ADD.CUST_ID;

-- Validate that the view is working
SELECT * FROM CUSTOMER_INFO;






_create share_

```sql
-- create a new share object
USE ROLE ACCOUNTADMIN;
CREATE SHARE share_cust_data;

-- grant usage on the database & schema containging the view
GRANT USAGE ON DATABASE VIEW_SHR_DB TO SHARE share_cust_data;
GRANT USAGE ON SCHEMA VIEW_SHR_DB.public TO SHARE share_cust_data;

-- we must grant reference_usage on all databases that contain the
-- tables that are used in the view
GRANT REFERENCE_USAGE ON DATABASE C7_R2_DB1 TO SHARE share_cust_data;
GRANT REFERENCE_USAGE ON DATABASE C7_R2_DB2 TO SHARE share_cust_data;

-- grant selct on the customer_info view to the share object
GRANT SELECT ON TABLE VIEW_SHR_DB.public.CUSTOMER_INFO TO SHARE share_cust_data;

-- allow consumer account access on the Share
-- to find the consumer_account_number look at the URL of the snowflake
-- instance of the consumer. So if the URL is https://drb98231.us-east-1.snowflakecomputing.com/console#/internal/worksheet
-- the consumer account_number is drb98231
ALTER SHARE share_cust_data ADD ACCOUNT=<consumer_account_name_here>;


```

_consume share_

```sql
-- List the inbound and outbound shares that are currently present in the system
USE ROLE ACCOUNTADMIN;
SHOW SHARES;

-- Find the share details by running describe. 
-- Always use provider_account.share_name
DESC SHARE <provider_account_name_here>.SHARE_CUST_DATA;

-- create a database in consumer snowflake instance based on the share.
CREATE DATABASE SHR_CUSTOMER FROM SHARE <provider_account_name_here>.SHARE_CUST_DATA;

-- Rerun a describe again to validate that the 
-- database has correctly been attached to the share
-- Always use provider_account.share_name
DESC SHARE <provider_account_name_here>.SHARE_CUST_DATA;

-- validate that you can select from the shared view
SELECT * FROM SHR_CUSTOMER.PUBLIC.CUSTOMER_INFO;


```