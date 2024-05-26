### schema validation

```py
import mysql.connector
from mysql.connector import Error 
import hashlib
import json
import os
import sys

class Dbversion:
    def __init__(self, host, database, user, password):
        self.host = host      
        self.database = database
        self.user = user        
        self.password = password

    def get_dbversion_report(self):
        report = ""
        try:
            connection = mysql.connector.connect(
                host=self.host, 
                database=self.database,                             
                user=self.user,
                password=self.password
            )

            if connection.is_connected():
                db_info = connection.get_server_info()
                # print(f"The MySQL server version is {db_info}")
                cursor = connection.cursor()
                cursor.execute("SELECT database();")
                record = cursor.fetchone()
                
                for queryName, queryStatement in self.sqls.items():         
                    queryStatement = queryStatement.replace("%schema_name", "'" + self.database + "' ")
                    cursor.execute(queryStatement)
                    rows = cursor.fetchall()
                    report = report + "--------------------------------------------" + "\r\n"
                    report = report + queryName + ":" + str(cursor.rowcount) +  "\r\n"
                    report = report + "--------------------------------------------" + "\r\n"
                    report = report + self.to_json(cursor, rows) + "\r\n" 
                    report = report + "\r\n\r\n"
                report = report.strip()          
        except Error as e:
            print("Error while connecting to MySQL", e)
        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
        return report

    def calculate_hash(self):
        algorithm='sha1'
        hash_object = hashlib.new(algorithm)
        hash_object.update(self.get_dbversion_report().encode())
        return hash_object.hexdigest()
    
    def to_json(self, cursor, rows):
        column_names = [description[0] for description in cursor.description]
        json_data = []
        for row in rows:
            row_dict = dict(zip(column_names, row))
            json_row = json.dumps(row_dict)
            json_data.append(json_row)
        return "\r\n".join(json_data)

    sqls = {
    "schema":
        """SELECT DISTINCT 
            sc.CATALOG_NAME,
            sc.SCHEMA_NAME,
            sc.DEFAULT_CHARACTER_SET_NAME,
            sc.DEFAULT_COLLATION_NAME,
            sc.DEFAULT_ENCRYPTION
        FROM 
            information_schema.schemata sc
        WHERE 
            sc.schema_name = %schema_name
        ORDER BY 
            sc.CATALOG_NAME,
            sc.SCHEMA_NAME,
            sc.DEFAULT_CHARACTER_SET_NAME,
            sc.DEFAULT_COLLATION_NAME,
            sc.DEFAULT_ENCRYPTION
        """, 
    "table":
        """SELECT DISTINCT 
            t.TABLE_CATALOG, 
            t.TABLE_SCHEMA, 
            t.TABLE_NAME, 
            t.TABLE_TYPE, 
            t.ENGINE, 
            t.ROW_FORMAT
        FROM 
            INFORMATION_SCHEMA.tables  t
        WHERE 
            t.table_schema = %schema_name and t.table_name  not like '\_\_%'
        ORDER BY 
            t.TABLE_CATALOG, 
            t.TABLE_SCHEMA, 
            t.TABLE_NAME, 
            t.TABLE_TYPE, 
            t.ENGINE, 
            t.ROW_FORMAT
        """, 
    "table_extension":
        """SELECT 
            te.TABLE_CATALOG,
            te.TABLE_SCHEMA,
            te.TABLE_NAME,
            te.ENGINE_ATTRIBUTE,
            te.SECONDARY_ENGINE_ATTRIBUTE
        FROM 
            information_schema.TABLES_EXTENSIONS te
        WHERE 
            te.TABLE_SCHEMA = %schema_name and te.TABLE_NAME not like '\_\_%'
        ORDER BY
            te.TABLE_CATALOG,
            te.TABLE_SCHEMA,
            te.TABLE_NAME,
            te.ENGINE_ATTRIBUTE,
            te.SECONDARY_ENGINE_ATTRIBUTE
        """,
    "column": 
        """SELECT DISTINCT
            c.TABLE_CATALOG, 
            c.TABLE_SCHEMA,    
            c.TABLE_NAME,    
            c.COLUMN_NAME,
            c.COLUMN_DEFAULT,
            c.IS_NULLABLE,
            c.DATA_TYPE,
            c.CHARACTER_MAXIMUM_LENGTH, 
            c.CHARACTER_OCTET_LENGTH, 
            c.NUMERIC_PRECISION, 
            c.NUMERIC_SCALE,
            c.DATETIME_PRECISION,
            c.CHARACTER_SET_NAME,
            c.COLLATION_NAME, 
            c.COLUMN_TYPE, 
            c.COLUMN_KEY,
            c.SRS_ID, 
            c.GENERATION_EXPRESSION
        FROM 
            INFORMATION_SCHEMA.COLUMNS c 
        WHERE 
            c.TABLE_SCHEMA = %schema_name and c.table_name not like '\_\_%' and c.column_name not like '\_\_%'
        ORDER BY 
            c.TABLE_CATALOG, 
            c.TABLE_SCHEMA,    
            c.TABLE_NAME,    
            c.COLUMN_NAME,
            c.COLUMN_DEFAULT,
            c.IS_NULLABLE,
            c.DATA_TYPE,
            c.CHARACTER_MAXIMUM_LENGTH, 
            c.CHARACTER_OCTET_LENGTH, 
            c.NUMERIC_PRECISION, 
            c.NUMERIC_SCALE,
            c.DATETIME_PRECISION,
            c.CHARACTER_SET_NAME,
            c.COLLATION_NAME, 
            c.COLUMN_TYPE, 
            c.COLUMN_KEY,    
            c.SRS_ID
        """, 
    "column_extension":
        """SELECT DISTINCT
            ce.TABLE_CATALOG, 
            ce.TABLE_SCHEMA, 
            ce.TABLE_NAME, 
            ce.COLUMN_NAME, 
            ce.ENGINE_ATTRIBUTE, 
            ce.SECONDARY_ENGINE_ATTRIBUTE
        FROM 
            information_schema.COLUMNS_EXTENSIONS ce
        WHERE 
            ce.table_schema = %schema_name and ce.table_name not like '\_\_%' and ce.column_name not like '\_\_%'
        ORDER BY 
            ce.TABLE_CATALOG, 
            ce.TABLE_SCHEMA, 
            ce.TABLE_NAME, 
            ce.COLUMN_NAME, 
            ce.ENGINE_ATTRIBUTE, 
            ce.SECONDARY_ENGINE_ATTRIBUTE
        """, 
    "constraint": 
        """SELECT DISTINCT 
            tc.CONSTRAINT_CATALOG, 
            tc.table_schema, 
            tc.table_name, 
            tc.CONSTRAINT_NAME, 
            tc.CONSTRAINT_TYPE, 
            tc.ENFORCED
        FROM  
            INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc 
        WHERE 
            tc.table_schema = %schema_name and tc.table_name not like '\_\_%'
        ORDER BY 
            tc.CONSTRAINT_CATALOG, 
            tc.table_schema, 
            tc.table_name, 
            tc.CONSTRAINT_NAME, 
            tc.CONSTRAINT_TYPE, 
            tc.ENFORCED
        """, 
    "check_constraint":
        """SELECT 
            cc.CONSTRAINT_CATALOG, 
            cc.CONSTRAINT_SCHEMA,
            cc.CONSTRAINT_NAME, 
            cc.CHECK_CLAUSE
        FROM 
            information_schema.check_constraints cc
        WHERE 
            cc.CONSTRAINT_SCHEMA = %schema_name
        ORDER BY 
            cc.CONSTRAINT_CATALOG, 
            cc.CONSTRAINT_SCHEMA,
            cc.CONSTRAINT_NAME
        """, 
    "referential_constraint":
        """SELECT DISTINCT 
            rc.CONSTRAINT_CATALOG,
            rc.CONSTRAINT_SCHEMA,
            rc.CONSTRAINT_NAME,
            rc.UNIQUE_CONSTRAINT_CATALOG,
            rc.UNIQUE_CONSTRAINT_SCHEMA,
            rc.UNIQUE_CONSTRAINT_NAME,	
            rc.TABLE_NAME,
            rc.REFERENCED_TABLE_NAME,
            rc.MATCH_OPTION,
            rc.UPDATE_RULE,
            rc.DELETE_RULE
        FROM 
            information_schema.REFERENTIAL_CONSTRAINTS rc
        WHERE 
            rc.CONSTRAINT_SCHEMA = %schema_name
        ORDER BY
            rc.CONSTRAINT_CATALOG,
            rc.CONSTRAINT_SCHEMA,
            rc.CONSTRAINT_NAME,
            rc.UNIQUE_CONSTRAINT_CATALOG,
            rc.UNIQUE_CONSTRAINT_SCHEMA,
            rc.UNIQUE_CONSTRAINT_NAME,	
            rc.TABLE_NAME,
            rc.REFERENCED_TABLE_NAME,
            rc.MATCH_OPTION,
            rc.UPDATE_RULE,
            rc.DELETE_RULE
        """, 
    "key_usage":
        """SELECT DISTINCT
            cu.CONSTRAINT_CATALOG, 
            cu.TABLE_SCHEMA, 
            cu.TABLE_NAME, 
            cu.COLUMN_NAME, 
            cu.constraint_name, 
            cu.POSITION_IN_UNIQUE_CONSTRAINT, 
            cu.REFERENCED_TABLE_SCHEMA, 
            cu.REFERENCED_TABLE_NAME, 
            cu.REFERENCED_COLUMN_NAME
        FROM 
            INFORMATION_SCHEMA.KEY_COLUMN_USAGE cu
        WHERE 
            cu.CONSTRAINT_SCHEMA = %schema_name and cu.TABLE_NAME not like '\_\_%' and cu.COLUMN_NAME not like '\_\_%'
        ORDER BY 
            cu.CONSTRAINT_CATALOG, 
            cu.TABLE_SCHEMA,  
            cu.TABLE_NAME, 
            cu.COLUMN_NAME, 
            cu.constraint_name, 
            cu.POSITION_IN_UNIQUE_CONSTRAINT, 
            cu.REFERENCED_TABLE_SCHEMA, 
            cu.REFERENCED_TABLE_NAME, 
            cu.REFERENCED_COLUMN_NAME
        """, 
    "index":
        """SELECT 
            st.TABLE_CATALOG, 
            st.TABLE_SCHEMA, 
            st.TABLE_NAME, 
            st.COLUMN_NAME, 
            st.SEQ_IN_INDEX, 
            st.INDEX_NAME, 
            st.NON_UNIQUE, 
            st.COLLATION, 
            st.PACKED, 
            st.NULLABLE, 
            st.INDEX_TYPE,
            st.IS_VISIBLE, 
        st.EXPRESSION
        FROM 
            INFORMATION_SCHEMA.STATISTICS st
        WHERE 
            st.TABLE_SCHEMA = %schema_name and st.TABLE_NAME not like '\_\_%' and st.COLUMN_NAME not like '\_\_%'
        ORDER BY 
            st.TABLE_CATALOG, 
            st.TABLE_SCHEMA, 
            st.TABLE_NAME, 
            st.COLUMN_NAME, 
            st.SEQ_IN_INDEX, 
            st.INDEX_NAME, 
            st.NON_UNIQUE, 
            st.COLLATION, 
            st.PACKED, 
            st.NULLABLE, 
            st.INDEX_TYPE,
            st.IS_VISIBLE
        """, 
    "routine": 
        """SELECT 
            r.SPECIFIC_NAME,
            r.ROUTINE_CATALOG,
            r.ROUTINE_SCHEMA,
            r.ROUTINE_NAME,
            r.ROUTINE_TYPE,
            r.DATA_TYPE,
            r.CHARACTER_MAXIMUM_LENGTH,
            r.CHARACTER_OCTET_LENGTH,
            r.NUMERIC_PRECISION,
            r.NUMERIC_SCALE,
            r.DATETIME_PRECISION,
            r.CHARACTER_SET_NAME,
            r.COLLATION_NAME,
            r.DTD_IDENTIFIER,
            r.ROUTINE_BODY, 
            r.EXTERNAL_NAME,
            r.EXTERNAL_LANGUAGE,
            r.PARAMETER_STYLE,
            r.IS_DETERMINISTIC, 
            r.ROUTINE_DEFINITION
        FROM 
            information_schema.routines r
        WHERE 
            r.ROUTINE_SCHEMA = %schema_name
        ORDER BY 
            r.SPECIFIC_NAME,
            r.ROUTINE_CATALOG,
            r.ROUTINE_SCHEMA,
            r.ROUTINE_NAME,
            r.ROUTINE_TYPE,
            r.DATA_TYPE,
            r.CHARACTER_MAXIMUM_LENGTH,
            r.CHARACTER_OCTET_LENGTH,
            r.NUMERIC_PRECISION,
            r.NUMERIC_SCALE,
            r.DATETIME_PRECISION,
            r.CHARACTER_SET_NAME,
            r.COLLATION_NAME,
            r.DTD_IDENTIFIER,
            r.ROUTINE_BODY,
            r.ROUTINE_DEFINITION,
            r.EXTERNAL_NAME,
            r.EXTERNAL_LANGUAGE,
            r.PARAMETER_STYLE,
            r.IS_DETERMINISTIC
        """, 
    "trigger": 
        """SELECT 
            t.TRIGGER_CATALOG,
            t.TRIGGER_SCHEMA,
            t.TRIGGER_NAME,
            t.EVENT_MANIPULATION,
            t.EVENT_OBJECT_CATALOG,
            t.EVENT_OBJECT_SCHEMA,
            t.EVENT_OBJECT_TABLE,
            t.ACTION_ORDER,
            t.ACTION_CONDITION,
            t.ACTION_ORIENTATION,
            t.ACTION_TIMING,
            t.ACTION_REFERENCE_OLD_TABLE,
            t.ACTION_REFERENCE_NEW_TABLE,
            t.ACTION_REFERENCE_OLD_ROW,
            t.ACTION_REFERENCE_NEW_ROW, 
            t.ACTION_STATEMENT
        FROM 
            information_schema.triggers t
        WHERE 
            t.trigger_schema = %schema_name
        ORDER BY 
            t.TRIGGER_CATALOG,
            t.TRIGGER_SCHEMA,
            t.TRIGGER_NAME,
            t.EVENT_MANIPULATION,
            t.EVENT_OBJECT_CATALOG,
            t.EVENT_OBJECT_SCHEMA,
            t.EVENT_OBJECT_TABLE,
            t.ACTION_ORDER,
            t.ACTION_CONDITION,
            t.ACTION_ORIENTATION,
            t.ACTION_TIMING,
            t.ACTION_REFERENCE_OLD_TABLE,
            t.ACTION_REFERENCE_NEW_TABLE,
            t.ACTION_REFERENCE_OLD_ROW,
            t.ACTION_REFERENCE_NEW_ROW
        """, 
    "view": 
        """SELECT 
            v.TABLE_CATALOG,
            v.TABLE_SCHEMA,
            v.TABLE_NAME,
            v.VIEW_DEFINITION,
            v.CHECK_OPTION,
            v.IS_UPDATABLE
        FROM 
            information_schema.views v 
        WHERE 
            v.table_schema = %schema_name and v.table_name not like '\_\_%'
        ORDER BY 
            v.TABLE_CATALOG,
            v.TABLE_SCHEMA,
            v.TABLE_NAME,
            v.VIEW_DEFINITION,
            v.CHECK_OPTION,
            v.IS_UPDATABLE
        """
    }

if __name__ == "__main__":
    dbversion = Dbversion(host="13.212.19.169", database="ris_db", user="gino", password="password")
    hash_value = dbversion.calculate_hash()
    print(hash_value)
```
