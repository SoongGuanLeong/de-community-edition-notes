CREATE TABLE derived AS 
WITH combined AS (
    SELECT
        g.game_date_est,
        g.season,
        g.home_team_id,
        g.visitor_team_id, 
        g.home_team_wins,
        gd.game_id,
        gd.player_id,
        gd.player_name,
        gd.team_id,
        gd.fgm,
        gd.fg3m,
        gd.ftm,
        ROW_NUMBER() 
            OVER(PARTITION BY gd.game_id, gd.team_id, gd.player_id 
                    ORDER BY g.game_date_est) AS row_num
    FROM game_details gd JOIN games g
    ON gd.game_id = g.game_id
)
SELECT 
    game_date_est,
    season,
    game_id,
    team_id,
    player_id,
    player_name,
    (2 * (fgm-fg3m) + 3*fg3m + ftm) AS pts,
    CASE
        WHEN team_id = home_team_id AND home_team_wins = 1 THEN 1
        WHEN team_id = visitor_team_id AND home_team_wins = 0 THEN 1
        ELSE 0
    END AS team_won
FROM combined
WHERE row_num = 1;


SELECT 
    player_id,
    player_name,
    team_id,
    season,
    SUM(pts) AS total_pts,
    SUM(team_won) AS total_wins
FROM derived
GROUP BY GROUPING SETS (
    (player_id, player_name, team_id),
    (player_id, player_name, season),
    (team_id)
)
ORDER BY SUM(pts) DESC, SUM(team_won) DESC;

-- who scored the most points playing for one team?
-- 203507,"Giannis Antetokounmpo",1610612749,,15556,369

-- who scored the most points in one season?
-- 201935,"James Harden",,2018,3247,60

-- which team has won the most games?
-- ,,1610612744,,78239,5748
