#!/usr/bin/env bash
# Copyright 2023 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -eo pipefail

require_docker_daemon() {
    if (! docker stats --no-stream >/dev/null); then
        echo "Docker is required for this Github Action"
        echo
        exit 1
    fi
}

require_docker_image() {
    local image_spec="$1"
    echo "Pulling Docker image : $image_spec"
    docker pull "$image_spec" >/dev/null 2>&1
}
