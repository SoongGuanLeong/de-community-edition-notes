CREATE TABLE users_growth_accounting (
    user_id TEXT,
    first_active_date DATE,
    last_active _date DATE,
    daily_active_state TEXT,
    weekly_active_state TEXT,
    dates_active DATE[],
    date DATE,
    PRIMARY KEY (user_id, date)
);


CREATE TABLE events (
    user_id TEXT,
    device_id NUMERIC,
    referrer TEXT,
    host TEXT,
    url TEXT,
    event_time TEXT
);
