from ast import literal_eval
from pathlib import Path

from airflow.models import Variable

# SLA in minutes
SLA_DEFAULT_VALUE_MINUTES = 60
try:
    SLA_MINUTES = literal_eval(
        Variable.get("DATA_PIPELINE_SLA_MINUTES", f"{SLA_DEFAULT_VALUE_MINUTES}")
    )
except ValueError:
    SLA_MINUTES = SLA_DEFAULT_VALUE_MINUTES

if type(SLA_MINUTES) not in (int, float):
    SLA_MINUTES = SLA_DEFAULT_VALUE_MINUTES

## dbt related vars
DBT_PROJECT_DIR: Path = Path(__file__).parent.parent / Variable.get(
    "DBT_PROJECT_DIR", "dbt"
)
DBT_PROJECT_NAME: str = Variable.get("DBT_PROJECT_NAME", "superside_challenge")
DBT_PROFILES_FILE: Path = DBT_PROJECT_DIR / DBT_PROJECT_NAME / "profiles.yml"
DBT_PROFILE_NAME: str = Variable.get("DBT_PROFILE_NAME", DBT_PROJECT_NAME)
DBT_TARGET_NAME: str = Variable.get("DBT_TARGET_NAME", "dev")
