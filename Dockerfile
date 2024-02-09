FROM python:3.10-slim-buster

# Install Postgres and configure a username + password
USER root

ARG DB_USERNAME=$DB_USERNAME
ARG DB_PASSWORD=$DB_PASSWORD

RUN apt update -y && apt install postgresql postgresql-contrib -y

USER postgres
WORKDIR /db
COPY ./db .

RUN service postgresql start && \
psql -c "CREATE USER $DB_USERNAME PASSWORD '$DB_PASSWORD'" && \
psql < 1_create_tables.sql && \
psql < 2_seed_users.sql && \
psql < 3_seed_tokens.sql && \
psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USERNAME;" && \
psql -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USERNAME"

# -- End database setup

USER root

WORKDIR /src

COPY ./analytics/requirements.txt requirements.txt

# Dependencies are installed during build time in the container itself so we don't have OS mismatch
RUN pip install -r requirements.txt

COPY ./analytics .

# Start the database and Flask application
CMD service postgresql start && python app.py
