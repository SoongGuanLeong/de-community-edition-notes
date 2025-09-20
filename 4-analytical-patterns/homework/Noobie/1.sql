CREATE TABLE players_state_tracking (
    player_name TEXT,
    years_since_last_active INTEGER,
    is_active BOOLEAN,
    daily_active_state TEXT,
    current_season INTEGER,
    PRIMARY KEY (player_name, current_season)
);


DO $$
DECLARE yr INT;
BEGIN
    FOR yr IN 1996..2022 LOOP
        INSERT INTO players_state_tracking
        WITH previous_players AS (
            SELECT * FROM players_state_tracking
            WHERE current_season = yr - 1
        ),
        current_players AS (
            SELECT
                player_name,
                years_since_last_active,
                is_active,
                current_season
            FROM players
            WHERE current_season = yr
        )
        SELECT
            COALESCE(cp.player_name, pp.player_name) AS player_name,
            COALESCE(cp.years_since_last_active, pp.years_since_last_active) AS years_since_last_active,
            COALESCE(cp.is_active, pp.is_active) AS is_active,
            CASE 
                WHEN pp.player_name IS NULL AND cp.is_active = TRUE THEN 'New'
                WHEN pp.is_active = TRUE AND cp.is_active = FALSE THEN 'Retired'
                WHEN pp.is_active = TRUE AND cp.is_active = TRUE THEN 'Continued Playing'
                WHEN (pp.is_active = FALSE OR pp.is_active IS NULL)
                    AND cp.is_active = TRUE AND cp.years_since_last_active > 0
                    THEN 'Returned from Retirement'
                WHEN pp.is_active = FALSE AND cp.is_active = FALSE THEN 'Stayed Retired'
            END AS daily_active_state,
            COALESCE(cp.current_season, pp.current_season) AS current_season
        FROM current_players cp 
        FULL OUTER JOIN previous_players pp
        ON cp.player_name = pp.player_name;
    END LOOP;
END $$;