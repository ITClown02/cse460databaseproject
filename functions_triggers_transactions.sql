-- functions_triggers_transactions.sql
-- Reusable procedures, failure logging, and a transaction failure demonstration.

CREATE TABLE IF NOT EXISTS transaction_failure_log (
    failure_id serial PRIMARY KEY,
    failure_time timestamptz NOT NULL DEFAULT now(),
    operation text NOT NULL,
    error_code text,
    error_message text
);

CREATE TABLE IF NOT EXISTS transaction_failure_audit (
    audit_id serial PRIMARY KEY,
    failure_id integer NOT NULL,
    failure_time timestamptz NOT NULL,
    operation text NOT NULL,
    error_code text,
    created_at timestamptz NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_after_failure_audit ON transaction_failure_log;
CREATE OR REPLACE FUNCTION after_failure_audit_trigger() RETURNS trigger AS $$
BEGIN
    INSERT INTO transaction_failure_audit(failure_id, failure_time, operation, error_code)
    VALUES (NEW.failure_id, NEW.failure_time, NEW.operation, NEW.error_code);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_failure_audit
AFTER INSERT ON transaction_failure_log
FOR EACH ROW EXECUTE FUNCTION after_failure_audit_trigger();

CREATE OR REPLACE FUNCTION record_transaction_failure(
    p_operation text,
    p_error_code text,
    p_error_message text
) RETURNS void AS $$
BEGIN
    INSERT INTO transaction_failure_log(operation, error_code, error_message)
    VALUES (p_operation, p_error_code, p_error_message);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_team(
    p_team_id integer,
    p_team_name text,
    p_team_abbr text,
    p_conference text,
    p_division text,
    p_founded_year integer
) RETURNS void AS $$
BEGIN
    INSERT INTO teams(team_id, team_name, team_abbr, conference, division, founded_year)
    VALUES (p_team_id, p_team_name, p_team_abbr, p_conference, p_division, p_founded_year);
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Team % already exists, skipping insert.', p_team_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_team_abbr(
    p_team_id integer,
    p_new_abbr text
) RETURNS void AS $$
BEGIN
    UPDATE teams
    SET team_abbr = p_new_abbr
    WHERE team_id = p_team_id;
    IF NOT FOUND THEN
        RAISE NOTICE 'No team found with team_id=%', p_team_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_penalty(p_penalty_id bigint) RETURNS void AS $$
BEGIN
    DELETE FROM penalties WHERE penalty_id = p_penalty_id;
    IF NOT FOUND THEN
        RAISE NOTICE 'No penalty found with penalty_id=%', p_penalty_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION select_player_game_summary(p_player_id integer)
RETURNS TABLE(
    game_id integer,
    game_date date,
    passing_yards integer,
    rushing_yards integer,
    receiving_yards integer,
    touchdowns integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT ps.game_id,
           g.game_date,
           ps.passing_yards,
           ps.rushing_yards,
           ps.receiving_yards,
           ps.touchdowns
    FROM playerstats ps
    JOIN games g ON ps.game_id = g.game_id
    WHERE ps.player_id = p_player_id
    ORDER BY g.game_date DESC;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION demo_failed_transaction_update(
    p_team_id integer,
    p_new_abbr text
) RETURNS text AS $$
BEGIN
    BEGIN
        UPDATE teams
        SET team_abbr = p_new_abbr
        WHERE team_id = p_team_id;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Team % not found', p_team_id;
        END IF;

        -- Simulate an error after the update to demonstrate rollback.
        RAISE EXCEPTION 'Simulated failure after team update';
    EXCEPTION WHEN OTHERS THEN
        PERFORM record_transaction_failure('demo_failed_transaction_update', SQLSTATE, SQLERRM);
        RETURN 'TRANSACTION_ABORTED';
    END;

    RETURN 'TRANSACTION_OK';
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT insert_team(9999, 'Placeholder Team', 'PHLD', 'Unknown', 'Unknown', 1900);
-- SELECT update_team_abbr(9999, 'PHLD');
-- SELECT delete_penalty(999999999);
-- SELECT * FROM select_player_game_summary(20010032);
-- SELECT demo_failed_transaction_update(9999, 'TEST');
-- SELECT * FROM transaction_failure_log ORDER BY failure_time DESC LIMIT 5;
