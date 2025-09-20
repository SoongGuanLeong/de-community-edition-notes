from pyspark.sql import SparkSession

query = """
    WITH with_previous AS (
    SELECT 
        actorid,
        actor, 
        year AS current_year, 
        quality_class, 
        is_active,
        LAG(quality_class,1)
            OVER(PARTITION BY actorid ORDER BY year) AS previous_quality_class,
        LAG(is_active,1)
            OVER(PARTITION BY actorid ORDER BY year) AS previous_is_active
    FROM actors
    WHERE year <= 2020
    ),
    with_indicator AS (
        SELECT *,
            CASE WHEN quality_class <> previous_quality_class THEN 1
                WHEN is_active <> previous_is_active THEN 1
                ELSE 0
            END change_indicator
        FROM with_previous
    ),
    with_streaks AS (
    SELECT *,
        SUM(change_indicator)
            OVER(PARTITION BY actorid ORDER BY current_year) AS streak_identifier
    FROM with_indicator
    )
    SELECT
        actorid,
        actor,
        quality_class,
        is_active,
        MIN(current_year) AS start_year,
        MAX(current_year) AS end_year,
        CAST(2020 AS BIGINT) AS current_year
    FROM with_streaks
    GROUP BY actorid, actor, streak_identifier, is_active, quality_class
    ORDER BY actor, actorid, streak_identifier
"""


def do_actors_history_scd_transformation(spark, dataframe):
    dataframe.createOrReplaceTempView("actors")
    return spark.sql(query)


def main():
    spark = (
        SparkSession.builder.master("local").appName("actors_history_scd").getOrCreate()
    )
    output_df = do_actors_history_scd_transformation(spark, spark.table("actors"))
    output_df.write.mode("overwrite").insertInto("players_scd")
