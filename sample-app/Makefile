.DEFAULT_GOAL := help

ENV_DEV=.env
ENV_PROD=.env.prod

help:
	@echo "Usage:"
	@echo "  make dev    - Run local development stack with Postgres container and hot-reload"
	@echo "  make prod   - Run production stack with managed Postgres"

dev:
	docker compose --env-file $(ENV_DEV) up --build

prod:
	docker compose -f docker-compose.yml --env-file $(ENV_PROD) up --build

down:
	docker compose down

logs:
	docker compose logs -f
