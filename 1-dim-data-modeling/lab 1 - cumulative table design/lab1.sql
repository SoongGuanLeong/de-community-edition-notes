SELECT * FROM player_seasons;

-- Struct type for SCD, that are not fixed
CREATE TYPE season_stats AS (
	season INTEGER,
	gp INTEGER,         -- games played
	pts REAL,           -- points
	reb REAL,           -- rebounds
	ast REAL            -- assists
);

-- enum is like data validation in Excel
CREATE TYPE scoring_class AS ENUM('star', 'good', 'average', 'bad');

-- target table: the one we r trying to create
-- first seven column is fixed dimension
CREATE TABLE players (
	player_name TEXT,
	height TEXT,
	college TEXT,
	country TEXT,
	draft_year TEXT,
	draft_round TEXT,
	draft_number TEXT,
	season_stats season_stats[],                -- array of season stats
	scoring_class scoring_class,                -- derived col: category based on points
	years_since_last_season INTEGER,            -- derived col: tracks inactivity
	current_season INTEGER,                     -- derived col: act like create_date
	PRIMARY KEY(player_name, current_season)
)

-- src(new data): player_seasons, trg(old data): players
-- like upsert
INSERT INTO players
With yesterday AS (
	SELECT * FROM players
	WHERE current_season = 2000
),
today AS (
	SELECT * FROM player_seasons
	WHERE season = 2001
)
SELECT 
    -- basic player info: fixed dimension
	COALESCE(t.player_name, y.player_name) AS player_name,
	COALESCE(t.height, y.height) AS height,
	COALESCE(t.college, y.college) AS college,
	COALESCE(t.country, y.country) AS country,
	COALESCE(t.draft_year, y.draft_year) AS draft_year,
	COALESCE(t.draft_round, y.draft_round) AS draft_round,
	COALESCE(t.draft_number, y.draft_number) AS draft_number,

    -- season_stats array update: append this year’s stats if present
	CASE
        -- first season for this player → initialize array 
		WHEN y.season_stats IS NULL THEN ARRAY[ROW(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		)::season_stats]
        -- continuing player → append this season to array
		WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[ROW(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		)::season_stats]
        -- no new stats → carry forward old array
		ELSE y.season_stats
	END AS season_stats,
    -- scoring_class update: recompute if new season stats exist, else carry forward
	CASE 
		WHEN t.season IS NOT NULL THEN
			CASE WHEN t.pts > 20 THEN 'star'
				WHEN t.pts > 15 THEN 'good'
				WHEN t.pts > 10 THEN 'average'
				ELSE 'bad'
			END::scoring_class
		ELSE y.scoring_class
	END AS scoring_class,
    -- inactivity counter: reset if new season, else increment
	CASE 
		WHEN t.season IS NOT NULL THEN 0
		ELSE y.years_since_last_season + 1
	END AS years_since_last_season,
    -- current_season = today’s season if available, else yesterday’s + 1
	COALESCE(t.season, y.current_season + 1) AS current_season
-- FULL OUTER JOIN TO KEEP ALL HISTORY
FROM today t FULL OUTER JOIN yesterday y
ON t.player_name = y.player_name;


-- Demo query: how this kind of table can prevent shuffling
SELECT
	player_name,
	(season_stats[CARDINALITY(season_stats)]::season_stats).pts/
	CASE WHEN(season_stats[1]::season_stats).pts=0 THEN 1 ELSE (season_stats[1]::season_stats).pts END
FROM players
WHERE current_season = 2001
AND scoring_class = 'star'


-- how to get the nested struct array back to original table format
WITH unnested AS (
SELECT 
	player_name,
	UNNEST(season_stats)::season_stats AS season_stats	
FROM players WHERE current_season = 2001
)
SELECT player_name, (season_stats::season_stats).*          -- expand struct fields into columns
FROM unnested