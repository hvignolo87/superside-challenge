.DEFAULT_GOAL := help

# Load .env file if exists
ifneq ($(wildcard ./.env.dbt.local),)
include ./.env.dbt.local
export $$(grep -v '^#' ./.env.dbt.local | xargs)
else
warning_msg:
$(warning There's no .env file for dbt. Please run make generate-dotenv.)
endif

ifneq ($(wildcard ./.env.services.local),)
include ./.env.services.local
export $$(grep -v '^#' ./.env.services.local | xargs)
else
warning_msg:
$(warning There's no .env file for the services. Please run make generate-dotenv.)
endif

.EXPORT_ALL_VARIABLES:
	$$(grep -v '^#' ./.env.dbt.local)
	$$(grep -v '^#' ./.env.services.local)

DOCKER_COMPOSE_CMD = docker compose -f ./docker-compose.yml --env-file .env.services.local

_GREEN='\033[0;32m'
_NC='\033[0m'

define log
	@printf "${_GREEN}$(1)${_NC}\n"
endef


# Reference: https://www.padok.fr/en/blog/beautiful-makefile-awk
.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Environment

.PHONY: generate-dotenv
generate-dotenv: ## Generate new .env files (it overrides the existing ones). Usage: make generate-dotenv
	$(call log, Generating .env files...)
	cp ./.env.services.local.example ./.env.services.local
	cp ./.env.dbt.local.example ./.env.dbt.local

.PHONY: install-poetry
install-poetry: ## Install poetry. Usage: make install-poetry
	$(call log, Installing poetry...)
	curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.6.1 python3 - && \
	export "PATH=${HOME}/.local/bin:${PATH}" && \
	poetry config virtualenvs.in-project true && \
	poetry --version

.PHONY: install-project
install-project: ## Install the project dependencies. Usage: make install-project
	$(call log, Installing project dependencies...)
	poetry install --no-interaction --all-extras --with dev --sync

.PHONY: install-pre-commit
install-pre-commit: ## Install pre-commit and git hooks. Usage: make install-pre-commit
	$(call log, Installing pre-commit and git hooks...)
	poetry run pre-commit install --install-hooks


##@ Linting & Formatting

.PHONY: lint-python
lint-python: ## Lint a Python file. Usage: make lint-python path="./dags/my_file.py"
	$(call log, Linting $(path)...)
	poetry run ruff check $(path)
	poetry run mypy --config-file ./mypy.ini $(path)

.PHONY: format-python
format-python: ## Format a Python file. Usage: make format-python path="./dags/my_file.py"
	$(call log, Formatting $(path)...)
	poetry run isort $(path)
	poetry run black $(path)

.PHONY: lint-sql
lint-sql: ## Lint a SQL file. Usage: make lint-sql path="./path/to/my_file.sql"
	$(call log, Linting $(path)...)
	poetry run sqlfluff lint --config ./.sqlfluff $(path)

.PHONY: fix-sql
fix-sql: ## Apply fixes to a SQL file. Usage: make fix-sql path="./path/to/my_file.sql"
	$(call log, Fixing $(path)...)
	poetry run sqlfluff fix --force --config ./.sqlfluff $(path)

.PHONY: format-sql
format-sql: ## Format a SQL file. Usage: make format-sql path="./path/to/my_file.sql"
	$(call log, Formatting $(path)...)
	poetry run sqlfluff format --config ./.sqlfluff $(path)


##@ Pre-commit hooks

.PHONY: nox-hooks
nox-hooks: ## Run all the pre-commit hooks in a nox session on all the files. Usage: make nox-hooks
	$(call log, Running all the pre-commit hooks in a nox session...)
	poetry run nox --session hooks

.PHONY: pre-commit-hooks
pre-commit-hooks: ## Run all the pre-commit hooks on all the files. Usage: make pre-commit-hooks
	$(call log, Running all the pre-commit hooks...)
	poetry run pre-commit run --hook-stage manual --show-diff-on-failure --all-files


##@ Kubernetes (k3d, helm, terraform)

.PHONY: set-k3d-context
set-k3d-context: ## Set the current context to point to the k3d cluster
	kubectl config use-context k3d-${PROJECT_NAME}

.PHONY: cluster-create
cluster-create: ## Build and start the required docker services and the k3d cluster
	${DOCKER_COMPOSE_CMD} up -d --build
	k3d cluster create ${PROJECT_NAME} \
		--agents 3 \
		--agents-memory 4g \
		--api-port 6443 \
		--k3s-node-label component=airbyte@agent:0 \
		--k3s-node-label component=airflow@agent:1 \
		--k3s-node-label component=jobs@agent:2 \
		--port 8100:80@loadbalancer \
		--servers 1 \
		--servers-memory 4g \
		--network ${PROJECT_NAME} \
		--volume $(PWD):/mnt/host \
		--volume $(PWD)/dags:/mnt/host/dags \
		--volume $(PWD)/dbt:/mnt/host/dbt \
		--volume $(PWD)/registries.yaml:/etc/rancher/k3s/registries.yaml \
		--k3s-arg '--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%@agent:*' \
  		--k3s-arg '--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%@agent:*'

.PHONY: cluster-delete
cluster-delete: ## Stop and delete the k3d cluster
	k3d cluster delete ${PROJECT_NAME}
	${DOCKER_COMPOSE_CMD} down -v

.PHONY: cluster-stop
cluster-stop: ## Stop the k3d cluster
	${DOCKER_COMPOSE_CMD} stop
	k3d cluster stop ${PROJECT_NAME}

.PHONY: cluster-start
cluster-start: ## Start the stopped k3d cluster
	${DOCKER_COMPOSE_CMD} start
	k3d cluster start ${PROJECT_NAME}

.PHONY: cluster-install-apps
cluster-install-apps: set-k3d-context ## Install the required apps in the k8s cluster
	$(call log, Installing apps in the k8s cluster...)
	cd infra && \
	terraform init && \
	terraform apply -auto-approve -target="helm_release.airbyte" -target="helm_release.airflow"

.PHONY: cluster-uninstall-apps
cluster-uninstall-apps: set-k3d-context ## Uninstall the required apps in the k8s cluster
	$(call log, Uninstalling apps in the k8s cluster...)
	cd infra && terraform init && terraform destroy -auto-approve

.PHONY: cluster-setup-airbyte
cluster-setup-airbyte: set-k3d-context ## Setup the Airbyte workspace with sources and destinations
	cd infra && \
	terraform init && \
	terraform apply -auto-approve \
		-target="airbyte_source_postgres.clients_db" \
		-target="airbyte_destination_postgres.warehouse" \
		-target="airbyte_connection.clients_connection"

.PHONY: cluster-local-image
cluster-local-image: ## Push the local image to the local registry
	$(call log, Pushing the local image to the local registry...)
	docker build -f Dockerfile -t ${PROJECT_NAME}:latest . && \
	docker image tag ${PROJECT_NAME}:latest localhost:${REGISTRY_PORT_HOST}/${PROJECT_NAME}:latest && \
	docker push localhost:${REGISTRY_PORT_HOST}/${PROJECT_NAME}:latest


##@ Docker

.PHONY: build
build: ## Build docker-defined services, can be passed specific service(s) to only build those. Usage: make build services="warehouse"
	$(call log, Building images...)
	${DOCKER_COMPOSE_CMD} build $(services)

.PHONY: up
up: ## Create docker-defined services, can be passed specific service(s) to only start those. Usage: make up services="warehouse"
	$(call log, Creating services in detached mode...)
	${DOCKER_COMPOSE_CMD} up -d $(services)

.PHONY: start
start: ## Start docker-defined services, can be passed specific service(s) to only start those. Usage: make start services="warehouse"
	$(call log, Starting services...)
	${DOCKER_COMPOSE_CMD} start $(services)

.PHONY: stop
stop: ## Stop docker-defined services, can be passed specific service(s) to only stop those. Usage: make stop services="warehouse"
	$(call log, Stopping services $(services)...)
	${DOCKER_COMPOSE_CMD} stop $(services)

.PHONY: down
down: ## Delete docker-defined services, can be passed specific service(s) to only delete those. Usage: make down services="warehouse"
	$(call log, Deleting services $(services)...)
	${DOCKER_COMPOSE_CMD} down -v $(services)

.PHONY: clean
clean: down ## Delete containers and volumes
	$(call log, Deleting services and volumes...)
	docker volume prune --all --force

.PHONY: prune
prune: ## Delete everything in docker
	$(call log, Deleting everything...)
	docker system prune --all --volumes --force && docker volume prune --all --force


##@ Airflow

.PHONY: airflow-shell
airflow-shell: ## Open a shell inside the Airflow scheduler. Usage: make airflow-shell
	$(call log, Opening Airflow shell in the scheduler...)
	$(DOCKER_COMPOSE_CMD) exec airflow-scheduler /bin/bash

.PHONY: airflow-tasks-test
airflow-tasks-test: ## Tests an Airflow task. Usage: make airflow-tasks-test dag="etl" task="obt_sourcing_rs" args="20231005"
	$(call log, Testing the task $(task) in the DAG $(dag) in Airflow...)
	$(DOCKER_COMPOSE_CMD) exec airflow-scheduler airflow tasks test $(dag) $(task) $(args)

.PHONY: airflow-conn-test
airflow-conn-test: ## Tests an Airflow connection. Usage: make airflow-conn-test id="postgres_warehouse"
	$(call log, Testing the connection $(id) in Airflow...)
	$(DOCKER_COMPOSE_CMD) exec airflow-scheduler airflow connections test $(id)


##@ dbt

.PHONY: dbt-run-model
dbt-run-model: ## Run a dbt model. Usage: make dbt-run-model node="--select +stg_model"
	$(call log, Running dbt model $(node)...)
	poetry run dbt run $(node) --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME}

.PHONY: dbt-test-model
dbt-test-model: ## Execute tests of a dbt model. Usage: make dbt-test-model node="--select stg_model"
	$(call log, Testing dbt model $(node)...)
	poetry run dbt test $(node) --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME}

