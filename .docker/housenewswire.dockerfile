FROM debian:stable

RUN apt-get update; \
    apt-get install -y cpanminus libpq-dev libssl-dev libz-dev build-essential; \
    cpanm App::plx;

RUN useradd -d /app catalyst;

USER catalyst
COPY --chown=catalyst:catalyst Web /app/

WORKDIR /app

CMD plx starman
