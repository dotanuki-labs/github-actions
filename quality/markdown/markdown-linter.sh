#!/usr/bin/env bash
# Copyright 2024 Dotanuki Labs
# SPDX-License-Identifier: MIT

# shellcheck disable=SC1091

set -eo pipefail

readonly folder="$1"

# https://github.com/igorshubovych/markdownlint-cli/pkgs/container/markdownlint-cli
readonly markdownlint="ghcr.io/igorshubovych/markdownlint-cli:v0.44.0"

# https://hub.docker.com/r/lycheeverse/lychee/tags
readonly lychee="lycheeverse/lychee:0.15.1"

require_docker_daemon() {
    if (! docker stats --no-stream >/dev/null); then
        echo "Docker is required for this execution"
        echo
        exit 1
    fi
}

require_docker_image() {
    local image_spec="$1"
    echo "Pulling Docker image : $image_spec"
    docker pull "$image_spec" >/dev/null 2>&1
}

lint_markdown() {
    echo
    echo "→ Linting markdown files (markdownlint)"
    docker run --rm -v "$folder:/workdir" "$markdownlint" "**/*.md"
}

check_broken_links() {
    echo
    echo "→ Checking broken links (lychee)"
    docker run --rm -w /input -v "$folder:/input" "$lychee" "**/*.md" --exclude "github\.com"
}

echo
echo "🔥 Linting Markdown files"
echo

require_docker_daemon
require_docker_image "$markdownlint"
lint_markdown

require_docker_image "$lychee"
check_broken_links

echo
echo "✅ All good!"
echo
