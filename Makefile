# -- Docker
# Get the current user ID to use for docker run and docker exec commands
COMPOSE                 = bin/compose
COMPOSE_RUN             = $(COMPOSE) run --rm
COMPOSE_TEST_RUN        = $(COMPOSE_RUN)
COMPOSE_TEST_RUN_APP    = $(COMPOSE_TEST_RUN) app
DOCKERIZE               = $(COMPOSE_RUN) dockerize

# -- LBT
LBT_IMAGE_NAME          ?= lbt
LBT_IMAGE_TAG           ?= development
LBT_IMAGE_BUILD_TARGET  ?= development

# Include environment variables from .env
include .env
export

# Include implemented LRS makefiles
include $(wildcard stores/*/Makefile)

default: help

.env:
	cp .env.dist .env

bootstrap: ## bootstrap the project
bootstrap: \
	.env \
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

run-locust: ## run locust
	@$(COMPOSE) up -d locust-master
.PHONY: run-locust

stop-locust: ## stop locust
	@$(COMPOSE) stop locust-master
	@$(COMPOSE) stop locust-worker
.PHONY: stop-locust

restart: ## restart locust containers
restart: \
	stop-locust \
	run-locust
.PHONY: restart

list-lrs: ## list all the LRS available
	@grep -hE 'run-lrs-[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sed "s/run-lrs-//" | sed "s/:.*//"
.PHONY: list-lrs

run: ## run all stacks for LRS chosen with `LRS=`
run: \
	run-locust \
	run-lrs-$(LRS)
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
