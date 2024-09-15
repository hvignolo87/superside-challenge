#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "warehouse" --dbname "warehouse" <<-EOSQL

	CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

	CREATE SCHEMA IF NOT EXISTS clients;

	CREATE TABLE IF NOT EXISTS clients.engagement_metrics (
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

	COPY clients.engagement_metrics
    FROM '/docker-entrypoint-initdb.d/source_data/engagement_metrics_raw.csv'
    DELIMITER ','
    CSV HEADER;

	CREATE SCHEMA IF NOT EXISTS marts;

	CREATE TABLE marts.dim_project (
		id UUID PRIMARY KEY,
		project_id UUID NOT NULL,
		folder VARCHAR(65535),
		status VARCHAR(65535),
		name VARCHAR(65535),
		staffing_version VARCHAR(65535),
		description VARCHAR(65535),
		internal_description VARCHAR(65535),
		customer_id INT,
		project_service_id INT,
		service VARCHAR(65535),
		sub_service VARCHAR(65535),
		product_id INT,
		product VARCHAR(65535),
		team VARCHAR(65535),
		team_type VARCHAR(65535),
		team_id UUID,
		cpm VARCHAR(65535),
		cpm_id UUID,
		dim_cpm_id UUID,
		quality VARCHAR(65535),
		rate NUMERIC(10, 2),
		discount NUMERIC(5, 2),
		min_estimate NUMERIC(12, 2),
		max_estimate NUMERIC(12, 2),
		sp_estimate NUMERIC(12, 2),
		pm_estimate NUMERIC(12, 2),
		ad_estimate NUMERIC(12, 2),
		delivery VARCHAR(65535),
		is_critical_delivery BOOLEAN,
		is_critical_delivery_success BOOLEAN,
		is_submitted_from_internal BOOLEAN,
		is_created_with_deliverables BOOLEAN,
		is_project_ai_enabled BOOLEAN,
		timezone VARCHAR(65535),
		date_project_created TIMESTAMP,
		date_project_submitted TIMESTAMP,
		date_project_deadline TIMESTAMP,
		date_project_grabbed TIMESTAMP,
		date_project_started TIMESTAMP,
		date_project_ended TIMESTAMP,
		date_project_updated TIMESTAMP,
		source_app VARCHAR(65535)
	);

	COPY marts.dim_project
    FROM '/docker-entrypoint-initdb.d/source_data/dim_project.csv'
    DELIMITER ','
    CSV HEADER;
EOSQL
