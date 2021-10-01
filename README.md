[![Build Status](https://drone.k8s.clowa.de/api/badges/clowa/docker-terraform/status.svg)](https://ci.k8s.clowa.de/clowa/docker-terraform)

# Overview

Docker image with corresponding terraform version.

Supported platforms:

- linux/386
- linux/amd64
- linux/arm/v6
- linux/arm/v7
- linux/arm64/v8

# CI setups for Drone

Fire this command to setup the cron schedule.

```bash
drone cron add "clowa/docker-terraform" "nightly" "0 0 1 * * *"
```
