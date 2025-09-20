from pyspark.sql import SparkSession, DataFrame
from pyspark.sql.functions import *

spark = SparkSession.builder.appName("homework").getOrCreate()

spark.conf.set("spark.sql.autoBroadcastJoinThreshold", "-1")

maps = spark.read.csv("data/maps.csv", header=True, inferSchema=True)
match_details = spark.read.csv("data/match_details.csv", header=True, inferSchema=True)
matches = spark.read.csv("data/matches.csv", header=True, inferSchema=True)
medals_matches_players = spark.read.csv(
    "data/medals_matches_players.csv", header=True, inferSchema=True
)
medals = spark.read.csv("data/medals.csv", header=True, inferSchema=True)

maps.show()
match_details.show()
matches.show()
medals_matches_players.show()
medals.show()


def write_bucketed(df: DataFrame, table_name: str, buckets: int, bucket_col: str):
    # Bucketed tables must be saved as Hive tables for Spark to use bucketing at join time
    (
        df.write.mode("overwrite")
        .bucketBy(buckets, bucket_col)
        .sortBy(bucket_col)  # helps colocate + reduces shuffle
        .saveAsTable(table_name)
    )


write_bucketed(match_details, "md_bucketed", 16, "match_id")
write_bucketed(matches, "m_bucketed", 16, "match_id")
write_bucketed(medals_matches_players, "mmp_bucketed", 16, "match_id")

md_b = spark.table("md_bucketed")
m_b = spark.table("m_bucketed")
mmp_b = spark.table("mmp_bucketed")

# rename columns to avoid ambiguity
mmp_b = mmp_b.withColumnRenamed("player_gamertag", "mmp_player_gamertag")
maps = maps.withColumnRenamed("name", "map_name").withColumnRenamed(
    "description", "map_description"
)
medals = medals.withColumnRenamed("name", "medal_name").withColumnRenamed(
    "description", "medal_description"
)

master = (
    md_b.join(m_b, on="match_id")
    .join(mmp_b, on="match_id")
    .join(broadcast(maps), on="mapid", how="left")
    .join(broadcast(medals), on="medal_id", how="left")
)

master.createOrReplaceTempView("master")

master.describe().show()

master.show(truncate=False)

# question 1
q1 = (
    master.groupBy("match_id", "player_gamertag")
    .agg(max("player_total_kills").alias("kills_in_match"))
    .groupBy("player_gamertag")
    .agg(avg("kills_in_match").alias("avg_kills_per_match"))
    .orderBy(desc("avg_kills_per_match"))
)
q1.show(1)

# question 2
q2 = (
    master.groupBy("playlist_id")
    .agg(count_distinct("match_id").alias("num_matches"))
    .orderBy(desc("num_matches"))
)
q2.show(1)

# question 3
q3 = (
    master.groupBy("mapid", "map_name")
    .agg(count_distinct("match_id").alias("num_matches"))
    .orderBy(desc("num_matches"))
)
q3.show(1)

# question 4
q4 = (
    master.filter(col("medal_name") == "Killing Spree")
    .groupBy("mapid", "map_name")
    .agg(count("medal_name").alias("num_killing_spree_medals"))
    .orderBy(desc("num_killing_spree_medals"))
)
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
