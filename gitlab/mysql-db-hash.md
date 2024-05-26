

```yml

.mysql-schema-hash-calculator:
  variables:
    CI_PIPELINE_NAME: ${CI_PROJECT_TITLE}
    CI_PROJECT_NAME: ${CI_PROJECT_NAME}
    CI_PIPELINE_ID: ${CI_PIPELINE_ID}
    CI_PROJECT_URL: ${CI_PROJECT_URL}
    CI_PIPELINE_URL: ${CI_PIPELINE_URL}
    MYSQL_SCHEMA_HASH_VALUE: ""
    SCHEMA_VALIDATION_ENANBLED: "false"
  script:
    - |
      python3 - <<EOF
      import mysql.connector
      from mysql.connector import Error
      import hashlib
      import logging
      import os
      import sys

      class CustomLogger:
          def __init__(self, name, debug=False):
              self.logger = logging.getLogger(name)
              if not self.logger.hasHandlers():
                  self.logger.setLevel(logging.DEBUG if debug else logging.INFO)
                  formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
                  console_handler = logging.StreamHandler()
                  console_handler.setFormatter(formatter)
                  console_handler.setLevel(logging.DEBUG if debug else logging.INFO)
                  self.logger.addHandler(console_handler)
              self.debug = debug

          def get_logger(self):
              return self.logger

      class MySQLSchemaHasher:
          def __init__(self, host, database, user, password, logger):
              self.host = host
              self.database = database
              self.user = user
              self.password = password
              self.logger = logger

          def connect_to_database(self):
              try:
                  connection = mysql.connector.connect(
                      host=self.host,
                      database=self.database,
                      user=self.user,
                      password=self.password
                  )
                  if connection.is_connected():
                      self.logger.info("Connected to the database")
                      return connection
              except Error as e:
                  self.logger.error(f"Error: {e}")
                  return None

          def close_connection(self, connection):
              if connection is not None and connection.is_connected():
                  connection.close()
                  self.logger.info("Connection closed")

          def fetch_schema(self):
              connection = self.connect_to_database()
              if connection is None:
                  self.logger.error("Not connected to the database")
                  return None

              try:
                  cursor = connection.cursor()
                  cursor.execute("SHOW TABLES")
                  tables = cursor.fetchall()

                  schema_lines = []
                  for (table_name,) in tables:
                      schema_lines.append(f"Table: {table_name}")
                      cursor.execute(f"SHOW COLUMNS FROM {table_name}")
                      columns = cursor.fetchall()
                      for column in columns:
                          schema_lines.append(f"  Column: {column[0]}, Type: {column[1]}, Null: {column[2]}, Key: {column[3]}, Default: {column[4]}, Extra: {column[5]}")

                  cursor.close()
                  self.close_connection(connection)
                  return '\n'.join(schema_lines)
              except Error as e:
                  self.logger.error(f"Error: {e}")
                  self.close_connection(connection)
                  return None

          def create_hash(self, data):
              return hashlib.sha256(data.encode()).hexdigest()

          def get_schema_hash(self):
              schema = self.fetch_schema()
              if schema:
                  return self.create_hash(schema)
              return None

      if __name__ == "__main__":
          logger = CustomLogger(name='MySQLSchemaHasher', debug=False).get_logger()
          mysql_schema_hasher = MySQLSchemaHasher(
              host=os.getenv('MYSQL_HOST'),
              database=os.getenv('MYSQL_DATABASE'),
              user=os.getenv('MYSQL_USER'),
              password=os.getenv('MYSQL_PASSWORD'),
              logger=logger
          )
          schema_hash = mysql_schema_hasher.get_schema_hash()

          print(f"Current hash value is: {schema_hash}")

          SCHEMA_HASH_VALUE = os.environ.get("MYSQL_SCHEMA_HASH_VALUE")

          SCHEMA_VALIDATION_ENANBLED_STATUS = os.environ.get("SCHEMA_VALIDATION_ENANBLED")
          
          print(os.environ.get("MYSQL_SCHEMA_HASH_VALUE"))

          if SCHEMA_VALIDATION_ENANBLED_STATUS == "true":
              if SCHEMA_HASH_VALUE == "":
                  print("Environment variable MYSQL_SCHEMA_HASH_VALUE is not set or is empty.")
                  sys.exit(1)
              else:
                  if SCHEMA_HASH_VALUE == schema_hash:
                      print(f"Schema validation completed and  current hash value is: {schema_hash}")
                  else:
                      sys.exit(1)
          else:
              print(f"SCHEMA_VALIDATION_ENANBLED is disabled")
      EOF
```
