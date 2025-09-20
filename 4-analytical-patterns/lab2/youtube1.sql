WITH deduped_events AS (
    SELECT
        user_id, url, event_time, DATE(event_time) AS event_date
    FROM events
    WHERE user_id IS NOT NULL
    -- AND url IN ('/signup', '/api/v1/users')
    GROUP BY user_id, url, event_time, DATE(event_time)
),
selfjoined AS (
    SELECT d1.user_id, d1.url, 
        d2.url AS destination_url, d1.event_time, d2.event_time
    FROM deduped_events d1 JOIN deduped_events d2
    ON d1.user_id = d2.user_id
    AND d1.event_date = d2.event_date
    AND d2.event_time > d1.event_time
    -- AND d1.url <> d2.url
    -- WHERE d1.url = '/signup'
),
userlevel AS (
SELECT user_id, url, COUNT(1) AS number_of_hits,
    SUM(CASE WHEN destination_url = '/api/v1/users' THEN 1 ELSE 0 END) AS converted
FROM selfjoined
GROUP BY user_id, url
)
SELECT 
    url, SUM(number_of_hits) AS num_hits,
    SUM(converted) AS num_converted,
    CAST(SUM(converted) AS REAL) / SUM(number_of_hits) AS pct_converted
FROM userlevel
GROUP BY url
HAVING SUM(number_of_hits) > 500