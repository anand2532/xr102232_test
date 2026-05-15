#!/usr/bin/env bash
# Push feature branches for PR scenarios (see docs/GITHUB_SETUP.md to merge).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git checkout main && git pull origin main

merge_branch() {
  local branch=$1 msg=$2
  shift 2
  git checkout -B "$branch" main
  "$@"
  git add -A && git commit -m "$msg"
  git push -u origin "$branch" --force
  git checkout main
}

merge_branch "feature/push-multiply" "feat: multiply on branch" bash -c \
  'printf "\ndef multiply(a, b):\n    return a * b\n" >> src/xr102232_test/extras.py 2>/dev/null || printf "def multiply(a, b):\n    return a * b\n" > src/xr102232_test/extras.py'

merge_branch "feature/push-clamp" "feat: clamp on branch" bash -c \
  'printf "\ndef clamp(v, lo, hi):\n    return max(lo, min(hi, v))\n" >> src/xr102232_test/extras.py'

merge_branch "fix/push-readme" "docs: readme branch tweak" bash -c \
  'echo -e "\n<!-- pr branch -->" >> README.md'

merge_branch "docs/push-api" "docs: api branch note" bash -c \
  'echo "Branch PR activity." >> docs/api.md'

merge_branch "chore/push-changelog" "chore: changelog branch entry" bash -c \
  'echo "- Branch PR batch" >> CHANGELOG.md'

git checkout -B yolo/no-review-merge main
echo "YOLO branch — merge without review via PR." >> docs/WIKI.md
git add docs/WIKI.md && git commit -m "docs: yolo branch for no-review merge"
git push -u origin yolo/no-review-merge --force
git checkout main
echo "Done. Run: gh auth login && ./scripts/local_achievements.sh"
