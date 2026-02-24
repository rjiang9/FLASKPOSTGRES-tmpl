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
