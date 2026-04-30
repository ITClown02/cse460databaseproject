-- =========================================================
-- Sample SQL Queries for NFL Play-by-Play Database
-- =========================================================

-- 1. Show all games with team names
SELECT 
    g.game_id,
    g.game_date,
    ht.team_name AS home_team,
    at.team_name AS away_team,
    g.home_score,
    g.away_score
FROM Games g
JOIN Teams ht ON g.home_team_id = ht.team_id
JOIN Teams at ON g.away_team_id = at.team_id;

-- 2. Total yards gained by each team
SELECT 
    t.team_name,
    SUM(p.yards_gained) AS total_yards
FROM Plays p
JOIN Teams t ON p.possession_team_id = t.team_id
GROUP BY t.team_name
ORDER BY total_yards DESC;

-- 3. Third down performance by team
SELECT 
    t.team_name,
    COUNT(*) AS third_down_plays,
    SUM(CASE WHEN p.yards_gained >= p.yards_to_go THEN 1 ELSE 0 END) AS successful_conversions
FROM Plays p
JOIN Teams t ON p.possession_team_id = t.team_id
WHERE p.down_number = 3
GROUP BY t.team_name
ORDER BY successful_conversions DESC;

-- 4. Players with most touchdowns
SELECT 
    pl.first_name,
    pl.last_name,
    SUM(ps.touchdowns) AS total_touchdowns
FROM PlayerStats ps
JOIN Players pl ON ps.player_id = pl.player_id
GROUP BY pl.first_name, pl.last_name
ORDER BY total_touchdowns DESC;

-- 5. Games that went to overtime
SELECT *
FROM Games
WHERE overtime_flag = TRUE;

-- 6. Penalty yards by team
SELECT 
    t.team_name,
    SUM(pe.yards_penalized) AS total_penalty_yards
FROM Penalties pe
JOIN Teams t ON pe.team_id = t.team_id
GROUP BY t.team_name
ORDER BY total_penalty_yards DESC;

-- 7. Scoring plays by game
SELECT 
    game_id,
    COUNT(*) AS scoring_play_count
FROM Plays
WHERE scoring_play = TRUE
GROUP BY game_id;

-- 8. Turnovers by team
SELECT 
    t.team_name,
    COUNT(*) AS turnovers
FROM Plays p
JOIN Teams t ON p.possession_team_id = t.team_id
WHERE p.turnover_flag = TRUE
GROUP BY t.team_name
ORDER BY turnovers DESC;

-- 9. Average yards gained by play type
SELECT 
    play_type,
    AVG(yards_gained) AS avg_yards
FROM Plays
GROUP BY play_type
ORDER BY avg_yards DESC;

-- 10. Find all players involved in a specific play
SELECT 
    pp.play_id,
    pl.first_name,
    pl.last_name,
    pp.role_type,
    pp.team_side
FROM PlayParticipants pp
JOIN Players pl ON pp.player_id = pl.player_id
WHERE pp.play_id = 1001;
