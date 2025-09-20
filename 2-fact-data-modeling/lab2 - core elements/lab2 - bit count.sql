CREATE TABLE users_cumulated (
	user_id TEXT,
	dates_active DATE[],
	date DATE,	
	PRIMARY KEY (user_id, date)
);


INSERT INTO users_cumulated
WITH yesterday AS (
	SELECT * FROM users_cumulated
	WHERE date = DATE '2023-01-30'
),
today AS (
	SELECT
		CAST(user_id AS TEXT) AS user_id, 
		CAST(event_time AS TIMESTAMP)::DATE AS date_active
	FROM events
	WHERE CAST(event_time AS TIMESTAMP)::DATE = DATE '2023-01-31'
	AND user_id IS NOT NULL
	GROUP BY user_id, CAST(event_time AS TIMESTAMP)::DATE
)
SELECT
	COALESCE(t.user_id, y.user_id) AS user_id,
	CASE 
		WHEN y.dates_active IS NULL THEN ARRAY[t.date_active]
		WHEN t.date_active IS NULL THEN y.dates_active
		ELSE ARRAY[t.date_active] || y.dates_active
	END AS dates_active,
	COALESCE(t.date_active, y.date + INTERVAL '1 DAY') AS date
FROM today t 
FULL OUTER JOIN yesterday y
ON t.user_id = y.user_id;


WITH users AS (
	SELECT * FROM users_cumulated
	WHERE date = DATE '2023-01-31'
),
series AS (
	SELECT * 
	FROM generate_series(DATE '2023-01-01', DATE '2023-01-31', INTERVAL '1 DAY') 
		AS series_date
),
placeholder_ints AS (
SELECT 
	CASE WHEN dates_active @> ARRAY[DATE(series_date)]  -- A @> B means array A contains array B
		THEN CAST(POW(2, 32 - (date - DATE(series_date))) AS BIGINT)  -- 32 days covers all months
		ELSE 0
	END AS placeholder_int_value,
	*
FROM users CROSS JOIN series  --is like dot product
)
SELECT
	user_id,
	CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32)),
	BIT_COUNT(CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) > 0 
		AS dim_is_monthly_active,
	BIT_COUNT(CAST('11111110000000000000000000000000' AS BIT(32)) &
		CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) > 0
		AS dim_is_weekly_active,
	BIT_COUNT(CAST('10000000000000000000000000000000' AS BIT(32)) &
		CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) > 0
		AS dim_is_daily_active
FROM placeholder_ints
GROUP BY user_id