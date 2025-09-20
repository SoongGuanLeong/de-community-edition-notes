-- What is the average number of web events of a session from a user on Tech Creator?
SELECT 
    ip, AVG(num_events) AS avg_num_events
FROM processed_events_sessionized
WHERE host LIKE '%.techcreator.io'
GROUP BY ip;

-- Compare results between different hosts (zachwilson.techcreator.io, zachwilson.tech, lulu.techcreator.io)
SELECT 
    host,
    AVG(num_events) AS avg_num_events
FROM processed_events_sessionized
WHERE host IN (
    'zachwilson.techcreator.io',
    'zachwilson.tech',
    'lulu.techcreator.io'
)
GROUP BY host;