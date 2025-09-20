# Core Elements in Fact Data Modeling
## fact vs dimension
- the difference can be blurry depending on context
- facts can be aggregated and turned into dimension
- `CASE WHEN`-bucketise facts into dim to reduce cardinality(<10)
- **dim_is_active** can be both dim and fact bcuz it is affected by login events

| Dimensions                                | Facts                                    |
|-------------------------------------------|------------------------------------------|
| Usually used in GROUP BY during analytics | Usually aggregated using SUM, AVG, COUNT |
| Can be both high & low cardinality        | Usually higher volume than dim           |
| Snapshot of a state                       | Comes from events and logs               |

### Airbnb Example
Blurry example: Price of a night on Airbnb
- host can set the price which sound like an event
- can be easily SUM, AVG, COUNT

BUT 
- Price here is a dim bcuz it is affected by the state of things set by the owner
- Think of **a fact has to be logged** like an event
- fact here would be **the event** the owner changed the settings but the price is a **dim from the settings**

### Fact/Dimension - Boolean/existence-based
- dim_is_active, dim_bought_sth 
    - usually these are on hourly grain
- dim_has_ever_booked, dim_ever_active, dim_ever_labeled_fake
    - 'ever' is like one time switch, once done never go back
- 'days since': days_since_last_active, days_since_signup
    - common retention analytical patterns
    - topic: J curves

### Fact/Dimension - Categorical
- dim derived from facts
- often calculated from `CASE WHEN` & 'bucketizing'
- can be from multiple columns/conditions
- once set it is hard/expensive to change (like FB friends limit)

### dim_is_activated vs dim_is_active
- dim_is_activated: signup
- dim_is_active: growth

## Date List Data Structure
- normally a `users_cumulated` table look like this

| user_id | date       | dates_active                         |
|---------|------------|--------------------------------------|
| 32      | 2023-01-01 | {2022-12-25, 2022-12-31, 2023-01-01} |

- instead, turns `dates_active` into `datelist_int`
- this format below is better for compression

| user_id | date       | datelist_int    |
|---------|------------|-----------------|
| 32      | 2023-01-01 | 100000010000001 |