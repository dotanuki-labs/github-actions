#!/usr/bin/env bash
# Copyright 2023 Dotanuki Labs
# SPDX-License-Identifier: MIT

# shellcheck disable=SC1091

set -eo pipefail

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/lib/preconditions.sh"

readonly target_folder="$1"

# https://github.com/igorshubovych/markdownlint-cli
readonly markdownlint="ghcr.io/igorshubovych/markdownlint-cli:latest"

# https://github.com/lycheeverse/lychee
readonly lychee="lycheeverse/lychee:latest"

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

require_docker_daemon
require_docker_image "$markdownlint"
require_docker_image "$lychee"

lint_markdown
check_broken_links

echo
echo "✅ All good!"
echo
