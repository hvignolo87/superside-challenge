#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER:-warehouse}" --dbname "${POSTGRES_DB:-warehouse}" <<-EOSQL
	CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
EOSQL
