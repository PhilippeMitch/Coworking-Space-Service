FROM python:3.10-slim-buster

RUN apt update -y && apt install postgresql postgresql-contrib -y

WORKDIR /db
COPY ./db .

WORKDIR /analytics

COPY ./analytics/requirements.txt requirements.txt

# Dependencies are installed during build time in the container itself so we don't have OS mismatch
RUN pip install -r requirements.txt

COPY ./analytics .

# Start the database and Flask application
CMD service postgresql start && python app.py
