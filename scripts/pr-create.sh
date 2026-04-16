#!/usr/bin/env bash
set -euo pipefail

# Create a PR with auto-generated title and description from commits.
#
# Usage:
#   ./scripts/pr-create.sh
#
# Extracts issue number from branch name, fetches issue title,
# groups commits by Conventional Commits type, generates PR body.

branch=$(git branch --show-current)

if [[ "$branch" == "main" ]]; then
    echo "Error: cannot create PR from main branch"
    exit 1
fi

# Extract issue number from branch name (e.g. .../1-server-configure-base-setup -> 1)
issue_number=$(echo "$branch" | grep -oP '/\K\d+(?=-)' | head -1)

if [[ -z "$issue_number" ]]; then
    echo "Error: could not extract issue number from branch: $branch"
    exit 1
fi

# Fetch issue title
echo "Fetching issue #${issue_number}..."
issue_title=$(gh issue view "$issue_number" --json title --jq '.title')

# PR title
pr_title="[#${issue_number}] ${issue_title}"

# Collect commits since main
commits=$(git log main..HEAD --format="%s" --reverse)

if [[ -z "$commits" ]]; then
    echo "Error: no commits found between main and HEAD"
    exit 1
fi

# Group commits by type
declare -A type_labels=(
    [feat]="Features"
    [fix]="Fixes"
    [docs]="Documentation"
    [style]="Style"
    [refactor]="Refactoring"
    [perf]="Performance"
    [test]="Tests"
    [build]="Build"
    [ci]="CI"
    [chore]="Chores"
)

declare -A grouped

while IFS= read -r commit; do
    # Extract type and description: "type(scope): desc (#N)" -> type, desc
    type=$(echo "$commit" | sed -n 's/^\([a-z]*\)\(([^)]*)\)\?[!]\?:.*/\1/p')
    desc=$(echo "$commit" | sed 's/^[a-z]*\(([^)]*)\)\?[!]\?:[[:space:]]*//' | sed 's/[[:space:]]*([#][0-9]*)$//')

    if [[ -z "$type" ]]; then
        type="other"
    fi

    if [[ -n "${grouped[$type]+x}" ]]; then
        grouped[$type]="${grouped[$type]}"$'\n'"- ${desc}"
    else
        grouped[$type]="- ${desc}"
    fi
done <<< "$commits"

# Build body
body="## Summary"$'\n\n'"${issue_title}"$'\n\n'"## Changes"$'\n'

for type in feat fix docs style refactor perf test build ci chore other; do
    if [[ -n "${grouped[$type]+x}" ]]; then
        label="${type_labels[$type]:-Other}"
        body="${body}"$'\n'"### ${label}"$'\n'"${grouped[$type]}"$'\n'
    fi
done

body="${body}"$'\n'"Closes #${issue_number}"

# Create PR
echo ""
echo "Title: $pr_title"
echo ""
echo "$body"
echo ""
echo "Creating PR..."

pr_url=$(gh pr create --title "$pr_title" --body "$body" 2>&1)

echo ""
echo "=== PR created ==="
echo "  $pr_url"
