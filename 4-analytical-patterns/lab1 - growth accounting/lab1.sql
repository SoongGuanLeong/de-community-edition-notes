DO $$
DECLARE loop_date DATE := DATE '2023-03-01';
BEGIN
    WHILE loop_date <= DATE '2023-03-09' LOOP
        INSERT INTO users_growth_accounting
        WITH yesterday AS (
            SELECT * FROM users_growth_accounting
            WHERE date = loop_date - INTERVAL '1 DAY'
        ),
        today AS (
            SELECT
                CAST(user_id AS TEXT) AS user_id,
                DATE_TRUNC('day', event_time::timestamp) AS today_date,
                COUNT(1)
            FROM events
            WHERE DATE_TRUNC('day', event_time::timestamp) = loop_date
            AND user_id IS NOT NULL
            GROUP BY user_id, DATE_TRUNC('day', event_time::timestamp)
        )
        SELECT
            COALESCE(t.user_id, y.user_id) AS user_id,
            COALESCE(y.first_active_date, t.today_date) AS first_active_date,
            COALESCE(t.today_date, y.last_active_date) AS last_active_date,
            CASE 
                WHEN y.user_id IS NULL AND t.user_id IS NOT NULL THEN 'New'
                WHEN y.last_active_date = t.today_date - INTERVAL '1 DAY' THEN 'Retained'
                WHEN y.last_active_date < t.today_date - INTERVAL '1 DAY' THEN 'Resurrected'
                WHEN t.today_date IS NULL AND y.last_active_date = y.date THEN 'Churned'
                ELSE 'Stale'
            END AS daily_active_state,
            CASE
                WHEN y.user_id IS NULL AND t.user_id IS NOT NULL THEN 'New'
                WHEN COALESCE(t.today_date, y.last_active_date) >= y.date - INTERVAL '7 DAY' THEN 'Retained'
                WHEN y.last_active_date < t.today_date - INTERVAL '7 DAY' THEN 'Resurrected'
                WHEN t.today_date IS NULL AND y.last_active_date = y.date - INTERVAL '7 DAY' THEN 'Churned'
                ELSE 'Stale'
            END AS weekly_active_state,
            CASE 
                WHEN y.dates_active IS NULL THEN ARRAY[t.today_date]
                WHEN t.today_date IS NULL THEN y.dates_active
                ELSE ARRAY[t.today_date] || y.dates_active
            END AS dates_active,
            COALESCE(t.today_date, y.date + INTERVAL '1 DAY') AS date
        FROM today t
        FULL OUTER JOIN yesterday y
        ON t.user_id = y.user_id;
        loop_date := loop_date + INTERVAL '1 day';
    END LOOP;
END $$;



SELECT * FROM users_growth_accounting
WHERE date = DATE '2023-03-02'
AND daily_active_state = 'Churned';

SELECT 
    extract(dow from first_active_date) AS dow,
    date - first_active_date AS days_since_first_active, 
    COUNT(CASE WHEN daily_active_state IN ('Retained', 'Resurrected', 'New')THEN 1 END) AS number_active,
    COUNT(1),
    CAST(COUNT(CASE WHEN daily_active_state IN ('Retained', 'Resurrected', 'New')THEN 1 END) AS REAL) / COUNT(1) AS pct_active
FROM users_growth_accounting
GROUP BY extract(dow from first_active_date), date - first_active_date;