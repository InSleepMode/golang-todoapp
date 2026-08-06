include .env
export

export PROJECT_ROOT=$(CURDIR)

env-up:
	docker compose up -d todoapp-postgres

env-down:
	docker compose down todoapp-postgres

env-cleanup:
	@read -p "Очистить все volume файлы окружения? Опасность утери данных. [y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down todoapp-postgres port-forwarder && \
		rm -rf $(CURDIR)/out/pgdata && \
		echo "Файлы окружения очищены"; \
	else \
		echo "Очистка окружения отменена"; \
	fi


env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Отсутствует параметр 'seq'. Пример: make migrate-create seq=init"; \
	else \
		docker compose run --rm todoapp-postgres-migrate \
			create \
			-ext sql \
			-dir /migrations \
			-seq "$(seq)"; \
	fi

migrate-up:
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		up

migrate-down:
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		down

migrate-force:
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		force $(version)

logs-cleanup:
	@read -p "Очистить все log файлы? Опасность утери logs. [y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down todoapp-postgres port-forwarder && \
		rm -rf $(CURDIR)/out/logs && \
		echo "Файлы logs очищены"; \
	else \
		echo "Очистка logs отменена"; \
	fi


todoapp-run:
	@export LOGGER_FOLDER=$(CURDIR)/out/logs && \
	export POSTGRES_HOST=localhost && \
	go mod tidy && \
	go run $(CURDIR)/cmd/todoapp/main.go

todoapp-deploy:
	@docker compose up -d --build todoapp

todoapp-undeploy:
	@docker compose down todoapp


ps:
	@docker compose ps