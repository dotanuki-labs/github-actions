#!/usr/bin/env bash
# Copyright 2023 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -eo pipefail

readonly target_folder="$1"

# https://github.com/igorshubovych/markdownlint-cli
readonly markdownlint="ghcr.io/igorshubovych/markdownlint-cli:latest"

# https://github.com/lycheeverse/lychee
readonly lychee="lycheeverse/lychee:latest"

require_docker() {
    if (! docker stats --no-stream >/dev/null); then
        echo "Docker is required for this check"
        echo
        exit 1
    fi
}

lint_markdown() {
    echo
    echo "→ Linting markdown files (markdownlint)"
    docker run --rm -v "$target_folder:/workdir" "$markdownlint" "**/*.md"
}

check_broken_links() {
    echo
    echo "→ Checking broken links (lychee)"
    docker run --rm -w /input -v "$target_folder:/input" "$lychee" "**/*.md"
}

echo
echo "🔥 Linting documentation and prose"
echo

require_docker
lint_markdown
check_broken_links

echo
echo "✅ All good!"
echo