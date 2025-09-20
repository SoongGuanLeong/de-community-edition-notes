from chispa.dataframe_comparer import *
from ..jobs.job1 import do_actors_history_scd_transformation
from collections import namedtuple

ActorYear = namedtuple("ActorYear", "actorid actor year quality_class is_active")
ActorHistoryScd = namedtuple(
    "ActorHistoryScd",
    "actorid actor quality_class is_active start_year end_year current_year",
)


def test_scd_generation(spark):
    source_data = [
        ActorYear(1, "Actor A", 2018, "Good", True),
        ActorYear(1, "Actor A", 2019, "Good", True),
        ActorYear(1, "Actor A", 2020, "Bad", True),
        ActorYear(2, "Actor B", 2019, "Good", False),
        ActorYear(2, "Actor B", 2020, "Good", True),
    ]
    source_df = spark.createDataFrame(source_data)

    source_df.createOrReplaceTempView("actors")
    actual_df = do_actors_history_scd_transformation(spark, source_df)

    expected_data = [
        ActorHistoryScd(1, "Actor A", "Good", True, 2018, 2019, 2020),
        ActorHistoryScd(1, "Actor A", "Bad", True, 2020, 2020, 2020),
        ActorHistoryScd(2, "Actor B", "Good", False, 2019, 2019, 2020),
        ActorHistoryScd(2, "Actor B", "Good", True, 2020, 2020, 2020),
    ]
    expected_df = spark.createDataFrame(expected_data)
    assert_df_equality(actual_df, expected_df, ignore_nullable=True)
