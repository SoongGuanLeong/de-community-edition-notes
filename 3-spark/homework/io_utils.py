from pyspark.sql import DataFrame, SparkSession


def read_csv(spark: SparkSession, path: str):
    return spark.read.csv(path, header=True, inferSchema=True)


def write_bucketed(df: DataFrame, table_name: str, buckets: int, bucket_col: str):
    try:
        (
            df.write.format("iceberg")
            .mode("overwrite")
            .bucketBy(buckets, bucket_col)
            .saveAsTable(table_name)
        )
    except Exception as e:
        print(f"Iceberg write failed ({e}), falling back to Spark table")
        (
            df.write.mode("overwrite")
            .bucketBy(buckets, bucket_col)
            .sortBy(bucket_col)
            .saveAsTable(table_name)
        )
