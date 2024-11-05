FROM python:3.8-slim
WORKDIR /app

RUN pip install gunicorn flask libnum

COPY ecc.py .
COPY app.py .
COPY /templates ./templates

EXPOSE 10000
CMD gunicorn --bind 0.0.0.0:10000 app:app --reload