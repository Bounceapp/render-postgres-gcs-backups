# Deploy a Cron Job to Backup PostgreSQL to Google Cloud Storage

This repo can be used to deploy a [Cron Job](https://render.com/docs/cronjobs) on [Render](https://render.com) to backup a PostgreSQL instance to Google Cloud Storage.

Fork this repo and click the button below to deploy.

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

See the guide for S3 at https://render.com/docs/backup-postgresql-to-s3 for more information.

## Excluding tables from the backup

Set the optional `EXCLUDE_TABLE_DATA` environment variable to a comma-separated list of tables whose **data** to skip. The schema is still dumped — only the rows are dropped — so you can shrink backups by leaving out large, non-critical tables (caches, logs, etc.). Leave it unset to back up everything.

Values are passed to `pg_dump --exclude-table-data`, so wildcards and schema qualification work:

```
EXCLUDE_TABLE_DATA=temp_*, public.audit_log, event_stream
```

An unqualified name matches that table in every schema; qualify it (`public.audit_log`) to pin one schema.

### Known limitations

- **Typos pass silently.** A pattern that matches no table is ignored, so a misspelled name just backs up that table's data as usual. Check names against the live schema.
- **Can break restores via foreign keys.** If a kept table references an excluded one, its rows lose their targets and the foreign key may fail to restore. Only exclude tables nothing else references.
- **Doesn't cover partitions.** Excluding a partitioned table doesn't exclude its child partitions. List the children explicitly (or use a wildcard).

