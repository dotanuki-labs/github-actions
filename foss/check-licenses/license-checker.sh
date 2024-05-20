#!/usr/bin/env bash
# Copyright 2024 Dotanuki Labs
# SPDX-License-Identifier: MIT

# shellcheck disable=SC1091
# shellcheck disable=SC2046

set -eo pipefail

# https://github.com/google/addlicense/pkgs/container/addlicense
readonly addlicense="ghcr.io/google/addlicense:v1.1.0"

readonly target_folder="$1"
readonly sources="$2"
readonly license="$3"

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

check_license_on_files() {
    local extension="$1"

    echo "→ Checking licenses for $extension files"

    docker run --rm -v "${target_folder}:/src" "$addlicense" \
        -c "Dotanuki Labs" \
        -l "$license" \
        -check $(find . -type f -name "$extension")
}

report_missing_licenses() {
    echo
    echo "There are files with missing ($license) license"
    echo
    exit 1
}

enforce_license_for_file_patterns() {
    IFS=" " read -r -a files <<<"$(echo "$sources" | tr "," " " | xargs)"

    for type in "${files[@]}"; do
        check_license_on_files "$type" || report_missing_licenses
    done
}

echo
echo "🔥 Enforcing open-source license on source files"
echo

require_docker_daemon
require_docker_image "$addlicense"
enforce_license_for_file_patterns

echo
echo "✅ All good!"
echo
