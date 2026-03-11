# Docker Restart Monitor (Prometheus Metric)

## Overview

This repository contains a simple Bash script that monitors the restart count of a Docker container.
If the container restarts, the script logs the event and writes a Prometheus-ready metric file that can be collected by the Node Exporter textfile collector.

---

## Features

* Checks Docker container restart count
* Logs restart events
* Exposes metrics in Prometheus format
* Can be run with cron for regular monitoring

---

## Metric Example

The script creates a metric file like this:

```
# HELP docker_container_restart_count Total restart count for a Docker container
# TYPE docker_container_restart_count counter
docker_container_restart_count{container="nginx",image="nginx:latest",host="server01"} 3
```

---

## Installation

1. Copy the script

```
sudo cp docker_restart_monitor.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/docker_restart_monitor.sh
```

2. Create the Node Exporter textfile directory

```
sudo mkdir -p /var/lib/node_exporter/textfile_collector
```

3. Make sure Node Exporter is running with:

```
--collector.textfile.directory=/var/lib/node_exporter/textfile_collector
```

---

## Run with Cron

Create a cron file:

`/etc/cron.d/docker_restart_monitor`

```
*/5 * * * * root /usr/local/bin/docker_restart_monitor.sh
```

This runs the script every **5 minutes**.

---

## Log File

Restart events are written to:

```
/var/log/docker_restart_monitor.log
```

Example:

```
2026-03-11 14:10:01 - Container nginx restarted. Count increased from 2 to 3
```

---
