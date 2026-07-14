include .env
export

export PROJECT_ROOT=$(CURDIR)

env-up:
	docker compose up -d todoapp-postgres

env-down:
	docker compose down todoapp-postgres

env-cleanup:
	@echo "Stopping container..."
	docker compose down todoapp-postgres
	@echo "Deleting pgdata..."
	rmdir /s /q out\pgdata
	@echo "Cleanup done!"

migrate-create:
	@if "$(seq)"=="" ( \
		echo "Отсутствует параметр 'seq'. Пример: make migrate-create seq=init" \
	) else ( \
		docker compose run --rm todoapp-postgres-migrate \
			create \
			-ext sql \
			-dir /migrations \
			-seq "$(seq)" \
	)



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

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compose down port-forwarder