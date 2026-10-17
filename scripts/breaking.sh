#!/bin/sh
# Checks for breaking changes against the latest v* tag; skips when no release exists yet.
set -eu

tag="$(git tag --list 'v*' --sort=-v:refname | head -n 1)"
if [ -z "$tag" ]; then
  echo "breaking: no release tag yet, skipped"
  exit 0
fi

echo "breaking: comparing against $tag"
buf breaking --against ".git#tag=$tag"
