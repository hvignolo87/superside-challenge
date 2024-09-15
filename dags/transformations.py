from datetime import datetime, timedelta

from airflow.decorators import dag
from airflow.operators.empty import EmptyOperator
from airflow.utils.trigger_rule import TriggerRule
from cosmos import (
    DbtTaskGroup,
    ExecutionConfig,
    ExecutionMode,
    LoadMode,
    ProfileConfig,
    ProjectConfig,
    RenderConfig,
    TestBehavior,
)
from settings import (
    DBT_PROFILE_NAME,
    DBT_PROFILES_FILE,
    DBT_PROJECT_DIR,
    DBT_PROJECT_NAME,
    DBT_TARGET_NAME,
    SLA_MINUTES,
)

DEFAULT_ARGS = {
    "owner": "Data Engineering",
    "retries": 0,
}


@dag(
    dag_id="transformations",
    description="dbt transformations pipeline",
    default_args=DEFAULT_ARGS,
    tags=[
        "analytics_engineering",
        "cosmos",
        "data_pipeline",
        "data_engineering",
        "dbt",
        "PostgreSQL",
        "superside_challenge",
        "T",
        "transformations",
    ],
    schedule="0 6 * * *",
    start_date=datetime(2024, 1, 1),
    max_active_runs=1,
    max_active_tasks=10,
    catchup=False,
)
def dbt_pipeline():
    """
    **Transformations DAG**

    This DAG executes the [dbt](https://www.getdbt.com/product/what-is-dbt) `superside_challenge` project with
    all its transformations using [cosmos](https://astronomer.github.io/astronomer-cosmos/).

    These are the airflow variables related to `dbt`:
    - `DBT_PROJECT_DIR`: the path to the dbt project directory, default is `../dbt/superside_challenge` (we use `../dbt/superside_challenge/` here)
    - `DBT_PROJECT_NAME`: the name of the dbt project, default is `superside_challenge` (we use `superside_challenge` here)
    - `DBT_PROFILES_FILE`: the path to `profiles.yml` file, default is `../dbt/superside_challenge/profiles.yml` (we use `../dbt/superside_challenge/profiles.yml` here)
    - `DBT_PROFILE_NAME`: the name of the profile to use, default is `superside_challenge` (we use `superside_challenge` here)
    - `DBT_TARGET_NAME`: the name of the target to use, default is `dev` (we use `prod` here)
    """  # noqa: E501

    transformations_starts = EmptyOperator(
        task_id="transformations_starts",
    )

    project_config = ProjectConfig(dbt_project_path=DBT_PROJECT_DIR / DBT_PROJECT_NAME)

    profile_config = ProfileConfig(
        profile_name=DBT_PROFILE_NAME,
        profiles_yml_filepath=DBT_PROFILES_FILE,
        target_name=DBT_TARGET_NAME,
    )

    execution_config = ExecutionConfig(
        execution_mode=ExecutionMode.LOCAL,
    )

    operator_args = {
        "append_env": True,
        "install_deps": True,
        "output_encoding": "utf-8",
        "no_version_check": True,
    }

    transformations_render_config = RenderConfig(
        dbt_deps=True,
        load_method=LoadMode.DBT_LS,
        test_behavior=TestBehavior.AFTER_EACH,
    )

    transformations = DbtTaskGroup(
        group_id="transformations",
        render_config=transformations_render_config,
        execution_config=execution_config,
        operator_args=operator_args,
        profile_config=profile_config,
        project_config=project_config,
    )

    sla_check = EmptyOperator(
        task_id="sla_check",
        sla=timedelta(minutes=SLA_MINUTES),
        trigger_rule=TriggerRule.ALL_DONE,
    )

    transformations_starts >> transformations >> sla_check


dbt_pipeline()
