CREATE ROLE jino WITH LOGIN NOSUPERUSER INHERIT CREATEDB CREATEROLE NOREPLICATION PASSWORD 'Pass@123!>';
GRANT azure_pg_admin TO jino;
CREATE DATABASE mydb;
GRANT CONNECT ON DATABASE mydb TO jino;

psql -h dodo-psql-server.postgres.database.azure.com -U 'dodo@dodo-psql-server' -d postgres
Password@123

