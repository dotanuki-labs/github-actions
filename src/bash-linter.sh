#!/usr/bin/env bash
# Copyright 2023 Dotanuki Labs
# SPDX-License-Identifier: MIT

# shellcheck disable=SC1091

set -eo pipefail

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/lib/preconditions.sh"

# https://github.com/mvdan/sh
readonly shmft="docker.io/mvdan/shfmt:latest"

#https://github.com/koalaman/shellcheck
readonly shellcheck="docker.io/koalaman/shellcheck-alpine:stable"

readonly target_folder="$1"

check_code_style() {
    echo "→ Checking code formatting (shfmt)"
    docker run --rm -v "$target_folder:/mnt" -w /mnt "$shmft" --diff .
}

check_code_smells() {
    echo "→ Checking code smells (shellcheck)"
    local exec_cmd="find /mnt -name '*.sh' | xargs shellcheck"
    docker run --rm -v "$target_folder:/mnt" "$shellcheck" sh -c "$exec_cmd"
}

echo
echo "🔥 Linting Bash scripts"
echo

require_docker_daemon
require_docker_image "$shmft"
require_docker_image "$shellcheck"

echo
check_code_style
check_code_smells

echo
echo "✅ All good!"
echo
