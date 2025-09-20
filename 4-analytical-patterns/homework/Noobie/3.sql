-- What is the most games a team has won in a 90 game stretch?
WITH rolling AS (
    SELECT
        team_id,
        game_date_est,
        game_id, 
        SUM(team_won) OVER(
            PARTITION BY team_id
            ORDER BY game_date_est, game_id
            ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
            ) AS wins_in_90_games
    FROM derived
)
SELECT 
    team_id, MAX(wins_in_90_games) AS max_wins_in_90_games
FROM rolling
GROUP BY team_id
ORDER BY max_wins_in_90_games DESC;


-- How many games in a row did LeBron James score over 10 points a game?

WITH lebron AS (
    SELECT
        game_date_est, game_id,
        player_id, player_name,
        CASE WHEN pts > 10 THEN 1 ELSE 0 END AS scored_over_10
    FROM derived
    WHERE player_name = 'LeBron James'
),
streaks AS (
    SELECT *,
           SUM(CASE WHEN scored_over_10 = 0 THEN 1 ELSE 0 END) 
               OVER (ORDER BY game_id ROWS UNBOUNDED PRECEDING) AS reset_group
    FROM lebron
)
SELECT COUNT(*) AS longest_streak
FROM streaks
WHERE scored_over_10 = 1
GROUP BY reset_group
ORDER BY COUNT(*) DESC
LIMIT 1;
