# Advanced Apache Spark

## Contents
- Spark Server vs Spark Notebook
- PySpark UDFs vs Scala Spark UDFs
- APIs
- Reminder: Best practices

## Spark Server vs Spark Notebook
| Server                                 | Notebook (Databricks)                                                          |
|----------------------------------------|-------------------------------------------------------------------|
| Every run is fresh (New spark session) | Spark session persist. Need to kill the session using unpersist() |
| Nice for testing for production.       |                                                                   |

### Databricks considerations
- downside of using notebook, code can push to prod right away
- should be connected to Github
    - PR review, CI/CD check

### Caching vs Temp Views
| Temp Views                       | Caching                                                                                                                                                 |
|----------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| Nothing is stored unless cached. | Storage level: RAM only/ Disk only/ both (default)                                                                                                      |
| Recompute query everytime.       | Only good if data fits into RAM                                                                                                                         |
|                                  | Caching to disk = Creating a table (in term of speed).  <br>So rule of thumb is<br>cache for RAM.<br>Materialized view/staging table if spill to disk.  |
|                                  | In notebook, unpersist cached data (not auto delete)                                                                                                    |

### Caching vs BROADCAST JOIN
|             | Caching                                         | Broadcast Join                           |
|-------------|-------------------------------------------------|------------------------------------------|
| Similarity  | Stores in RAM                                   | Stores in RAM                            |
| Differences | Partition data                                  | Do not partition data                    |
|             | Different partition sent to different executors | Whole table sent to all executors        |
|             | Works with bigger table                         | One table need to be small (several GBs) |

#### BROADCAST JOIN optimization
Two ways:
- Set limit: spark.sql.autoBroadcastJoinThreshold
- No limit: Use broadcast(df)

## PySpark UDFs vs Scala Spark UDFs
### Scala 
- compiled language within JVM family. 
- Spark native language/API. Most features appear here 1st
- Only consider this language when working with massive dataset or UDAFs - user defined aggregate functions
- `dataset API` allow us to directly use scala functions

### Python
- works well most of the time
- performance drops when handling massive dataset

## SparkSQL vs DataFrame vs Dataset
- left to right: more advanced
- SparkSQL: good for collab with data scientist
- DataFrame: if pipeline in pyspark (but less functionalities in unit and integration tests)
- Dataset: if pipeline in Scala Spark (best has everything but learning curve)

## Reminder: Best Practices

### Parquet - amazing file format
- Run-length encoding allows powerful compression
- Do not use global .sort()
- Use .sortWithinPartitions
    - parallelizable for distributed computing

### Spark Tuning
#### Executor RAM
- do not auto set to 16GB. Test a little bit.

#### Driver RAM
- do not change it unless
    - df.collect() or very complex job

#### Shuffle Partitions
- default is 200
- Aim for ~100MB per partition and then test 
    - example: if 200GB, 2000 , then test also 1000, 3000

#### Adaptive Query Execution AQE
- spark.sql.adaptive.enabled = True
- waste if data is not skewed.