#!/bin/sh
# Generates Go code into a temporary module and compiles it.
set -eu

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

buf generate --template "$root/buf.gen.go-check.yaml" --output "$tmp" "$root"

cd "$tmp"
go mod init example.com/contracts-check >/dev/null 2>&1
# Quiet on success; rerun verbosely so failures stay visible
go mod tidy >/dev/null 2>&1 || go mod tidy
go build ./...
echo "go-check: generated Go code compiles"
