-- =========================================================
-- NFL Play-by-Play Database Schema
-- PostgreSQL Version
-- =========================================================

DROP TABLE IF EXISTS Penalties CASCADE;
DROP TABLE IF EXISTS PlayerStats CASCADE;
DROP TABLE IF EXISTS PlayParticipants CASCADE;
DROP TABLE IF EXISTS Plays CASCADE;
DROP TABLE IF EXISTS Drives CASCADE;
DROP TABLE IF EXISTS Players CASCADE;
DROP TABLE IF EXISTS Games CASCADE;
DROP TABLE IF EXISTS Stadiums CASCADE;
DROP TABLE IF EXISTS Teams CASCADE;
DROP TABLE IF EXISTS Seasons CASCADE;

CREATE TABLE Seasons (
    season_id INT PRIMARY KEY,
    season_year INT NOT NULL,
    season_type VARCHAR(20) NOT NULL DEFAULT 'Regular',
    start_date DATE,
    end_date DATE
);

CREATE TABLE Teams (
    team_id INT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    team_abbr VARCHAR(10) NOT NULL UNIQUE,
    conference VARCHAR(10),
    division VARCHAR(20),
    founded_year INT
);

CREATE TABLE Stadiums (
    stadium_id INT PRIMARY KEY,
    stadium_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50),
    capacity INT,
    surface_type VARCHAR(30)
);

CREATE TABLE Games (
    game_id INT PRIMARY KEY,
    season_id INT NOT NULL,
    game_date DATE NOT NULL,
    week_number INT NOT NULL,
    home_team_id INT NOT NULL,
    away_team_id INT NOT NULL,
    stadium_id INT,
    home_score INT NOT NULL DEFAULT 0,
    away_score INT NOT NULL DEFAULT 0,
    overtime_flag BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_games_season
        FOREIGN KEY (season_id)
        REFERENCES Seasons(season_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_games_home_team
        FOREIGN KEY (home_team_id)
        REFERENCES Teams(team_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_games_away_team
        FOREIGN KEY (away_team_id)
        REFERENCES Teams(team_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_games_stadium
        FOREIGN KEY (stadium_id)
        REFERENCES Stadiums(stadium_id)
        ON DELETE SET NULL
);

CREATE TABLE Players (
    player_id INT PRIMARY KEY,
    team_id INT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(10),
    jersey_num INT,
    birth_date DATE,
    college VARCHAR(100),

    CONSTRAINT fk_players_team
        FOREIGN KEY (team_id)
        REFERENCES Teams(team_id)
        ON DELETE SET NULL
);

CREATE TABLE Drives (
    drive_id INT PRIMARY KEY,
    game_id INT NOT NULL,
    drive_number INT NOT NULL,
    offense_team_id INT NOT NULL,
    start_quarter INT NOT NULL,
    start_time_remaining VARCHAR(10),
    start_yardline INT,
    result VARCHAR(50),

    CONSTRAINT fk_drives_game
        FOREIGN KEY (game_id)
        REFERENCES Games(game_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_drives_offense_team
        FOREIGN KEY (offense_team_id)
        REFERENCES Teams(team_id)
        ON DELETE RESTRICT
);

CREATE TABLE Plays (
    play_id BIGINT PRIMARY KEY,
    game_id INT NOT NULL,
    drive_id INT NOT NULL,
    play_sequence INT NOT NULL,
    quarter INT NOT NULL,
    time_remaining VARCHAR(10),
    down_number INT,
    yards_to_go INT,
    yardline_100 INT,
    play_type VARCHAR(30) NOT NULL,
    yards_gained INT NOT NULL DEFAULT 0,
    scoring_play BOOLEAN NOT NULL DEFAULT FALSE,
    turnover_flag BOOLEAN NOT NULL DEFAULT FALSE,
    possession_team_id INT NOT NULL,
    play_description VARCHAR(500),

    CONSTRAINT fk_plays_game
        FOREIGN KEY (game_id)
        REFERENCES Games(game_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_plays_drive
        FOREIGN KEY (drive_id)
        REFERENCES Drives(drive_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_plays_possession_team
        FOREIGN KEY (possession_team_id)
        REFERENCES Teams(team_id)
        ON DELETE RESTRICT
);

CREATE TABLE PlayParticipants (
    play_id BIGINT NOT NULL,
    player_id INT NOT NULL,
    role_type VARCHAR(30) NOT NULL,
    team_side VARCHAR(10),

    PRIMARY KEY (play_id, player_id, role_type),

    CONSTRAINT fk_participants_play
        FOREIGN KEY (play_id)
        REFERENCES Plays(play_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_participants_player
        FOREIGN KEY (player_id)
        REFERENCES Players(player_id)
        ON DELETE CASCADE
);

CREATE TABLE PlayerStats (
    player_stat_id BIGINT PRIMARY KEY,
    game_id INT NOT NULL,
    player_id INT NOT NULL,
    team_id INT NOT NULL,
    passing_yards INT NOT NULL DEFAULT 0,
    rushing_yards INT NOT NULL DEFAULT 0,
    receiving_yards INT NOT NULL DEFAULT 0,
    touchdowns INT NOT NULL DEFAULT 0,
    interceptions INT NOT NULL DEFAULT 0,
    tackles INT NOT NULL DEFAULT 0,

    CONSTRAINT fk_stats_game
        FOREIGN KEY (game_id)
        REFERENCES Games(game_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_stats_player
        FOREIGN KEY (player_id)
        REFERENCES Players(player_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_stats_team
        FOREIGN KEY (team_id)
        REFERENCES Teams(team_id)
        ON DELETE RESTRICT
);

CREATE TABLE Penalties (
    penalty_id BIGINT PRIMARY KEY,
    play_id BIGINT NOT NULL,
    team_id INT,
    player_id INT,
    penalty_type VARCHAR(100) NOT NULL,
    yards_penalized INT NOT NULL DEFAULT 0,
    automatic_first_down BOOLEAN NOT NULL DEFAULT FALSE,
    declined_flag BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_penalties_play
        FOREIGN KEY (play_id)
        REFERENCES Plays(play_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_penalties_team
        FOREIGN KEY (team_id)
        REFERENCES Teams(team_id)
        ON DELETE SET NULL,

    CONSTRAINT fk_penalties_player
        FOREIGN KEY (player_id)
        REFERENCES Players(player_id)
        ON DELETE SET NULL
);
