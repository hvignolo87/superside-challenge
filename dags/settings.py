from ast import literal_eval
import json
from pathlib import Path

from airflow.models import Variable
from kubernetes.client import models as k8s

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
DBT_PROJECT_NAME: str = Variable.get("DBT_PROJECT_NAME", "superside")
DBT_PROFILES_FILE: Path = DBT_PROJECT_DIR / DBT_PROJECT_NAME / "profiles.yml"
DBT_PROFILE_NAME: str = Variable.get("DBT_PROFILE_NAME", DBT_PROJECT_NAME)
DBT_TARGET_NAME: str = Variable.get("DBT_TARGET_NAME", "dev")

# dbt k8s vars
DBT_IMAGE = Variable.get("DBT_IMAGE", "registry:5000/superside:latest")

DEFAULT_DBT_JOB_NODE_SELECTOR = json.dumps({"component": "jobs"})
try:
    DBT_JOB_NODE_SELECTOR = json.loads(
        Variable.get("DBT_JOB_NODE_SELECTOR", DEFAULT_DBT_JOB_NODE_SELECTOR)
    )
except ValueError:
    DBT_JOB_NODE_SELECTOR = json.loads(DEFAULT_DBT_JOB_NODE_SELECTOR)

DEFAULT_DBT_K8S_STARTUP_TIMEOUT_SECONDS = 300
try:
    DBT_K8S_STARTUP_TIMEOUT_SECONDS = literal_eval(
        Variable.get(
            "DBT_K8S_STARTUP_TIMEOUT_SECONDS", DEFAULT_DBT_K8S_STARTUP_TIMEOUT_SECONDS
        )
    )
except ValueError:
    DBT_K8S_STARTUP_TIMEOUT_SECONDS = DEFAULT_DBT_K8S_STARTUP_TIMEOUT_SECONDS


DBT_K8S_REQUESTS_CPU = Variable.get("DBT_K8S_REQUESTS_CPU", "300m")
DBT_K8S_REQUESTS_MEMORY = Variable.get("DBT_K8S_REQUESTS_MEMORY", "256Mi")
DBT_K8S_RESOURCES = k8s.V1ResourceRequirements(
    requests={"cpu": DBT_K8S_REQUESTS_CPU, "memory": DBT_K8S_REQUESTS_MEMORY},
    limits={"memory": DBT_K8S_REQUESTS_MEMORY},
)

DBT_K8S_ENV_VARS = [
    k8s.V1EnvVar(
        name="DBT_USER",
        value=Variable.get("DBT_USER", "warehouse"),
    ),
    k8s.V1EnvVar(
        name="DBT_PASSWORD",
        value=Variable.get("DBT_PASSWORD", "warehouse"),
    ),
    k8s.V1EnvVar(
        name="DBT_HOST",
        value=Variable.get("DBT_HOST", "warehouse"),
    ),
    k8s.V1EnvVar(
        name="DBT_PORT",
        value=Variable.get("DBT_PORT", "5432"),
    ),
    k8s.V1EnvVar(
        name="DBT_DB",
        value=Variable.get("DBT_DB", "warehouse"),
    ),
]
