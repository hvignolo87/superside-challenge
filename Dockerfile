# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.10.10
FROM python:${PYTHON_VERSION} AS base

USER root

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_ROOT_USER_ACTION="ignore"
ENV PATH="${PATH}:/root/.local/bin"

WORKDIR /opt/airflow

ARG POETRY_VERSION=1.6.1
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e && \
    apt-get update -qy && \
    pip install -U pip && \
    curl -sSL https://install.python-poetry.org | POETRY_VERSION=${POETRY_VERSION} python3 - && \
    poetry config virtualenvs.create false

COPY . .

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=cache,target=/root/.cache/pypoetry \
    poetry install --no-interaction --all-extras --sync --without dev

WORKDIR /opt/airflow/dbt/superside

RUN poetry run dbt deps

WORKDIR /opt/airflow
