from pyspark.sql import SparkSession
from config import set_spark_conf
from pipeline import run_pipeline
from queries import *


def main():
    spark = SparkSession.builder.appName("homework").getOrCreate()
    set_spark_conf(spark)
    master_df = run_pipeline(spark)

    # player_avg_kills
    q1 = player_avg_kills(master_df)
    q1.show(1)

    # playlist_counts
    q2 = playlist_counts(master_df)
    q2.show(1)

    # map_counts
    q3 = map_counts(master_df)
    q3.show(1)

    # map_killingspree_medals_counts
    q4 = map_killingspree_medals_counts(master_df)
    q4.show(1)

    q1_unsorted = q1.repartition(4, col("player_gamertag"))
    q2_unsorted = q2.repartition(4, col("playlist_id"))
    q3_unsorted = q3.repartition(4, col("mapid"))
    q4_unsorted = q4.repartition(4, col("mapid"))

    q1_sorted = q1_unsorted.sortWithinPartitions(col("player_gamertag"))
    q2_sorted = q2_unsorted.sortWithinPartitions(col("playlist_id"))
    q3_sorted_a = q3_unsorted.sortWithinPartitions(col("map_name"), col("mapid"))
    q3_sorted_b = q3_unsorted.sortWithinPartitions(col("mapid"), col("map_name"))
    q4_sorted_a = q4_unsorted.sortWithinPartitions(col("map_name"), col("mapid"))
    q4_sorted_b = q4_unsorted.sortWithinPartitions(col("mapid"), col("map_name"))

    # below part need to be tested in iceberg
    q1_unsorted.write.mode("overwrite").saveAsTable("bootcamp.q1_unsorted")
    q2_unsorted.write.mode("overwrite").saveAsTable("bootcamp.q2_unsorted")
    q3_unsorted.write.mode("overwrite").saveAsTable("bootcamp.q3_unsorted")
    q4_unsorted.write.mode("overwrite").saveAsTable("bootcamp.q4_unsorted")
    q1_sorted.write.mode("overwrite").saveAsTable("bootcamp.q1_sorted")
    q2_sorted.write.mode("overwrite").saveAsTable("bootcamp.q2_sorted")
    q3_sorted_a.write.mode("overwrite").saveAsTable("bootcamp.q3_sorted_a")
    q3_sorted_b.write.mode("overwrite").saveAsTable("bootcamp.q3_sorted_b")
    q4_sorted_a.write.mode("overwrite").saveAsTable("bootcamp.q4_sorted_a")
    q4_sorted_b.write.mode("overwrite").saveAsTable("bootcamp.q4_sorted_b")

    result1 = spark.sql("""
                        SELECT SUM(file_size_in_bytes) as size, COUNT(1) as num_files, 'sorted' 
                        FROM demo.bootcamp.q1_sorted.files
                        UNION ALL
                        SELECT SUM(file_size_in_bytes) as size, COUNT(1) as num_files, 'unsorted' 
                        FROM demo.bootcamp.q1_unsorted.files
                        """)
    result1.show()

    result2 = spark.sql("""
                        SELECT SUM(file_size_in_bytes) as size, COUNT(1) as num_files, 'sorted' 
                        FROM demo.bootcamp.q2_sorted.files
                        UNION ALL
                        SELECT SUM(file_size_in_bytes) as size, COUNT(1) as num_files, 'unsorted' 
                        FROM demo.bootcamp.q2_unsorted.files
                        """)
    result2.show()

    result3 = spark.sql("""
                        SELECT SUM(file_size_in_bytes) as size, COUNT(1) as num_files, 'sorted_a' 
                        FROM demo.bootcamp.q3_sorted_a.files
                        UNION ALL
                        SELECT SUM(file_size_in_bytes) as size, COUNT(1) as num_files, 'sorted_b' 
                        FROM demo.bootcamp.q3_sorted_b.files
                        UNION ALL
                        SELECT SUM(file_size_in_bytes) as size, COUNT(1) as num_files, 'unsorted' 
                        FROM demo.bootcamp.q3_unsorted.files
                        """)
    result3.show()

    result4 = spark.sql("""
                        SELECT SUM(file_size_in_bytes) as size, COUNT(1) as num_files, 'sorted_a' 
                        FROM demo.bootcamp.q4_sorted_a.files
                        UNION ALL
                        SELECT SUM(file_size_in_bytes) as size, COUNT(1) as num_files, 'sorted_b' 
                        FROM demo.bootcamp.q4_sorted_b.files
                        UNION ALL
                        SELECT SUM(file_size_in_bytes) as size, COUNT(1) as num_files, 'unsorted' 
                        FROM demo.bootcamp.q4_unsorted.files
                        """)
    result4.show()


if __name__ == "__main__":
    main()
