INSERT INTO actors
WITH yesterday AS (
	SELECT * FROM actors
	WHERE year = 1969
),
today AS (
	SELECT * FROM actor_films
	WHERE year = 1970
),
today_agg AS (
	SELECT actorid, actor, year,
		ARRAY_AGG(ROW(film,votes, rating, filmid)::film_stats) AS films
	FROM today
	GROUP BY actorid, actor, year
)
SELECT
    COALESCE(t.actorid, y.actorid) AS actorid,
    COALESCE(t.actor, y.actor) AS actor,
    CASE 
		WHEN y.films IS NULL THEN t.films
		WHEN t.films IS NOT NULL THEN y.films || t.films
		ELSE y.films
	END AS films,
	CASE 
        WHEN t.films IS NOT NULL THEN (
            SELECT CASE 
                WHEN SUM(f.rating * f.votes) / NULLIF(SUM(f.votes), 0) > 8 THEN 'star'
                WHEN SUM(f.rating * f.votes) / NULLIF(SUM(f.votes), 0) > 7 THEN 'good'
                WHEN SUM(f.rating * f.votes) / NULLIF(SUM(f.votes), 0) > 6 THEN 'average'
                ELSE 'bad'
            END::quality_class
            FROM UNNEST(t.films) AS f
        )
        ELSE y.quality_class
    END AS quality_class,
    CASE
        WHEN t.films IS NOT NULL THEN True
        ELSE FALSE
    END AS is_active,
    COALESCE(t.year, y.year+1) AS year
FROM today_agg t FULL OUTER JOIN yesterday y
ON t.actorid = y.actorid;