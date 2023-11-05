#!/usr/bin/env bash
# Copyright 2023 Dotanuki Labs
# SPDX-License-Identifier: MIT

# shellcheck disable=SC1091

set -eo pipefail

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/lib/preconditions.sh"

readonly target_folder="$1"
readonly docker_shmft="docker.io/mvdan/shfmt:latest"
readonly docker_shellcheck="docker.io/koalaman/shellcheck-alpine:stable"

echo
echo "🔥 Linting Bash scripts"
echo

require_docker

echo "→ Checking code formatting (shfmt)"
docker run --rm -v "$target_folder:/mnt" -w /mnt "$docker_shmft" --diff .

echo

echo "→ Checking code smells (shellcheck)"
docker run --rm -v "$target_folder:/mnt" "$docker_shellcheck" sh -c "find /mnt -name '*.sh' | xargs shellcheck"

echo
echo "✅ All good!"
echo
