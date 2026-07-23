# Deploy a Cron Job to Backup PostgreSQL to Google Cloud Storage

This repo can be used to deploy a [Cron Job](https://render.com/docs/cronjobs) on [Render](https://render.com) to backup a PostgreSQL instance to Google Cloud Storage.

Fork this repo and click the button below to deploy.

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

See the guide for S3 at https://render.com/docs/backup-postgresql-to-s3 for more information.

## Excluding tables from the backup

Set the optional `EXCLUDE_TABLE_DATA` environment variable to a comma-separated list of tables whose **data** should be skipped. The table schema is still included in the dump, so a restore remains complete — only the rows are omitted. This is useful for skipping large, non-critical tables (caches, logs, etc.) to keep backups smaller and faster.

Entries are whitespace-trimmed and passed through to `pg_dump --exclude-table-data`, so they support wildcards and schema qualification:

```
EXCLUDE_TABLE_DATA=temp_*, public.audit_log, event_stream
```

An unqualified name (e.g. `event_stream`) matches that table in every schema; qualify it (e.g. `public.audit_log`) to limit it to one schema. A pattern that matches no table is silently ignored, so a mistyped name never fails the backup — it just backs up more than intended. Leave the variable unset or empty to back up everything.

