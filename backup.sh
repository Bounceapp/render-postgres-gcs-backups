#!/bin/bash

set -eo pipefail

setup_gcp() {
  echo "$GCP_CREDENTIALS" > /credentials.json
  gcloud auth activate-service-account --key-file="/credentials.json"
}

pg_dump_database() {
  pg_dump -v --no-owner --no-privileges --clean --if-exists --quote-all-identifiers "$DATABASE_URL"
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
