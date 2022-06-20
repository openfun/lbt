# -- Docker
# Get the current user ID to use for docker run and docker exec commands
COMPOSE              = bin/compose
COMPOSE_RUN          = $(COMPOSE) run --rm

default: help

down: ## stop and remove backend containers
	@$(COMPOSE) down
.PHONY: down

logs: ## display locust master logs (follow mode)
	@$(COMPOSE) logs -f locust-master
.PHONY: logs

run: ## run locust
	@$(COMPOSE) up
.PHONY: run

status: ## an alias for "docker-compose ps"
	@$(COMPOSE) ps
.PHONY: status

# -- Misc
help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
