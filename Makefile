# -- Docker
# Get the current user ID to use for docker run and docker exec commands
COMPOSE                 = bin/compose
COMPOSE_RUN             = $(COMPOSE) run --rm
COMPOSE_TEST_RUN        = $(COMPOSE_RUN)
COMPOSE_TEST_RUN_APP    = $(COMPOSE_TEST_RUN) app
DOCKERIZE               = $(COMPOSE_RUN) dockerize

# -- LRS
LRS             ?= ralph
LRS_PORT        ?= 8090

ifeq ($(LRS),learninglocker)
    ENDPOINT_PREFIX = data/xAPI
else ifeq ($(LRS),ralph)
	ENDPOINT_PREFIX = xAPI
else ifeq ($(LRS),lrsql)
	ENDPOINT_PREFIX = xapi
endif

# -- Locust configuration
USERS_NUMBER   ?= 1
SPAWN_RATE     ?= 100
WORKERS_NUMBER ?= 1
RUN_TIME       ?= 4m
STOP_TIMEOUT   ?= 0

# -- Credentials
LRS_LOGIN    ?= AAA
LRS_PASSWORD ?= BBB

# Export variables to environment 
export

# Include implemented LRS makefiles
include $(wildcard stores/*/Makefile)

default: help

bootstrap: ## bootstrap the project
bootstrap: \
	data/dataset.json
.PHONY: bootstrap

data/dataset.json:
	$(COMPOSE_RUN) datasim -i /data/dataset.spec.json generate > ./data/dataset.json
	split -d --additional-suffix=.json ./data/dataset.json ./data/dataset-

down: ## stop and remove backend containers
	@$(COMPOSE) down
.PHONY: down

logs: ## display locust master logs (follow mode)
	@$(COMPOSE) logs -f locust-master
.PHONY: logs

logs-notebook: ## display app logs (follow mode)
	@$(COMPOSE) logs -f notebook
.PHONY: logs

run-locust: ## run locust
	@$(COMPOSE) up -d locust-master
.PHONY: run-locust

list-lrs: ## list the LRS available
	@grep -hE 'run-lrs-[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sed "s/run-lrs-//" | sed "s/:.*//"
.PHONY: list-lrs

run-notebook: ## run notebook server
	@$(COMPOSE) up -d notebook
.PHONY: run-notebook

run: ## run all stacks for LRS chosen with `LRS=`
run: \
	run-lrs-$(LRS) \
	run-locust 
# 
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