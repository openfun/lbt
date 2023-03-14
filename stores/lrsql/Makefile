
run-lrs-lrsql: ## run lrsql stack
	$(COMPOSE) up -d lrsql-postgres
	$(DOCKERIZE) \
		-wait tcp://lrsql-postgres:5432 \
		-timeout 60s
	$(COMPOSE) up -d lrsql
	$(DOCKERIZE) \
		-wait tcp://lrsql:8090 \
		-timeout 60s
.PHONY: run-lrs-lrsql
