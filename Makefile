# -- Docker
# Get the current user ID to use for docker run and docker exec commands
COMPOSE                 = bin/compose
COMPOSE_RUN             = $(COMPOSE) run --rm
COMPOSE_TEST_RUN        = $(COMPOSE_RUN)
COMPOSE_TEST_RUN_APP    = $(COMPOSE_TEST_RUN) app
DOCKERIZE               = $(COMPOSE_RUN) dockerize

# -- LRS to be tested
LRS             ?= ralph
LRS_PORT        ?= 8090

# Different LRS have different prefix endpoint
ifeq ($(LRS),learninglocker)
    ENDPOINT_PREFIX = data/xAPI
else ifeq ($(LRS),ralph)
	ENDPOINT_PREFIX = xAPI
else ifeq ($(LRS),lrsql)
	ENDPOINT_PREFIX = xapi
endif

# -- Locust configuration

# Scenario to be run
SCENARIO          ?= post
# Number of the iteration
ITERATION          ?= 01
# Number of locust users
USERS_NUMBER       ?= 1
# Number of users to be spawned by seconds
SPAWN_RATE         ?= 1
# Number of locust workers to be run
WORKERS_NUMBER     ?= 1
# Duration of the run (in seconds)
RUN_TIME           ?= 900
# Time to stop its tasks at the end of the run 
STOP_TIMEOUT       ?= 0
# Number of students emitting statements
STUDENTS_NUMBER    ?= 200
# Seed for generating random students
STUDENT_SEED       ?= 742
# Number of statements sent per request
STATEMENTS_PER_REQ ?= 2200
# Total number of statements to be sent in a run
STATEMENT_NUMBER = $(shell echo $$(($(STATEMENTS_PER_REQ) * 1000)))
# Prefix for locust result files
RESULT_PREFIX ?= run

# -- Credentials
LRS_LOGIN    = AAA
LRS_PASSWORD = BBB

# Export variables to environment 
export

# Include implemented LRS makefiles
include $(wildcard stores/*/Makefile)

default: help

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
	@$(COMPOSE) up -d locust-master
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