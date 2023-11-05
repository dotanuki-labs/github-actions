#!/usr/bin/env bash
# Copyright 2023 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -eo pipefail

require_docker() {
    if (! docker stats --no-stream >/dev/null); then
        echo "Docker is required for this Github Action"
        echo
        exit 1
    fi
}
