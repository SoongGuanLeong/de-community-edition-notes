# Test (Unit & Integration)

## Bugs
### Where do we find bugs
- dev (best case)
- prod but not show up in table (still ok)
- prod (worst, destroy trust)

### How to catch bugs in dev
- Unit test: test our own code (functions)
- Integration test: test other people's code (from imports etc)
- use of linter like ruff

### How to catch bugs in production
- Write-Audit-Publish: WAP (sth similar to dbt modeling)
- Signal table pattern (sth similar to exactly once processing)

## Software engineering SE
### SE has better quality standards than DE
- bigger risk
    - Server offline is worse than pipeline delay
    - stop the entire business
- industry history
    - SE has been around for more than 50 years while DE is about 15 years.
- Talent
    - DE come from more diverse background than SE.

### When data quality become more important
- data delays impact ML / experiments' decision making (like Airbnb pricing)
- As trust increases on data, risk increases too.

### Why DE teams often overlooked quality 
- mindset different. Rather than building pipelines that last, most just care about if they build more pipelines to answer more question.

### Tradeoff between speed & sustainability
- business wants answer fast
- DE wants to build pipelines that answer many questions and seldom fail

### DE standards will increase over time
- latency: more streaming, micro-batch
- quality: adopt SE best practices, frameworks like Great Expectations
- Completeness: Communication with domain experts
- Ease of access & usability: data products & data modeling

### Doing DE with SE in mind
- Silent failure is bad
- Loud failure is good. (Write more code the `RAISE` errors)
- DRY vs YAGNI
    - DRY: don't repeat yourself
    - YAGNI: you aren't gonna need it
- design documents = pipelines specs sheets
- care about efficiency (DSA, shuffles)