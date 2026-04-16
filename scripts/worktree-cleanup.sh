#!/usr/bin/env bash
set -euo pipefail

# Remove a git worktree and clean up its branch.
#
# Usage:
#   ./scripts/worktree-cleanup.sh              # cleanup current worktree (auto-detect)
#   ./scripts/worktree-cleanup.sh NAME=<name>  # cleanup specific worktree by dir name

NAME=""

for arg in "$@"; do
    case "$arg" in
        NAME=*) NAME="${arg#NAME=}" ;;
        *) echo "Unknown argument: $arg"; exit 1 ;;
    esac
done

# Resolve the main repo root (works from inside worktrees too)
repo_root=$(git rev-parse --show-toplevel)
# If inside a worktree, get the root of the main working tree
main_root=$(git -C "$repo_root" worktree list --porcelain | head -1 | sed 's/^worktree //')

# Auto-detect worktree name from current directory
if [[ -z "$NAME" ]]; then
    current_dir=$(pwd)
    if [[ "$current_dir" == */.worktrees/* ]]; then
        NAME=$(basename "$current_dir")
    else
        echo "Error: not inside a worktree directory. Provide NAME=<worktree-name>"
        exit 1
    fi
fi

worktree_dir="${main_root}/.worktrees/${NAME}"

if [[ ! -d "$worktree_dir" ]]; then
    echo "Error: worktree directory not found: $worktree_dir"
    exit 1
fi

# Get branch name before removing
branch=$(git -C "$worktree_dir" branch --show-current 2>/dev/null || echo "")

echo "Removing worktree: .worktrees/${NAME}"
git -C "$main_root" worktree remove ".worktrees/${NAME}" --force

if [[ -n "$branch" ]]; then
    echo "Deleting local branch: $branch"
    git -C "$main_root" branch -D "$branch" 2>/dev/null || echo "Branch already deleted or not found"
fi

echo "Pruning..."
git -C "$main_root" worktree prune
git -C "$main_root" fetch --prune

echo ""
echo "=== Cleanup complete ==="
echo "  Worktree: .worktrees/${NAME} (removed)"
[[ -n "$branch" ]] && echo "  Branch:   $branch (deleted)"
