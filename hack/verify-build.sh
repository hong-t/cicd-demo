#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

PLATFORMS=(
    linux/amd64
    windows/amd64
    darwin/amd64
)

for PLATFORM in "${PLATFORMS[@]}"; do
    OS="${PLATFORM%/*}"
    ARCH=$(basename "$PLATFORM")

    echo "Building project for $PLATFORM"
    GOARCH="$ARCH" GOOS="$OS" go build -o output/ ./...
done
