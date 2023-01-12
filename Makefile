# -- Docker
# Get the current user ID to use for docker run and docker exec commands
COMPOSE              = bin/compose
COMPOSE_RUN          = $(COMPOSE) run --rm
DOCKERIZE            = $(COMPOSE_RUN) dockerize

default: help

bootstrap: ## bootsrap the project
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

run-learninglocker: ## run learning-locker stack
	@$(COMPOSE) up -d learninglocker-mongo learninglocker-redis
	@$(DOCKERIZE) \
		-wait tcp://learninglocker-mongo:27017 \
		-wait tcp://learninglocker-redis:6379 \
		-timeout 60s
	@$(COMPOSE) up -d learninglocker-proxy
	@$(DOCKERIZE) -wait tcp://learninglocker-proxy:8090 -timeout 60s
.PHONY: run-learninglocker

run-locust: ## run locust
	@$(COMPOSE) up -d locust-master
.PHONY: run-locust

run: ## run all stacks
run: \
	run-locust \
	run-learninglocker
.PHONY: run

status: ## an alias for "docker-compose ps"
	@$(COMPOSE) ps
.PHONY: status

stop: ## an alias for "docker-compose stop"
	@$(COMPOSE) stop
.PHONY: stop

# -- Misc
help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
