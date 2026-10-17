# Compatible with GNU Make 3.81 (macOS) and 4.x (WSL2).
SHELL := /bin/sh
.DEFAULT_GOAL := help

.PHONY: help lint format format-check breaking go-check check

help: ## List available commands
	@grep -E '^[a-zA-Z_-]+:.*## ' $(firstword $(MAKEFILE_LIST)) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  %-14s %s\n", $$1, $$2}'

lint: ## Lint protos with the STANDARD rule set
	@buf lint && echo "lint: ok"

format: ## Rewrite protos in canonical format
	@buf format --write

format-check: ## Fail if any proto is not formatted
	@buf format --diff --exit-code && echo "format-check: ok"

breaking: ## Check for breaking changes against the latest release tag
	@sh scripts/breaking.sh

go-check: ## Generate Go code and compile it
	@sh scripts/go-check.sh

check: format-check lint breaking go-check ## Run every gate (same as CI)
	@echo "check: all gates passed"
