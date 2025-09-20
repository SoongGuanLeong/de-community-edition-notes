DO $$
DECLARE loop_date DATE := DATE '2023-01-01';
BEGIN
    WHILE loop_date <= DATE '2023-01-31' LOOP
        INSERT INTO host_activity_reduced
        WITH yesterday_array AS (
            SELECT * FROM host_activity_reduced
            WHERE month_start = DATE '2023-01-01'
        ),
        daily_aggregate AS (
            SELECT
                host,
                DATE(event_time) AS date,
                COUNT(1) AS num_hits,
                COUNT(DISTINCT user_id) AS num_unique_visitors
            FROM events
            WHERE DATE(event_time) = loop_date
            AND user_id IS NOT NULL
            GROUP BY host, DATE(event_time)
        )
        SELECT
            COALESCE(ya.month_start, DATE_TRUNC('month', da.date)) AS month_start,
            COALESCE(da.host, ya.host) AS host,
            CASE
                WHEN ya.hit_array IS NOT NULL
                    THEN ya.hit_array || ARRAY[COALESCE(da.num_hits,0)]
                WHEN ya.hit_array IS NULL
                    THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)])
                        || ARRAY[COALESCE(da.num_hits, 0)]
            END AS hit_array,
            CASE
                WHEN ya.unique_visitors_array IS NOT NULL
                    THEN ya.unique_visitors_array || ARRAY[COALESCE(da.num_unique_visitors,0)]
                WHEN ya.unique_visitors_array IS NULL
                    THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)])
                        || ARRAY[COALESCE(da.num_unique_visitors, 0)]
            END AS unique_visitors_array
        FROM daily_aggregate da
        FULL OUTER JOIN yesterday_array ya
        ON da.host = ya.host
        ON CONFLICT (host, month_start)
        DO UPDATE SET
            hit_array = EXCLUDED.hit_array,
            unique_visitors_array = EXCLUDED.unique_visitors_array;
        loop_date := loop_date + INTERVAL '1 day';
    END LOOP;
END $$;
