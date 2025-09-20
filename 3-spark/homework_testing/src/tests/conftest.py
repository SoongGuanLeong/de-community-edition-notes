import pytest
import os
from pyspark.sql import SparkSession

# Ensure Spark is configured correctly
os.environ["SPARK_HOME"] = r"C:\tools\spark-3.5.6-bin-hadoop3"
os.environ["PATH"] += os.pathsep + os.path.join(os.environ["SPARK_HOME"], "bin")


@pytest.fixture(scope="session")
def spark():
    return SparkSession.builder.master("local").appName("chispa").getOrCreate()
