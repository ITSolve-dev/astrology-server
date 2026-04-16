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

worktree_dir=".worktrees/${NAME}"

if [[ ! -d "$worktree_dir" ]]; then
    echo "Error: worktree directory not found: $worktree_dir"
    exit 1
fi

# Get branch name before removing
branch=$(git -C "$worktree_dir" branch --show-current 2>/dev/null || echo "")

echo "Removing worktree: $worktree_dir"
git worktree remove "$worktree_dir" --force

if [[ -n "$branch" ]]; then
    echo "Deleting local branch: $branch"
    git branch -D "$branch" 2>/dev/null || echo "Branch already deleted or not found"
fi

echo "Pruning..."
git worktree prune
git fetch --prune

echo ""
echo "=== Cleanup complete ==="
echo "  Worktree: $worktree_dir (removed)"
[[ -n "$branch" ]] && echo "  Branch:   $branch (deleted)"
