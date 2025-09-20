# Visualization Techniques

## Performant dashboard best practices
- pre-aggregate the data
- dont do JOIN on the fly
- use a low latency storage solution like Druid

## How to build dashboards that make sense
Who is your customers?
- exec (simple, ez to understand immediately)
- analysts (more charts, more density, more exploration capabilities)

## what are the types of question that can be asked?
- top line questions
- trend questions
- composition questions

## What numbers matter?
- total aggregates
- time-based aggregates
- time & entity-based aggregates
- Derivative metrics (WoW, MoM, YoY)
- dimensional mix (%US vs %India, %Android vs %iPhone)
- retention/survivorship(%left after N number of days)

## Why do these numbers matter?
### total aggregates
- get reported to Wall Street
- can easily be used as marketing material
- are the 'top-of-line' & represent how good or bad business is

### time-based aggregates
- get reported to Wall Street
- catch trends faster than totals (bad quarter is a potential signal of bad year)
- identify trends and growth

### time & entity-based aggregates
- easily plug into AB testing
- often included in daily master data
- used by scientists to look cut aggregated fact data in a way that is performant

### derivative metrics
- more sentitive to changes
- % increase is a better indicator than number
- YoY is often the most important metrics companies look at

### directional mix
- identify impact opportunities
- spot trends in dims, not just over time

### retention / survivorship (% left after N of days)
- also called J-curves
- great at predicting lifetime customer value (ltv)
- understand the stickiness of the app