
run-lrs-ralph: ## run ralph stack
	$(COMPOSE) up -d ralph-es
	$(DOCKERIZE) \
		-wait tcp://ralph-es:9200 \
		-timeout 60s
	$(COMPOSE) up -d ralph-proxy
	$(DOCKERIZE) -wait tcp://ralph-proxy:8090 -timeout 60s
.PHONY: run-lrs-ralph