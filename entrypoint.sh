#!/usr/bin/env bash
set -u

child_pid=""
max_retries=5
retry_count=0
backoff_seconds=10

stop_gateway() {
  if [ -n "$child_pid" ]; then
    kill -TERM "$child_pid" 2>/dev/null || true
    wait "$child_pid" 2>/dev/null || true
  fi
  exit 143
}

trap stop_gateway INT TERM

while true; do
  hermes --yolo gateway run &
  child_pid="$!"

  wait "$child_pid"
  exit_code="$?"
  child_pid=""

  if [ "$exit_code" -eq 0 ]; then
    echo "hermes gateway exited normally."
    exit 0
  fi

  if [ "$retry_count" -ge "$max_retries" ]; then
    echo "hermes gateway exited with code ${exit_code}; retry limit reached (${max_retries})."
    exit "$exit_code"
  fi

  retry_count=$((retry_count + 1))
  echo "hermes gateway exited with code ${exit_code}; restarting in ${backoff_seconds} seconds (${retry_count}/${max_retries})..."
  sleep "$backoff_seconds"
  backoff_seconds=$((backoff_seconds * 2))
done
