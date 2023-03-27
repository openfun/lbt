# Endpoint prefix for ralph
ifeq ($(LRS),xapi)
	ENDPOINT_PREFIX = xapi
endif

RALPH_DB ?= es

ES_INDEX = statements
ES_URL   = http://localhost:9200

run-es: ## run elasticsearch database
	$(COMPOSE) up -d ralph-es
	$(DOCKERIZE) \
		-wait tcp://ralph-es:9200 \
		-timeout 60s
	@echo "Creating $(ES_INDEX) index..."
	curl -X PUT $(ES_URL)/$(ES_INDEX)
	@echo -e "\nConfiguring $(ES_INDEX) index..."
	curl -X PUT $(ES_URL)/$(ES_INDEX)/_settings -H 'Content-Type: application/json' -d '{"index": {"number_of_replicas": 0}}'
.PHONY: run-es 

run-async_es: ## run elasticsearch database for async backend
run-async_es: \
	run-es
.PHONY: run-async_es

run-mongo: ## run mongo database
	$(COMPOSE) up -d ralph-mongo
	$(DOCKERIZE) \
		-wait tcp://ralph-mongo:27017 \
		-timeout 60s
.PHONY: run-mongo

run-clickhouse: ## run clickhouse database
	$(COMPOSE) up -d ralph-clickhouse
	$(DOCKERIZE) \
		-wait tcp://ralph-clickhouse:9000 \
		-timeout 60s
.PHONY: run-clickhouse

run-lrs-ralph: ## run ralph stack
	@make run-$(RALPH_DB)
	$(COMPOSE) up -d ralph
	$(DOCKERIZE) \
		-wait http://ralph:8090/__heartbeat__ \
		-timeout 60s
.PHONY: run-lrs-ralph