.PHONY: dbt-build-model
dbt-build-model: ## Build (run and test) a dbt model. Usage: make dbt-build-model node="--select stg_model"
	$(call log, Testing dbt model $(node)...)
	poetry run dbt build $(node) --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME}

.PHONY: dbt-seed-model
dbt-seed-model: ## Seed a dbt model. Usage: make dbt-seed-model node="--select +stg_model"
	$(call log, Seeding dbt model $(node)...)
	poetry run dbt seed $(node) --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME}

.PHONY: dbt-run-macro
dbt-run-macro: ## Run a dbt macro. Usage: make dbt-run-macro name="delete_deleted_ids" args='{"db": "warehouse"}'
	$(call log, Running dbt macro $(name)...)
	poetry run dbt run-operation $(name) --args '$(args)' --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME}

.PHONY: dbt-show-model
dbt-show-model: ## Show a dbt model. Usage: make dbt-show-model node="--select +stg_model"
	$(call log, Showing dbt model $(node)...)
	poetry run dbt show $(node) --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME}

.PHONY: dbt-compile
dbt-compile: ## Compile the dbt project. Usage: make dbt-compile
	$(call log, Compiling the dbt project...)
	poetry run dbt compile --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME}

.PHONY: dbt-install-pkgs
dbt-install-pkgs: ## Install dbt packages. Usage: make dbt-install-pkgs
	$(call log, Installing packages...)
	poetry run dbt deps --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME}

