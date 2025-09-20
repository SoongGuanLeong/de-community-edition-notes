DO $$
DECLARE loop_date DATE := DATE '2023-01-01';
BEGIN
    WHILE loop_date <= DATE '2023-01-31' LOOP
        INSERT INTO user_devices_cumulated
        WITH yesterday AS (
            SELECT * FROM user_devices_cumulated
            WHERE date = loop_date - INTERVAL '1 DAY'
        ),
        today AS (
            SELECT 
                e.user_id,
                d.browser_type,
                DATE(CAST(event_time AS TIMESTAMP)) AS device_activity_date
            FROM events e JOIN devices d
            ON e.device_id = d.device_id
            WHERE DATE(CAST(event_time AS TIMESTAMP)) = loop_date
            AND e.user_id IS NOT NULL
            GROUP BY e.user_id, d.browser_type, DATE(CAST(event_time AS TIMESTAMP))
        )
        SELECT
            COALESCE(t.user_id, y.user_id) AS user_id,
            COALESCE(t.browser_type, y.browser_type) AS browser_type,
            CASE
                WHEN y.device_activity_datelist IS NULL THEN ARRAY[t.device_activity_date]
                WHEN t.device_activity_date IS NULL THEN y.device_activity_datelist
                ELSE ARRAY[t.device_activity_date] || y.device_activity_datelist
            END AS device_activity_datelist,
            COALESCE(t.device_activity_date, y.date + INTERVAL '1 DAY') AS date
        FROM today t 
        FULL OUTER JOIN yesterday y
        ON t.user_id = y.user_id 
        AND t.browser_type = y.browser_type;
        loop_date := loop_date + INTERVAL '1 day';
    END LOOP;
END $$;
