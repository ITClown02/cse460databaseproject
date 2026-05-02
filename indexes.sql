-- indexes.sql
-- Additional indexes recommended for query performance.

CREATE INDEX IF NOT EXISTS idx_plays_play_type ON plays(play_type);
CREATE INDEX IF NOT EXISTS idx_playerstats_player_id_game_id ON playerstats(player_id, game_id);
CREATE INDEX IF NOT EXISTS idx_penalties_penalty_type ON penalties(penalty_type);
CREATE INDEX IF NOT EXISTS idx_games_game_date ON games(game_date);
CREATE INDEX IF NOT EXISTS idx_playerstats_team_game ON playerstats(team_id, game_id);
