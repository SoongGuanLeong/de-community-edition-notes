CREATE TABLE host_activity_reduced (
    month_start DATE,
    host TEXT,
    hit_array REAL[],
    unique_visitors_array REAL[],
    PRIMARY KEY (month_start, host)
);
