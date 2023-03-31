# -- Docker
# Get the current user ID to use for docker run and docker exec commands
COMPOSE                 = bin/compose
COMPOSE_RUN             = $(COMPOSE) run --rm
COMPOSE_TEST_RUN        = $(COMPOSE_RUN)
COMPOSE_TEST_RUN_APP    = $(COMPOSE_TEST_RUN) app
DOCKERIZE               = $(COMPOSE_RUN) dockerize

default: help

# Include implemented LRS makefiles
include $(wildcard stores/*/Makefile)


bootstrap: ## bootstrap the project
bootstrap: \
	dataspec \
	dataset
.PHONY: bootstrap

dataspec: ## generate the dataspec
	@echo "Generating data specification for $(STUDENTS_NUMBER) students..."
	@bin/gen_data_spec
.PHONY: dataspec

dataset: ## generate the dataset
	@rm -f data/set/*.json

	@$(COMPOSE_RUN) datasim \
		-p /data/inputs/dataset.profiles.json \
		-a /data/inputs/dataset.personae.json \
		-l /data/inputs/dataset.alignments.json \
		-o /data/inputs/dataset.parameters.json \
		validate-input /data/spec/dataset.spec.json

	@echo "Generating dataset..."
	@$(COMPOSE_RUN) datasim \
		-i /data/spec/dataset.spec.json generate | \
		split -l $(STATEMENTS_PER_REQ) -d --suffix-length=4 --additional-suffix=.json - ./data/set/dataset-

	@echo "Dataset of $(STATEMENT_NUMBER) statements successfully generated!"
.PHONY: dataset

down: ## stop and remove backend containers
	@$(COMPOSE) down
.PHONY: down

logs: ## display locust logs (follow mode)
	@$(COMPOSE) logs -f locust
.PHONY: logs

logs-notebook: ## display app logs (follow mode)
	@$(COMPOSE) logs -f notebooks-notebook
.PHONY: logs

run-locust: ## run locust
	@$(COMPOSE) up -d locust
.PHONY: run-locust

list-lrs: ## list the LRS available
	@grep -hE 'run-lrs-[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sed "s/run-lrs-//" | sed "s/:.*//"
.PHONY: list-lrs

run-notebook: ## run notebook server
	@$(COMPOSE) up -d --no-deps --build notebooks-notebook
.PHONY: run-notebook

run: ## run all stacks for LRS chosen with `LRS=`
run: \
	run-lrs-$(LRS) \
	run-locust
.PHONY: run

status: ## an alias for "docker-compose ps"
	@$(COMPOSE) ps
.PHONY: status

stop: ## an alias for "docker-compose stop"
	@$(COMPOSE) stop
.PHONY: stop

# -- Misc
help:
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
