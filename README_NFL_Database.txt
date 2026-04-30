NFL Play-by-Play and Team Performance Database Files

Recommended run order in PostgreSQL:

1. schema.sql
   Creates all 10 relations:
   Seasons, Teams, Stadiums, Games, Players, Drives, Plays,
   PlayParticipants, PlayerStats, and Penalties.

2. indexes.sql
   Adds useful indexes for common joins and performance queries.

3. functions_triggers_transactions.sql
   Adds one sample function, one trigger, and one transaction example.

4. queries.sql
   Contains sample SQL queries for joins, grouping, aggregation,
   third-down performance, penalties, turnovers, scoring plays, etc.

Note:
The transaction example requires matching sample data already inserted into
Seasons, Teams, and Stadiums. Otherwise, the foreign key constraints will stop it.
