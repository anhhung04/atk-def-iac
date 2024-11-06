FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y sqlite3

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src /app

EXPOSE 5000

RUN sqlite3 database.db < db.sql

CMD ["python", "app.py"]
