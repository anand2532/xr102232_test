#!/usr/bin/env bash
# Push 5 feature branches (merge via gh or Actions after enabling PR permission).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git checkout main && git pull origin main

merge_branch() {
  local branch=$1
  local msg=$2
  shift 2
  git checkout -B "$branch" main
  "$@"
  git add -A
  git commit -m "$msg"
  git push -u origin "$branch" --force
  git checkout main
}

merge_branch "feature/push-multiply" "feat: multiply on branch" bash -c \
  'echo -e "def multiply(a, b):\n    return a * b" >> src/xr102232_test/extras.py'

merge_branch "feature/push-clamp" "feat: clamp on branch" bash -c \
  'echo -e "\ndef clamp(v, lo, hi):\n    return max(lo, min(hi, v))" >> src/xr102232_test/extras.py'

merge_branch "fix/push-readme" "docs: readme branch tweak" bash -c \
  'echo "" >> README.md && echo "<!-- pr branch -->" >> README.md'

merge_branch "docs/push-api" "docs: api branch note" bash -c \
  'echo "Branch PR activity." >> docs/api.md'

merge_branch "chore/push-changelog" "chore: changelog branch entry" bash -c \
  'echo "- Branch PR batch" >> CHANGELOG.md'

git checkout -B yolo/no-review-merge main
echo "YOLO branch — merge without review via PR." >> docs/WIKI.md
git add docs/WIKI.md && git commit -m "docs: yolo branch for no-review merge"
git push -u origin yolo/no-review-merge --force
git checkout main

echo "Pushed 6 branches. Merge with: gh pr create && gh pr merge (see docs/GITHUB_SETUP.md)"
