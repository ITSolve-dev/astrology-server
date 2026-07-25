#!/usr/bin/env bash
set -euo pipefail

# Create a git worktree for a task.
#
# Usage:
#   ./scripts/worktree-create.sh ISSUE=<number>              # auto-derive from GitHub issue
#   ./scripts/worktree-create.sh BRANCH=<full-branch-name>   # manual branch name
#
# Auto mode fetches issue title and type from GitHub, builds branch name:
#   <git-username>/<type>/<number>-<title-slug>

ISSUE=""
BRANCH=""

for arg in "$@"; do
    case "$arg" in
        ISSUE=*) ISSUE="${arg#ISSUE=}" ;;
        BRANCH=*) BRANCH="${arg#BRANCH=}" ;;
        *) echo "Unknown argument: $arg"; exit 1 ;;
    esac
done

if [[ -z "$ISSUE" && -z "$BRANCH" ]]; then
    echo "Usage: $0 ISSUE=<number> or BRANCH=<full-branch-name>"
    exit 1
fi

slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

git_username() {
    local name
    name=$(git config user.name 2>/dev/null || echo "")
    if [[ -z "$name" ]]; then
        echo "Error: git user.name is not configured" >&2
        exit 1
    fi
    echo "$name" | tr '[:upper:]' '[:lower:]' | tr -d ' '
}

# Derive branch name from issue
if [[ -n "$ISSUE" ]]; then
    echo "Fetching issue #${ISSUE}..."

    issue_json=$(gh issue view "$ISSUE" --json title,projectItems)
    title=$(echo "$issue_json" | jq -r '.title')

    # Extract type from project board item properties
    issue_type=$(echo "$issue_json" | jq -r '
        .projectItems[]?.fieldValues[]? |
        select(.name == "Type") |
        .text // .name // empty
    ' 2>/dev/null | head -1)

    if [[ -z "$issue_type" ]]; then
        echo "Warning: could not detect issue type from project board, defaulting to 'feature'"
        issue_type="feature"
    fi

    issue_type=$(echo "$issue_type" | tr '[:upper:]' '[:lower:]')
    slug=$(slugify "$title")
    username=$(git_username)
    BRANCH="${username}/${issue_type}/${ISSUE}-${slug}"

    echo "Title:  $title"
    echo "Type:   $issue_type"
fi

# Derive worktree directory name from branch
worktree_name=$(echo "$BRANCH" | sed 's|.*/||')
worktree_dir=".worktrees/${worktree_name}"

echo "Branch: $BRANCH"
echo "Dir:    $worktree_dir"
echo ""

# Fetch latest main
echo "Fetching origin..."
git fetch origin

# Create worktree
echo "Creating worktree..."
git worktree add "$worktree_dir" -b "$BRANCH" origin/main

# Symlink .env if exists
if [[ -f ".env" ]]; then
    ln -sf "$(pwd)/.env" "${worktree_dir}/.env"
    echo "Symlinked .env"
fi

# Symlink .venv if exists
if [[ -d ".venv" ]]; then
    ln -sf "$(pwd)/.venv" "${worktree_dir}/.venv"
    echo "Symlinked .venv"
else
    # Install dependencies in worktree
    echo "Installing dependencies..."
    (cd "$worktree_dir" && make install)
fi

# Validation summary
echo ""
echo "=== Worktree ready ==="
echo "  Branch:    $BRANCH"
echo "  Directory: $worktree_dir"
echo "  User:      $(git config user.name) <$(git config user.email)>"
echo ""
echo "  cd $worktree_dir"
