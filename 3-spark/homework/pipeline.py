from pyspark.sql import SparkSession
from io_utils import read_csv, write_bucketed
from pyspark.sql.functions import broadcast


def run_pipeline(spark: SparkSession):
    maps = read_csv(spark, "/home/iceberg/data/maps.csv")
    match_details = read_csv(spark, "/home/iceberg/data/match_details.csv")
    matches = read_csv(spark, "/home/iceberg/data/matches.csv")
    medals_matches_players = read_csv(
        spark, "/home/iceberg/data/medals_matches_players.csv"
    )
    medals = read_csv(spark, "/home/iceberg/data/medals.csv")

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

    return master
