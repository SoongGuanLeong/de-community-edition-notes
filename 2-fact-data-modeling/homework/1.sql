WITH deduped AS (
	SELECT
		g.game_date_est,
		g.season,
		g.home_team_id,
		gd.*,
		ROW_NUMBER() 
			OVER(PARTITION BY gd.game_id, team_id, player_id 
					ORDER BY g.game_date_est) AS row_num
	FROM game_details gd
	JOIN games g ON gd.game_id = g.game_id
)
SELECT *
FROM deduped
WHERE row_num = 1;