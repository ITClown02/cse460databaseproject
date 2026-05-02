-- nfl_analysis_queries.sql
-- Example SQL query set for the NFL relational database.
-- Includes SELECTs with JOIN, GROUP BY, subqueries, and DML examples.

-- 1) Game count by season
SELECT season_id, COUNT(*) AS game_count
FROM games
GROUP BY season_id
ORDER BY season_id;

-- 2) Team win/loss summary based on home/away score comparison
SELECT t.team_id,
       t.team_name,
       SUM(CASE WHEN g.home_team_id = t.team_id AND g.home_score > g.away_score THEN 1
                WHEN g.away_team_id = t.team_id AND g.away_score > g.home_score THEN 1
                ELSE 0 END) AS wins,
       SUM(CASE WHEN g.home_team_id = t.team_id AND g.home_score < g.away_score THEN 1
                WHEN g.away_team_id = t.team_id AND g.away_score < g.home_score THEN 1
                ELSE 0 END) AS losses,
       SUM(CASE WHEN g.home_score = g.away_score THEN 1 ELSE 0 END) AS ties
FROM teams t
JOIN games g ON t.team_id IN (g.home_team_id, g.away_team_id)
GROUP BY t.team_id, t.team_name
ORDER BY wins DESC, losses ASC;

-- 3) Top 20 players by total touchdowns across all games
SELECT p.player_id,
       p.first_name || ' ' || p.last_name AS player_name,
       SUM(ps.touchdowns) AS total_touchdowns
FROM players p
JOIN playerstats ps ON p.player_id = ps.player_id
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY total_touchdowns DESC
LIMIT 20;

-- 4) Average yards gained per play type
SELECT play_type,
       COUNT(*) AS play_count,
       AVG(yards_gained) AS avg_yards
FROM plays
GROUP BY play_type
ORDER BY avg_yards DESC;

-- 5) Players with most plays participated in, using a subquery
SELECT player_id,
       (SELECT first_name || ' ' || last_name FROM players WHERE players.player_id = pp.player_id) AS player_name,
       COUNT(*) AS participation_count
FROM playparticipants pp
GROUP BY player_id
ORDER BY participation_count DESC
LIMIT 25;

-- 6) Game details with stadium and team names
SELECT g.game_id,
       g.game_date,
       s.stadium_name,
       th.team_name AS home_team,
       ta.team_name AS away_team,
       g.home_score,
       g.away_score
FROM games g
LEFT JOIN stadiums s ON g.stadium_id = s.stadium_id
LEFT JOIN teams th ON g.home_team_id = th.team_id
LEFT JOIN teams ta ON g.away_team_id = ta.team_id
ORDER BY g.game_date DESC
LIMIT 30;

-- 7) Drives per game and average drive length based on start quarter
SELECT g.game_id,
       g.game_date,
       COUNT(d.drive_id) AS drive_count,
       AVG(drive_number) AS avg_drive_number
FROM games g
JOIN drives d ON g.game_id = d.game_id
GROUP BY g.game_id, g.game_date
ORDER BY drive_count DESC
LIMIT 20;

-- 8) Player stats joined with team and game info
SELECT ps.player_stat_id,
       g.game_date,
       p.first_name || ' ' || p.last_name AS player_name,
       t.team_abbr,
       ps.passing_yards,
       ps.rushing_yards,
       ps.receiving_yards
FROM playerstats ps
JOIN players p ON ps.player_id = p.player_id
JOIN teams t ON ps.team_id = t.team_id
JOIN games g ON ps.game_id = g.game_id
ORDER BY g.game_date DESC, ps.passing_yards DESC
LIMIT 40;

-- 9) Penalty type frequency and average yards penalized
SELECT penalty_type,
       COUNT(*) AS penalty_count,
       AVG(yards_penalized) AS avg_yards_penalized,
       SUM(CASE WHEN automatic_first_down THEN 1 ELSE 0 END) AS auto_first_down_count
