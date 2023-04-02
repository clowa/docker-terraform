[![Get latest release version](https://github.com/clowa/docker-terraform/actions/workflows/get-latest-release.yml/badge.svg)](https://github.com/clowa/docker-terraform/actions/workflows/get-latest-release.yml)
[![Build docker images](https://github.com/clowa/docker-terraform/actions/workflows/docker-buildx.yml/badge.svg)](https://github.com/clowa/docker-terraform/actions/workflows/docker-buildx.yml)
[![Check base image update](https://github.com/clowa/docker-terraform/actions/workflows/check-base-image-update.yml/badge.svg)](https://github.com/clowa/docker-terraform/actions/workflows/check-base-image-update.yml)

# Overview

Docker image with corresponding terraform version.

Supported platforms:

- `linux/386`
- `linux/amd64`
- `linux/arm/v6`
- `linux/arm/v7`
- `linux/arm64/v8`

# CI setups

1. Checks every day at `12:00 am / midnight UTC` if a new release is available at the [terraform repository](https://github.com/hashicorp/terraform)
2. Build new docker images with the new release.
