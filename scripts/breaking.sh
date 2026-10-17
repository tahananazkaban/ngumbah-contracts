#!/bin/sh
# Checks for breaking changes against the latest v* tag; skips when no release exists yet.
set -eu

# Release tags only; pre-releases like v1.0.0-rc1 are ignored
tag="$(git tag --list 'v*' --sort=-v:refname | grep -v -- '-' | head -n 1)"
if [ -z "$tag" ]; then
  msg="breaking: no release tag yet, skipped"
  # Surface the skip as an annotation on GitHub Actions
  if [ "${GITHUB_ACTIONS:-}" = true ]; then echo "::notice::$msg"; else echo "$msg"; fi
  exit 0
fi

echo "breaking: comparing against $tag"
buf breaking --against ".git#tag=$tag"
