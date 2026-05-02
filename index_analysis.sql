-- index_analysis.sql
-- EXPLAIN examples and index recommendations for three problematic queries.

-- Query 1: filter on plays.play_type
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM plays
WHERE play_type = 'rush';

-- Query 2: join playerstats to games for a specific player
EXPLAIN ANALYZE
SELECT ps.player_id,
       g.game_date
FROM playerstats ps
JOIN games g ON ps.game_id = g.game_id
WHERE ps.player_id = 20010032
LIMIT 10;

-- Query 3: aggregate penalties by penalty_type with a LIKE filter
EXPLAIN ANALYZE
SELECT penalty_type,
       COUNT(*)
FROM penalties
WHERE penalty_type LIKE '%Holding%'
GROUP BY penalty_type;

-- Recommended new indexes to improve performance for object queries.
CREATE INDEX IF NOT EXISTS idx_plays_play_type ON plays(play_type);
CREATE INDEX IF NOT EXISTS idx_playerstats_player_id_game_id ON playerstats(player_id, game_id);
CREATE INDEX IF NOT EXISTS idx_penalties_penalty_type ON penalties(penalty_type);

-- Re-run the same queries after index creation to compare costs.
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM plays
WHERE play_type = 'rush';

EXPLAIN ANALYZE
SELECT ps.player_id,
       g.game_date
FROM playerstats ps
JOIN games g ON ps.game_id = g.game_id
WHERE ps.player_id = 20010032
LIMIT 10;

EXPLAIN ANALYZE
SELECT penalty_type,
       COUNT(*)
FROM penalties
WHERE penalty_type LIKE '%Holding%'
GROUP BY penalty_type;
