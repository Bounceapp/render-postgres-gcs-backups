#!/bin/bash

set -eo pipefail

setup_gcp() {
  echo "$GCP_CREDENTIALS" > /credentials.json
  gcloud auth activate-service-account --key-file="/credentials.json"
}

pg_dump_database() {
  # EXCLUDE_TABLE_DATA: optional comma-separated tables whose data to skip (schema
  # is still dumped). Supports pg_dump patterns, e.g. "temp_*, public.audit_log".
  local -a exclude_args=()
  local table
  IFS=',' read -ra tables <<< "${EXCLUDE_TABLE_DATA:-}"
  for table in "${tables[@]}"; do
    read -r table <<< "$table" # trim surrounding whitespace
    [[ -n "$table" ]] && exclude_args+=(--exclude-table-data="$table")
  done

  # Log to stderr; stdout is the dump being piped into gzip.
  [[ -n "${EXCLUDE_TABLE_DATA:-}" ]] && echo "Excluding table data: $EXCLUDE_TABLE_DATA" >&2

  pg_dump -v --no-owner --no-privileges --clean --if-exists --quote-all-identifiers \
    "${exclude_args[@]}" "$DATABASE_URL"
}

upload_to_bucket() {
  gsutil cp - "gs://$BUCKET_NAME/$BUCKET_PREFIX/$(date +%Y/%m/%d/backup-%H-%M-%S.sql.gz)"
}

main() {
  setup_gcp
  echo "Taking backup and uploading it to S3..."
  pg_dump_database | gzip | upload_to_bucket
  echo "Done."
}

main
