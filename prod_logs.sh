#!/bin/bash
set -euo pipefail

# Use first argument as ENV or default to "prod"
ENV="${1:-prod}"
BUCKET_NAME="techeazy-logs-debasish-87"

LOG_FILES=(
  "/home/ubuntu/techeazy-devops/app.log"
  "/var/log/cloud-init.log"
  "/var/log/cloud-init-output.log"
  "/var/log/syslog"
)

S3_LOGS_PATH="s3://${BUCKET_NAME}/logs/${ENV}/"
S3_STATUS_PATH="s3://${BUCKET_NAME}/status/${ENV}/"

for LOG_FILE in "${LOG_FILES[@]}"; do
  if [[ -f "$LOG_FILE" ]]; then
    BASENAME=$(basename "$LOG_FILE")
    echo "Uploading $LOG_FILE to ${S3_LOGS_PATH}${BASENAME}"
    aws s3 cp "$LOG_FILE" "${S3_LOGS_PATH}${BASENAME}"
  else
    echo "  $LOG_FILE not found, skipping."
  fi
done

echo "Logs uploaded at $(date)" > /tmp/status.txt
aws s3 cp /tmp/status.txt "${S3_STATUS_PATH}status.txt"

echo " All available logs uploaded successfully."