FROM penalties
GROUP BY penalty_type
ORDER BY penalty_count DESC
LIMIT 30;

-- 10) Find games with the highest combined score
SELECT game_id,
       game_date,
       home_score + away_score AS total_score
FROM games
ORDER BY total_score DESC
LIMIT 20;

-- 11) Subquery: players who have scored more than 10 touchdowns in a single game
SELECT ps.player_id,
       p.first_name || ' ' || p.last_name AS player_name,
       ps.game_id,
       ps.touchdowns
FROM playerstats ps
JOIN players p ON ps.player_id = p.player_id
WHERE ps.touchdowns > 10
ORDER BY ps.touchdowns DESC;

-- 12) Update example: normalize team abbreviations to uppercase
UPDATE teams
SET team_abbr = UPPER(team_abbr)
WHERE team_abbr IS NOT NULL;

-- 13) Update example: flag any penalties with yards_penalized > 15 as likely pass interference in description
UPDATE penalties
SET penalty_type = 'Possible Pass Interference'
WHERE yards_penalized > 15
  AND LOWER(penalty_type) LIKE '%interf%';

-- 14) Insert example: add a manual team record for a missing placeholder team
INSERT INTO teams (team_id, team_name, team_abbr, conference, division, founded_year)
SELECT 9999, 'Placeholder Team', 'PHLD', 'Unknown', 'Unknown', 1900
WHERE NOT EXISTS (SELECT 1 FROM teams WHERE team_id = 9999);

-- 15) Delete example: delete placeholder teams with no associated games
DELETE FROM teams
WHERE team_id = 9999
  AND NOT EXISTS (SELECT 1 FROM games WHERE home_team_id = teams.team_id OR away_team_id = teams.team_id);

-- 16) Complex query: team scoring summary by season
SELECT t.team_id,
       t.team_name,
       g.season_id,
       SUM(CASE WHEN g.home_team_id = t.team_id THEN g.home_score
                WHEN g.away_team_id = t.team_id THEN g.away_score
                ELSE 0 END) AS total_points_scored,
       SUM(CASE WHEN g.home_team_id = t.team_id THEN g.away_score
                WHEN g.away_team_id = t.team_id THEN g.home_score
                ELSE 0 END) AS total_points_allowed
FROM teams t
JOIN games g ON t.team_id IN (g.home_team_id, g.away_team_id)
GROUP BY t.team_id, t.team_name, g.season_id
ORDER BY g.season_id, total_points_scored DESC
LIMIT 50;

-- 17) Aggregation with HAVING: players whose average rushing yards per game exceeds 50
SELECT p.player_id,
       p.first_name || ' ' || p.last_name AS player_name,
       AVG(ps.rushing_yards) AS avg_rushing
FROM playerstats ps
JOIN players p ON ps.player_id = p.player_id
GROUP BY p.player_id, p.first_name, p.last_name
HAVING AVG(ps.rushing_yards) > 50
ORDER BY avg_rushing DESC;

-- 18) Insert example: add a derived playerstat record for a backup player in a specific game
INSERT INTO playerstats (player_stat_id, game_id, player_id, team_id, passing_yards, rushing_yards, receiving_yards, touchdowns, interceptions, tackles)
VALUES (999999999, 27167, 2504378, 2520, 0, 0, 0, 0, 0, 0)
ON CONFLICT DO NOTHING;

-- 19) Delete example: remove the temporary derived playerstat if it was added incorrectly
DELETE FROM playerstats
WHERE player_stat_id = 999999999;

-- 20) Join and filter: plays in the fourth quarter with scoring plays
SELECT p.play_id,
       g.game_date,
       t.team_abbr AS offense_team,
       p.play_type,
       p.yards_gained,
       p.play_description
FROM plays p
JOIN games g ON p.game_id = g.game_id
JOIN teams t ON p.possession_team_id = t.team_id
WHERE p.quarter = 4
  AND p.scoring_play = TRUE
ORDER BY g.game_date DESC
LIMIT 50;
