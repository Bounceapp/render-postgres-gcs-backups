FROM google/cloud-sdk:580.0.0-slim
ARG POSTGRES_VERSION

RUN test -n "$POSTGRES_VERSION" || (echo "POSTGRES_VERSION must be set" && false)

RUN install -d /usr/share/postgresql-common/pgdg \
    && curl --fail --silent -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    && . /etc/os-release \
    && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gzip postgresql-client-$POSTGRES_VERSION \
    && rm -rf /var/lib/apt/lists/*

COPY backup.sh /scripts/backup.sh
ENTRYPOINT [ "/scripts/backup.sh" ]
