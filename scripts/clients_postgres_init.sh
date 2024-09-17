#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER:-clients}" --dbname "${POSTGRES_DB:-clients}" <<-EOSQL

	CREATE TABLE IF NOT EXISTS public.engagement_metrics (
		project_id UUID,
		engagement_id UUID,
		customer_id VARCHAR(65535),
		customer_name VARCHAR(65535),
		engagement_date VARCHAR(65535),
		revenue VARCHAR(65535),
		revenue_usd VARCHAR(65535),
		service VARCHAR(65535),
		sub_service VARCHAR(65535),
		engagement_type VARCHAR(65535),
		employee_count VARCHAR(65535),
		comments VARCHAR(65535),
		project_ref UUID,
		engagement_reference VARCHAR(65535),
		client_revenue VARCHAR(65535),
		service_type VARCHAR(65535),
		detailed_sub_service VARCHAR(65535)
	);

	COPY public.engagement_metrics
    FROM '/docker-entrypoint-initdb.d/source_data/engagement_metrics_raw.csv'
    DELIMITER ','
    CSV HEADER;
EOSQL
