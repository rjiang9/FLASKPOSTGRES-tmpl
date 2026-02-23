#!/bin/bash
# setup_project.sh
# Usage: ./setup_project.sh <project_name>
# This script creates a full Flask + Postgres project structure for dev and production

# Check for argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

BASE_NAME=$1
PROJECT_NAME=$BASE_NAME
COUNTER=1

# Check for duplicate folder names
while [ -d "$PROJECT_NAME" ]; do
    PROJECT_NAME="${BASE_NAME}${COUNTER}"
    COUNTER=$((COUNTER + 1))
done

echo "Creating project folder: $PROJECT_NAME"

# Create project directories
mkdir -p "$PROJECT_NAME/app"
cd "$PROJECT_NAME" || exit

echo "Creating Dockerfile..."
cat > Dockerfile << 'EOF'
# Dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=app.py

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install gunicorn

EXPOSE 5000

CMD if [ "$FLASK_ENV" = "production" ]; then \
        gunicorn app:app --bind 0.0.0.0:5000; \
    else \
        flask run --host=0.0.0.0 --port=5000; \
    fi
EOF

echo "Creating docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
services:
  web:
    build: .
    ports:
      - "5000:5000"
    env_file:
      - .env.prod
EOF

echo "Creating docker-compose.override.yml..."
cat > docker-compose.override.yml << 'EOF'
services:
  web:
    environment:
      DATABASE_URL=postgresql://postgres:postgres@postgresdb:5432/postgres
      FLASK_ENV=development
    volumes:
      - ./app:/app
    depends_on:
      - postgresdb

  postgresdb:
    image: postgres:16
    ports:
      - "5433:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: postgres
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
EOF

echo "Creating .env..."
cat > .env << 'EOF'
FLASK_APP=app.py
FLASK_ENV=development
DATABASE_URL=postgresql://postgres:postgres@postgresdb:5432/postgres
EOF

echo "Creating .env.prod..."
cat > .env.prod << 'EOF'
FLASK_APP=app.py
FLASK_ENV=production
DATABASE_URL=postgresql://postgres:password@<managed-db-host>:5432/postgres
EOF

echo "Creating .dockerignore..."
cat > .dockerignore << 'EOF'
__pycache__/
*.pyc
.env
.env.prod
venv/
.git/
EOF

echo "Creating Makefile..."
cat > Makefile << 'EOF'
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
EOF

echo "Creating minimal Flask app..."
cat > app/app.py << 'EOF'
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return "Hello, Flask + Postgres!"
EOF

echo "Creating app requirements.txt..."
cat > app/requirements.txt << 'EOF'
flask
psycopg2-binary
EOF

echo "Project structure created successfully in $(pwd)"
