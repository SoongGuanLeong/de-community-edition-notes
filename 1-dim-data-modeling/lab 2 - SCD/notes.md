# Slowly Changing Dimension SCD
SCD vs fixed dimension. And how it relates to idempotency.

## Idempotency is CRITICAL
Pipelines should **ALWAYS** produce the same results
- Regardless of the day you run it
- Regardless of how many times you run it
- Regardless of the hour you run it

## Why is it hard to troubleshoot non-idempotency
- no error. Pipeline still run. (Silent failure)
- Usually downstream team discover it first when chart looks different.

## Causes
- INSERT INTO w/o TRUNCATE (Advice: NEVER use INSERT INTO)
    - use MERGE or INSERT OVERWRITE
- using start_date w/o end_date (unbounded windows)
- trigger too early (when there is no/partial data)
- pipeline jobs dependencies incorrect
- relying on 'latest partition' of wrongly modeled SCD source

## Pains/Consequences
- backfill inconsistencies
- bugs hard to troubleshoot
- unit test cannot replicate production behaviour
- Silent failure

## Options to model changing dim
- latest snapshot (not idempotent)
- daily partitioned snapshot
- SCD 1,2,3

## SCD Types
### Type 0
Fixed dimension (e.g. birthday)
### Type 1
only store latest value (not idempotent)
### Type 2
- store all history
- have start_date & end_date (9999-12-31 if current)
- purely idempotent
### Type 3
- only have original and current
- lose info if dim changes more than once
