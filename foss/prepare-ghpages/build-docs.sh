#!/usr/bin/env bash
# Copyright 2024 Dotanuki Labs
# SPDX-License-Identifier: MIT

# shellcheck disable=SC2001

set -eou pipefail

readonly root_dir="$1"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ensure_required_files() {
    if [ ! -f "$root_dir/docs/website.json" ]; then
        echo "docs/website.json required but not found"
        echo
        exit 1
    fi

    if [ ! -f "$root_dir/docs/readme.md" ]; then
        echo "docs/readme.md required but not found"
        echo
        exit 1
    fi
}

setup_vitepress() {
    cp "$script_dir/vitepress/package.json" "$root_dir/package.json"
    cp "$script_dir/vitepress/package-lock.json" "$root_dir/package-lock.json"
    mkdir -p "$root_dir/docs/.vitepress"
    cp "$script_dir/vitepress/config.mts" "$root_dir/docs/.vitepress/config.mts"

    local repo_name
    repo_name=$(echo "$GITHUB_REPOSITORY" | sed "s/dotanuki-labs\///g")
    perl -pi -e "s/<base-path>/$repo_name/g" "$root_dir/docs/.vitepress/config.mts"
    perl -pi -e "s/<repo>/$repo_name/g" "$root_dir/docs/.vitepress/config.mts"

    mv "$root_dir/docs/readme.md" "$root_dir/docs/index.md"
}

build_docs() {
    npm install
    npm run docs:build
}

ensure_required_files
setup_vitepress
build_docs

echo
echo "✅ Done"
echo
