
run-lrs-learninglocker: ## run learning-locker stack
	$(COMPOSE) up -d learninglocker-mongo learninglocker-redis
	$(DOCKERIZE) \
		-wait tcp://learninglocker-mongo:27017 \
		-wait tcp://learninglocker-redis:6379 \
		-timeout 60s
	$(COMPOSE) up -d learninglocker
	$(DOCKERIZE) \
		-wait tcp://learninglocker:8090 \
		-timeout 60s
.PHONY: run-lrs-learninglocker