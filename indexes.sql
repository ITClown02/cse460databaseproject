-- =========================================================
-- Useful Indexes for Query Performance
-- =========================================================

CREATE INDEX idx_games_season ON Games(season_id);
CREATE INDEX idx_games_home_team ON Games(home_team_id);
CREATE INDEX idx_games_away_team ON Games(away_team_id);
CREATE INDEX idx_drives_game ON Drives(game_id);
CREATE INDEX idx_plays_game ON Plays(game_id);
CREATE INDEX idx_plays_drive ON Plays(drive_id);
CREATE INDEX idx_plays_team ON Plays(possession_team_id);
CREATE INDEX idx_playerstats_player ON PlayerStats(player_id);
CREATE INDEX idx_playerstats_game ON PlayerStats(game_id);
CREATE INDEX idx_penalties_play ON Penalties(play_id);
