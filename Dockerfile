FROM google/cloud-sdk:436.0.0-slim
ARG POSTGRES_VERSION

RUN test -n "$POSTGRES_VERSION" || (echo "POSTGRES_VERSION must be set" && false)

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
    && curl --silent -o - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt update \
    && apt install gzip postgresql-$POSTGRES_VERSION -y \
    && rm -rf /var/lib/apt/lists/*

COPY backup.sh /scripts/backup.sh
ENTRYPOINT [ "/scripts/backup.sh" ]
