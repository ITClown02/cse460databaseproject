-- =========================================================
-- Function, Trigger, and Transaction Examples
-- PostgreSQL Version
-- =========================================================

-- Function: return total yards for one team
CREATE OR REPLACE FUNCTION get_team_total_yards(input_team_id INT)
RETURNS INT AS $$
DECLARE
    total_yards INT;
BEGIN
    SELECT COALESCE(SUM(yards_gained), 0)
    INTO total_yards
    FROM Plays
    WHERE possession_team_id = input_team_id;

    RETURN total_yards;
END;
$$ LANGUAGE plpgsql;

-- Trigger function: prevent negative yards_to_go
CREATE OR REPLACE FUNCTION check_yards_to_go()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.yards_to_go < 0 THEN
        RAISE EXCEPTION 'yards_to_go cannot be negative';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_yards_to_go
BEFORE INSERT OR UPDATE ON Plays
FOR EACH ROW
EXECUTE FUNCTION check_yards_to_go();

-- Transaction example: insert a game safely
BEGIN;

INSERT INTO Games (
    game_id, season_id, game_date, week_number,
    home_team_id, away_team_id, stadium_id,
    home_score, away_score, overtime_flag
)
VALUES (
    1, 2024, '2024-09-08', 1,
    1, 2, 1,
    24, 21, FALSE
);

COMMIT;

-- If something fails, use:
-- ROLLBACK;
