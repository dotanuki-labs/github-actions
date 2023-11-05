#!/usr/bin/env bash
# Copyright 2023 Dotanuki Labs
# SPDX-License-Identifier: MIT

set -e

readonly target_folder="$1"
readonly docker_shmft="docker.io/mvdan/shfmt:latest"
readonly docker_shellcheck="docker.io/koalaman/shellcheck-alpine:stable"

if (! docker stats --no-stream >/dev/null); then
    echo "Docker required for quality checks"
    exit 1
fi

echo
echo "🔥 Linting Bash scripts"
echo

echo "→ Checking code formatting (shfmt)"
docker run --rm -v "$target_folder:/mnt" -w /mnt "$docker_shmft" --diff .

echo

echo "→ Checking code smells (shellcheck)"

readonly gradle_wrapper_exclusion="-not -path ./gradle/*"
readonly find_with_execlusions="find /mnt -name '*.sh' $gradle_wrapper_exclusion"

docker run --rm -v "$target_folder:/mnt" "$docker_shellcheck" sh -c "$find_with_execlusions | xargs shellcheck"

echo
echo "✅ All good!"
echo
