# Recursive CTE & Window Functions

Things that appear on interview but almost never do on the job
- Rewrite query w/o window functions
- write a query with recursive CTE
- Using correlated subqueries in any capacity

Things that interviews get right 
- Care about number of table scans
    - `COUNT(CASE WHEN)`
    - Cumulative table design minimize table scan
- write clean code
    - CTE 
    - use aliases

## Advanced SQL to try out
- GROUPING SETS / GROUP BY CUBE / GROUP BY ROLLUP
- self JOINS
- window functions 
    - LAG, LEAD, ROWS 
- CROSS JOIN UNNEST / LATERAL VIEW EXPLODE

### GROUPING SETS
```sql
FROM events_augmented
GROUP BY GROUPING SETS (
    (os_type, device_type, browser_type),
    (os_type, browser_type),
    (os_type),
    (browser_type)
)
```

### CUBE
```sql
FROM events_augmented
GROUP BY CUBE (os_type, device_type, browser_type)
```

### ROLLUP
```sql
FROM events_augmented
GROUP BY ROLLUP (os_type, device_type, browser_type)
```

### WINDOW FUNCTIONS
- super important!
- function:
    - usually RANK, AVG, SUM, DENSE_RANK
- window:
    - PARTITION BY, ORDER BY, ROWS

### Data Modeling vs Advanced SQL
Symptoms of bad modeling
- slow dashboards
- Queries with lots of CTEs should be materialized (storage cheaper than compute)
- Lots of CASE WHEN statements