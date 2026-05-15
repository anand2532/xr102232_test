#!/usr/bin/env bash
# Create and merge PRs for branches pushed by push_pr_branches.sh (requires gh auth).
set -euo pipefail
gh auth status

branches=(
  yolo/no-review-merge
  feature/push-multiply
  feature/push-clamp
  fix/push-readme
  docs/push-api
  chore/push-changelog
)

for branch in "${branches[@]}"; do
  if gh pr list --head "$branch" --state open --json number -q '.[0].number' 2>/dev/null | grep -q .; then
    num=$(gh pr list --head "$branch" --state open -q '.[0].number')
    gh pr merge "$num" --merge 2>/dev/null || gh pr merge "$num" --squash
    echo "Merged existing PR for $branch"
    continue
  fi
  pr=$(gh pr create --base main --head "$branch" --title "merge: $branch" --body "Automated merge batch.")
  sleep 2
  if [[ "$branch" == "yolo/no-review-merge" ]]; then
    gh pr merge "$pr" --merge
  else
    gh pr merge "$pr" --squash
  fi
  echo "Merged $branch"
  sleep 3
done
