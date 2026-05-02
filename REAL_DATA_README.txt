REAL NFL DATA ETL PACKAGE

Run order in pgAdmin:
1. Run create.sql first (your 10-table schema).
2. Make sure the real CSV files are in: C:\Users\frict\Downloads\archive
3. Run real_data_etl.sql. This creates staging tables, loads real CSVs, and transforms them into the project schema.
4. Run indexes.sql, functions_triggers_transactions.sql, queries.sql, and index_analysis.sql after data loads.

Important:
- This ETL uses the real Kaggle/NFL files you uploaded: games.csv, plays.csv, players.csv, penalties.csv, passer.csv, rusher.csv, receiver.csv, gameParticipation.csv, and tackles.csv.
- It derives seasons, teams, stadiums, drives, playparticipants, and playerstats from the raw files.
- Because the real dataset stores numeric team IDs instead of team names, teams are labeled like Team 3200 / T3200.
- Because the raw dataset does not provide a clean drive table, drives are derived from possession changes inside each game.
- If PostgreSQL cannot read files from Downloads, move the archive folder to C:\nfl_data\archive and replace the COPY path in real_data_etl.sql.
