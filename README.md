# Superside challenge resolution

[![Kubernetes](https://img.shields.io/badge/kubernetes-1.3-blue.svg?logo=kubernetes&labelColor=lightgray)](<https://kubernetes.io/>) [![Terraform](https://img.shields.io/badge/terraform-1.5-blue.svg?logo=terraform&labelColor=lightgray)](<https://www.terraform.io/>) <br>

[![Airbyte](https://img.shields.io/badge/airbyte-0.64.4-blue.svg?logo=airbyte&labelColor=lightgray)](https://airflow.apache.org/docs/apache-airflow/2.6.3/index.html) [![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-2.6.3-green.svg?logo=apacheairflow)](https://airflow.apache.org/docs/apache-airflow/2.6.3/index.html) [![Python 3.10.12](https://img.shields.io/badge/python-3.10.12-blue.svg?labelColor=%23FFE873&logo=python)](https://www.python.org/downloads/release/python-31012/) ![dbt-version](https://img.shields.io/badge/dbt-version?style=flat&logo=dbt&label=1.5&link=https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fintroduction) <br>

[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://docs.astral.sh/ruff/) [![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://black.readthedocs.io/en/stable/) [![Imports: isort](https://img.shields.io/badge/%20imports-isort-%231674b1?style=flat&labelColor=ef8336)](https://pycqa.github.io/isort/)<br>

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org) [![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://pre-commit.com/)

Resolution of the Superside challenge for the Lead Data Engineer role.

## Directories structure

This is the structure of the project.

```text
.
├── .dockerignore
├── .env.dbt.local.example
├── .env.services.local.example
├── .github
│   └── workflows
│       └── pull-request.workflow.yaml
├── .gitignore
├── .markdownlint.json
├── .pre-commit-config.yaml
├── .python-version
├── .sqlfluffignore
├── .vscode
│   ├── extensions.json
│   └── settings.json
├── CONTRIBUTING.md
├── Dockerfile
├── LICENSE
├── Makefile
├── README.md
├── dags
│   ├── .airflowignore
│   ├── settings.py
│   └── transformations.py
├── dbt
│   └── superside
│       ├── .sqlfluff
│       ├── README.md
│       ├── analyses
│       │   └── .gitkeep
│       ├── dbt_project.yml
│       ├── logs
│       ├── macros
│       │   ├── .gitkeep
│       │   ├── generate_schema_name.sql
│       │   ├── intermediate
│       │   │   ├── extract_number.sql
│       │   │   └── map_categories.sql
│       │   └── macros.yml
│       ├── models
│       │   ├── intermediate
│       │   │   ├── _intermediate__models.yml
│       │   │   └── int_engagement_metrics.sql
│       │   ├── marts
│       │   │   ├── _marts__models.yml
│       │   │   ├── fct_engagement_metrics.sql
│       │   │   └── project_engagement.sql
│       │   └── staging
│       │       ├── _clients__models.yml
│       │       ├── _clients__sources.yml
│       │       └── stg_clients__engagement_metrics.sql
│       ├── packages.yml
│       ├── profiles.yml
│       ├── seeds
│       │   ├── .gitkeep
│       │   ├── marts
│       │   │   └── dim_project.csv
│       │   └── seeds.yml
│       ├── snapshots
│       │   └── .gitkeep
│       └── tests
│           └── .gitkeep
├── docker-compose.yml
├── infra
│   ├── .terraform.lock.hcl
│   ├── airbyte-values.yml
│   ├── airbyte.tf
│   ├── airflow-values.yml
│   ├── airflow.tf
│   ├── providers.tf
│   └── variables.tf
├── mypy.ini
├── noxfile.py
├── poetry.lock
├── pyproject.toml
├── registries.yaml
├── scripts
│   ├── clients_postgres_init.sh
│   └── warehouse_postgres_init.sh
└── source_data
    ├── dim_project.csv
    └── engagement_metrics_raw.csv

23 directories, 60 files
```

## What you'll need

This solution is runs in a local kubernetes cluster, so is containerized. You'll need the following mandatory tools in your local machine:

- [k3d](https://k3d.io/v5.6.0/#installation) for the local k8s cluster
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) to manage the k8s cluster through the CLI
- [Docker and docker-compose](https://docs.docker.com/get-docker/)
  - Beware that you'll need around 10 GB of RAM available to allocate (check [this link](https://docs.docker.com/desktop/settings/#resources) to see how in Docker Desktop)
- [Terraform](https://developer.hashicorp.com/terraform/install?product_intent=terraform)
- [GNU Make](https://www.gnu.org/software/make/)
- [poetry](https://python-poetry.org/docs/#installing-with-the-official-installer) to handle python dependencies
  - There's an useful make rule for this one, so you can skip its installation

Depending on your OS your installation process will be different. If you're in macOS you can run:

```bash
brew install k3d docker docker-compose tfenv
tfenv install 1.5.6
tfenv use 1.5.6
```

There are other optional dependencies:

- [Lens](https://k8slens.dev/) to easily manage the k8s cluster
- [DBeaver](https://dbeaver.io/download/) as a desktop SQL client like
- The recommended VS Code extensions

## Architecture overview

The selected data stack is as follows:

- [Airbyte](https://airbyte.com/) for data movement
- [Airflow](https://airflow.apache.org/) for tasks orchestration
- [dbt](https://docs.getdbt.com/) for data modeling
- [Postgres](https://www.postgresql.org/) for data storage

Airbyte and Airflow are installed in the kubernetes cluster via helm through its terraform providers.

<img src="./images/cluster.png" alt="cluster" style="vertical-align:middle"><br>

## Setup

Let's dive into the setup process.

### 1. Generate the environment variables

Open a shell in your machine, and navigate to this directory. Then run:

```bash
make generate-dotenv
```

This will generate two `.env` files with predefined values. Please, go ahead and open it! If you want to modify some values, just take into account that this may break some things.

### 2. Install the project dependencies

Run these commands in this sequence:

```bash
make install-poetry
make install-project
make dbt-install-pkgs
```

Optionally, if you've cloned the repo, you can run:

```bash
make install-pre-commit
```

To install the pre-commit hooks and play around with them.

### 3. Create an empty k8s cluster in your machine

> :warning: Remember to assign the 10 GB of RAM in Docker Desktop.

Run these command and wait a while for the cluster to be ready:

```bash
make cluster-create
```

You can monitor its state with Lens. Anyway, you can check the pods status from the terminal:

```bash
watch -d kubectl get pods -A
```

Wait until they're in the `Running` state.

Also, this command creates some useful services which you can check that are running both with Docker Desktop or by running:

```bash
docker ps
```
