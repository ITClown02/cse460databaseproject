-- create.sql
-- Create the target schema for the NFL ETL project used by real_data_etl.sql.

DROP TABLE IF EXISTS penalties CASCADE;
DROP TABLE IF EXISTS playerstats CASCADE;
DROP TABLE IF EXISTS playparticipants CASCADE;
DROP TABLE IF EXISTS plays CASCADE;
DROP TABLE IF EXISTS drives CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS games CASCADE;
DROP TABLE IF EXISTS stadiums CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP TABLE IF EXISTS seasons CASCADE;

CREATE TABLE seasons (
    season_id integer PRIMARY KEY,
    season_year integer NOT NULL,
    season_type text NOT NULL DEFAULT 'Regular',
    start_date date,
    end_date date
);

CREATE TABLE teams (
    team_id integer PRIMARY KEY,
    team_name text NOT NULL,
    team_abbr text NOT NULL,
    conference text,
    division text,
    founded_year integer
);

CREATE TABLE stadiums (
    stadium_id integer PRIMARY KEY,
    stadium_name text NOT NULL,
    city text,
    state text,
    capacity integer,
    surface_type text
);

CREATE TABLE games (
    game_id integer PRIMARY KEY,
    season_id integer NOT NULL REFERENCES seasons(season_id) ON DELETE RESTRICT,
    game_date date NOT NULL,
    week_number integer NOT NULL DEFAULT 0,
    home_team_id integer REFERENCES teams(team_id) ON DELETE RESTRICT,
    away_team_id integer REFERENCES teams(team_id) ON DELETE RESTRICT,
    stadium_id integer REFERENCES stadiums(stadium_id) ON DELETE SET NULL,
    home_score integer NOT NULL DEFAULT 0,
    away_score integer NOT NULL DEFAULT 0,
    overtime_flag boolean NOT NULL DEFAULT FALSE
);

CREATE TABLE players (
    player_id integer PRIMARY KEY,
    team_id integer REFERENCES teams(team_id) ON DELETE SET NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    position text,
    jersey_num integer,
    birth_date date,
    college text
);

CREATE TABLE drives (
    drive_id integer PRIMARY KEY,
    game_id integer NOT NULL REFERENCES games(game_id) ON DELETE CASCADE,
    drive_number integer NOT NULL DEFAULT 0,
    offense_team_id integer REFERENCES teams(team_id) ON DELETE RESTRICT,
    start_quarter integer NOT NULL DEFAULT 0,
    start_time_remaining text,
    start_yardline integer,
    result text
);

CREATE TABLE plays (
    play_id bigint PRIMARY KEY,
    game_id integer NOT NULL REFERENCES games(game_id) ON DELETE CASCADE,
    drive_id integer REFERENCES drives(drive_id) ON DELETE CASCADE,
    play_sequence integer NOT NULL DEFAULT 0,
    quarter integer NOT NULL DEFAULT 0,
    time_remaining text,
    down_number integer,
    yards_to_go integer,
    yardline_100 integer,
    play_type varchar(30) NOT NULL DEFAULT 'unknown',
    yards_gained integer NOT NULL DEFAULT 0,
    scoring_play boolean NOT NULL DEFAULT FALSE,
    turnover_flag boolean NOT NULL DEFAULT FALSE,
    possession_team_id integer REFERENCES teams(team_id) ON DELETE RESTRICT,
    play_description varchar(500)
);

CREATE TABLE playparticipants (
    play_id bigint NOT NULL REFERENCES plays(play_id) ON DELETE CASCADE,
    player_id integer NOT NULL REFERENCES players(player_id) ON DELETE CASCADE,
    role_type varchar(30) NOT NULL,
    team_side varchar(10),
    PRIMARY KEY (play_id, player_id, role_type)
);

CREATE TABLE playerstats (
    player_stat_id bigint PRIMARY KEY,
    game_id integer NOT NULL REFERENCES games(game_id) ON DELETE CASCADE,
    player_id integer NOT NULL REFERENCES players(player_id) ON DELETE CASCADE,
    team_id integer NOT NULL REFERENCES teams(team_id) ON DELETE RESTRICT,
    passing_yards integer NOT NULL DEFAULT 0,
    rushing_yards integer NOT NULL DEFAULT 0,
    receiving_yards integer NOT NULL DEFAULT 0,
    touchdowns integer NOT NULL DEFAULT 0,
    interceptions integer NOT NULL DEFAULT 0,
    tackles integer NOT NULL DEFAULT 0
);

CREATE TABLE penalties (
    penalty_id bigint PRIMARY KEY,
    play_id bigint REFERENCES plays(play_id) ON DELETE CASCADE,
    team_id integer REFERENCES teams(team_id) ON DELETE SET NULL,
    player_id integer REFERENCES players(player_id) ON DELETE SET NULL,
    penalty_type varchar(100) NOT NULL,
    yards_penalized integer NOT NULL DEFAULT 0,
    automatic_first_down boolean NOT NULL DEFAULT FALSE,
    declined_flag boolean NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_games_season_id ON games(season_id);
CREATE INDEX idx_games_home_team_id ON games(home_team_id);
CREATE INDEX idx_games_away_team_id ON games(away_team_id);
CREATE INDEX idx_plays_game_id ON plays(game_id);
CREATE INDEX idx_plays_drive_id ON plays(drive_id);
CREATE INDEX idx_playparticipants_player_id ON playparticipants(player_id);
CREATE INDEX idx_playerstats_game_id ON playerstats(game_id);
CREATE INDEX idx_playerstats_player_id ON playerstats(player_id);
CREATE INDEX idx_penalties_play_id ON penalties(play_id);

CREATE OR REPLACE FUNCTION get_game_player_stats(
    p_game_id integer,
    p_player_id integer
) RETURNS TABLE(
    player_id integer,
    team_id integer,
    passing_yards integer,
    rushing_yards integer,
    receiving_yards integer,
    touchdowns integer,
    interceptions integer,
    tackles integer
) AS $$
    SELECT player_id, team_id, passing_yards, rushing_yards, receiving_yards, touchdowns, interceptions, tackles
    FROM playerstats
    WHERE game_id = p_game_id
      AND player_id = p_player_id;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION penalty_flag_update() RETURNS trigger AS $$
BEGIN
    NEW.automatic_first_down := COALESCE(
        NEW.automatic_first_down,
        LOWER(COALESCE(NEW.penalty_type, '')) LIKE '%first%'
    );
    NEW.declined_flag := COALESCE(
        NEW.declined_flag,
        LOWER(COALESCE(NEW.penalty_type, '')) LIKE '%declin%'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_penalties_flag
BEFORE INSERT OR UPDATE ON penalties
FOR EACH ROW EXECUTE FUNCTION penalty_flag_update();
