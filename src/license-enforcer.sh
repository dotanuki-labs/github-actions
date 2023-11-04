#!/usr/bin/env bash
# Copyright 2023 Dotanuki Labs
# SPDX-License-Identifier: MIT

# shellcheck disable=SC2046

set -eo pipefail

# https://github.com/google/addlicense
readonly image="ghcr.io/google/addlicense"

readonly target_folder="$1"
readonly sources="$2"
readonly license="$3"

require_docker() {
    if (! docker stats --no-stream >/dev/null); then
        echo "Docker is required for this check"
        echo
        exit 1
    fi
}

check_license_on_files() {
    local extension="$1"

    echo "→ Checking licenses for $files files"

    docker run --rm -v "${target_folder}:/src" "$image" \
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
    IFS=" " read -r -a files <<<"$(echo "$sources" | sed "s/,/[:space:]/g" | xargs)"

    for type in "${files[@]}"; do
        check_license_on_files "$type" || report_missing_licenses
    done
}

echo
echo "🔥 Enforcing open-source license on source files"
echo

require_docker
enforce_license_for_file_patterns

echo
echo "✅ All good!"
echo