.PHONY: dbt-debug
dbt-debug: ## Debug the dbt project. Usage: make dbt-debug
	$(call log, Debugging the dbt project...)
	poetry run dbt debug --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME}

.PHONY: dbt-docs-generate
dbt-docs-generate: ## Generate documentation of the dbt project. Usage: make dbt-docs-generate
	$(call log, Generating the documentation website for the dbt project...)
	cd dbt/${PROJECT_NAME} && \
	poetry run dbt docs generate --compile && \
	cd ../.. && \
	poetry run python3 scripts/hide_dbt_resources_from_docs.py \
		--exclude-macro delete_deleted_ids \
		--exclude-macro generate_schema_name \
		--dbt-project-dir dbt/${PROJECT_NAME}

.PHONY: dbt-docs-serve
dbt-docs-serve: ## Serve the documentation website for the dbt project. Usage: make dbt-docs-serve port="8888"
	$(call log, Serving the documentation website for the dbt project...)
	poetry run dbt docs serve --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME} --browser --port $(port)

.PHONY: dbt-gen-source-yaml
dbt-gen-source-yaml: ## Generate lightweight YAML for sources. Usage: make dbt-gen-source-yaml db="warehouse" schema="cbo"
	$(call log, Generating sources for $(db).$(schema)...)
	poetry run dbt run-operation generate_source --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME} --args \
		'{ \
			"database_name": "$(db)", \
			"schema_name": "$(schema)", \
			"generate_columns": true, \
			"include_schema": true, \
			"include_database": true, \
			"include_descriptions": true, \
			"exclude": "%airbyte%" \
		}'

.PHONY: dbt-gen-model-yaml
dbt-gen-model-yaml: ## Generate YAML for models. Usage: make dbt-gen-model-yaml model='["applications", "user_links"]'
	$(call log, Generating models for $(model)...)
	poetry run dbt run-operation generate_model_yaml $(target) --project-dir dbt/${PROJECT_NAME} --profiles-dir dbt/${PROJECT_NAME} --args \
		'{ \
			"model_names": $(model), \
			"upstream_descriptions": true, \
			"include_data_types": true \
		}'
