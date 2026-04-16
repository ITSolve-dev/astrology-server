.DEFAULT_GOAL := help

.PHONY: help install install-dev install-test install-hooks lint format typecheck check server test worktree-create worktree-cleanup pr-create

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install all dependencies
	uv sync --all-groups

install-dev: ## Install dev dependencies only
	uv sync --group dev

install-test: ## Install test dependencies only
	uv sync --group test

install-hooks: ## Install pre-commit hooks
	uv run prek install

lint: ## Run ruff linter with auto-fix
	uv run ruff check --fix .

format: ## Run ruff formatter
	uv run ruff format .

typecheck: ## Run ty type checker
	uv run ty check

check: lint format typecheck ## Run all checks (lint + format + typecheck)

server: ## Run development server
	uv run fastapi dev src/main.py

test: ## Run tests
	uv run pytest

worktree-create: ## Create worktree (ISSUE=<n> or BRANCH=<name>)
	@bash scripts/worktree-create.sh $(if $(ISSUE),ISSUE=$(ISSUE)) $(if $(BRANCH),BRANCH=$(BRANCH))

worktree-cleanup: ## Remove worktree (NAME=<name>, or auto-detect)
	@bash scripts/worktree-cleanup.sh $(if $(NAME),NAME=$(NAME))

pr-create: ## Create PR with auto-generated description
	@bash scripts/pr-create.sh
