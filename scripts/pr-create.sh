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
issue_number=$(echo "$branch" | sed 's|.*/||' | sed 's/-.*//' | grep -o '[0-9]*')

if [[ -z "$issue_number" ]]; then
    echo "Error: could not extract issue number from branch: $branch"
    exit 1
fi

# Fetch latest origin/main for accurate diff
git fetch origin main --quiet

# Fetch issue title
echo "Fetching issue #${issue_number}..."
issue_title=$(gh issue view "$issue_number" --json title --jq '.title')

# PR title
pr_title="[#${issue_number}] ${issue_title}"

# Collect commits since origin/main
commits=$(git log origin/main..HEAD --format="%s" --reverse)

if [[ -z "$commits" ]]; then
    echo "Error: no commits found between origin/main and HEAD"
    exit 1
fi

# Type labels for commit grouping
get_type_label() {
    case "$1" in
        feat)     echo "Features" ;;
        fix)      echo "Fixes" ;;
        docs)     echo "Documentation" ;;
        style)    echo "Style" ;;
        refactor) echo "Refactoring" ;;
        perf)     echo "Performance" ;;
        test)     echo "Tests" ;;
        build)    echo "Build" ;;
        ci)       echo "CI" ;;
        chore)    echo "Chores" ;;
        *)        echo "Other" ;;
    esac
}

# Group commits by type into temp files
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

while IFS= read -r commit; do
    type=$(echo "$commit" | sed -n 's/^\([a-z]*\)\(([^)]*)\)\?[!]\?:.*/\1/p')
    desc=$(echo "$commit" | sed 's/^[a-z]*\(([^)]*)\)\?[!]\?:[[:space:]]*//' | sed 's/[[:space:]]*([#][0-9]*)$//')

    if [[ -z "$type" ]]; then
        type="other"
    fi

    echo "- ${desc}" >> "${tmpdir}/${type}"
done <<< "$commits"

# Build body
body="## Summary"$'\n\n'"${issue_title}"$'\n\n'"## Changes"$'\n'

for type in feat fix docs style refactor perf test build ci chore other; do
    if [[ -f "${tmpdir}/${type}" ]]; then
        label=$(get_type_label "$type")
        body="${body}"$'\n'"### ${label}"$'\n'"$(cat "${tmpdir}/${type}")"$'\n'
    fi
done

body="${body}"$'\n'"Closes #${issue_number}"

# Check for uncommitted changes
if [[ -n "$(git status --porcelain)" ]]; then
    echo "Error: working tree has uncommitted or unstaged changes"
    echo ""
    git status --short
    exit 1
fi

# Push branch to origin
echo "Pushing branch..."
git push -u origin "$branch"

# Create PR
echo ""
echo "Title: $pr_title"
echo ""
echo "$body"
echo ""
echo "Creating PR..."

# Resolve GitHub username
assignee=$(gh api user --jq '.login' 2>/dev/null || echo "")

pr_url=$(gh pr create --title "$pr_title" --body "$body" --draft ${assignee:+--assignee "$assignee"} 2>&1)

echo ""
echo "=== PR created ==="
echo "  $pr_url"
