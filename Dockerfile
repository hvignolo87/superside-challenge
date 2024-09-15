# syntax=docker/dockerfile:1
FROM apache/airflow:2.6.3-python3.10

USER root

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
	--mount=type=cache,target=/var/lib/apt,sharing=locked <<END
		apt-get update && \
		apt-get install --no-install-recommends --no-install-suggests -y \
		build-essential \
		gcc \
		libtool \
		libyaml-0-2 \
		libyaml-dev \
		libyaml-doc \
		libpq-dev \
		make \
		python3-dev \
		python3-pip \
		python3-venv \
		python3-wheel
END

USER airflow

RUN --mount=type=cache,target=/home/airflow/.cache/pip \
	pip install --upgrade pip && \
	pip install --no-cache-dir \
	"apache-airflow-providers-dbt-cloud==3.3.0" \
	"apache-airflow-providers-postgres==5.5.1" \
	"astronomer-cosmos[dbt-postgres]==1.2.5" \
	"dbt-core==1.5.6"
