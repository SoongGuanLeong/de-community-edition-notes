from pyspark.sql import SparkSession


def set_spark_conf(spark: SparkSession):
    # spark settings
    spark.conf.set("spark.sql.autoBroadcastJoinThreshold", "-1")

    # Iceberg catalog + default namespace
    spark.conf.set("spark.sql.catalog.demo", "org.apache.iceberg.spark.SparkCatalog")
    spark.conf.set("spark.sql.catalog.demo.type", "rest")
    spark.conf.set("spark.sql.catalog.demo.uri", "http://iceberg-rest:8181")
    spark.conf.set("spark.sql.catalog.demo.default-namespace", "bootcamp")
