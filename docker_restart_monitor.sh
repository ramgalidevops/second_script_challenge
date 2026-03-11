#!/bin/bash

CONTAINER_NAME="nginx"   # change this to the container you want to monitor
STATE_FILE="/var/tmp/docker_restart_${CONTAINER_NAME}.state"
LOG_FILE="/var/log/docker_restart_monitor.log"
METRIC_DIR="/var/lib/node_exporter/textfile_collector"
METRIC_FILE="${METRIC_DIR}/docker_restart.prom"

DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Ensure metric directory exists
mkdir -p "$METRIC_DIR"

# Get container restart count
RESTART_COUNT=$(docker inspect -f '{{.RestartCount}}' "$CONTAINER_NAME" 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "$DATE - ERROR: Unable to inspect container $CONTAINER_NAME" >> "$LOG_FILE"
    exit 1
fi

# Load previous restart count
if [ -f "$STATE_FILE" ]; then
    PREVIOUS_COUNT=$(cat "$STATE_FILE")
else
    PREVIOUS_COUNT=0
fi

# Detect restart increase
if [ "$RESTART_COUNT" -gt "$PREVIOUS_COUNT" ]; then
    echo "$DATE - Container $CONTAINER_NAME restarted. Count increased from $PREVIOUS_COUNT to $RESTART_COUNT" >> "$LOG_FILE"
fi

# Save new restart count
echo "$RESTART_COUNT" > "$STATE_FILE"

# Get additional labels
CONTAINER_ID=$(docker inspect -f '{{.Id}}' "$CONTAINER_NAME" | cut -c1-12)
IMAGE=$(docker inspect -f '{{.Config.Image}}' "$CONTAINER_NAME")
HOSTNAME=$(hostname)

# Write Prometheus metric
cat <<EOF > "$METRIC_FILE"
# HELP docker_container_restart_count Total restart count for a Docker container
# TYPE docker_container_restart_count counter
docker_container_restart_count{container="$CONTAINER_NAME",container_id="$CONTAINER_ID",image="$IMAGE",host="$HOSTNAME"} $RESTART_COUNT
EOF
