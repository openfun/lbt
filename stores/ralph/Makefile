ES_INDEX = statements
ES_URL   = http://localhost:9200

es-index: ## create elasticsearch index
	@echo "Creating $(ES_INDEX) index..."
	curl -X PUT $(ES_URL)/$(ES_INDEX)
	@echo -e "\nConfiguring $(ES_INDEX) index..."
	curl -X PUT $(ES_URL)/$(ES_INDEX)/_settings -H 'Content-Type: application/json' -d '{"index": {"number_of_replicas": 0}}'
.PHONY: es-index

run-lrs-ralph: ## run ralph stack
	$(COMPOSE) up -d ralph-es
	$(DOCKERIZE) \
		-wait tcp://ralph-es:9200 \
		-timeout 60s
	make es-index
	$(COMPOSE) up -d ralph --build --force-recreate
	$(DOCKERIZE) \
		-wait tcp://ralph:8090 \
		-timeout 60s
.PHONY: run-lrs-ralph
