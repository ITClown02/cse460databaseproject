REAL NFL DATA ETL PACKAGE

Run order in pgAdmin:
1. Run create.sql first (your 10-table schema).
2. Make sure the real CSV files are in: C:\Users\frict\Downloads\archive
3. Run real_data_etl.sql. This creates staging tables, loads real CSVs, and transforms them into the project schema.
4. Run in order indexes.sql, functions_triggers_transactions.sql, queries.sql, and index_analysis.sql after data loads.

