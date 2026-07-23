#!/bin/bash

set -eo pipefail

setup_gcp() {
  echo "$GCP_CREDENTIALS" > /credentials.json
  gcloud auth activate-service-account --key-file="/credentials.json"
}

pg_dump_database() {
  local -a exclude_args=()

  # EXCLUDE_TABLE_DATA is an optional, comma-separated list of tables whose *data*
  # should be skipped (the schema is still dumped, so restores stay complete).
  # Entries are trimmed and may use pg_dump patterns (e.g. "temp_*, public.audit_log").
  if [[ -n "${EXCLUDE_TABLE_DATA:-}" ]]; then
    local _t
    IFS=',' read -ra _tables <<< "$EXCLUDE_TABLE_DATA"
    for _t in "${_tables[@]}"; do
      # Trim leading/trailing whitespace so "a, b , c" parses cleanly.
      _t="${_t#"${_t%%[![:space:]]*}"}"
      _t="${_t%"${_t##*[![:space:]]}"}"
      [[ -z "$_t" ]] && continue
      exclude_args+=(--exclude-table-data="$_t")
    done
  fi

  # Log to stderr: stdout is piped into gzip, so anything here would corrupt the backup.
  if [[ ${#exclude_args[@]} -gt 0 ]]; then
    echo "Excluding data from tables matching: ${exclude_args[*]#--exclude-table-data=}" >&2
  fi

  pg_dump -v --no-owner --no-privileges --clean --if-exists --quote-all-identifiers "${exclude_args[@]}" "$DATABASE_URL"
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
