#!/usr/bin/env bash
# Local fallback for Quickdraw, YOLO, and 5 PR merges (requires: gh auth login)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

if ! gh auth status >/dev/null 2>&1; then
  echo "Run: gh auth login" >&2
  exit 1
fi

echo "=== Quickdraw ==="
NUM=$(gh issue create --title "chore: quickdraw local" --body "Close immediately." | grep -oE '[0-9]+$')
sleep 2
gh issue close "$NUM" --comment "Quickdraw local close."
echo "Closed #$NUM"

echo "=== YOLO ==="
git checkout main && git pull origin main
git checkout -B yolo/local-no-review
echo "Local YOLO merge." >> docs/WIKI.md
git add docs/WIKI.md && git commit -m "docs: yolo local merge"
git push -u origin yolo/local-no-review --force
PR=$(gh pr create --base main --head yolo/local-no-review --title "docs: yolo local" --body "No review.")
sleep 2
gh pr merge "$PR" --merge
git checkout main && git pull origin main

branches=(
  "feature/local-multiply:feat: local multiply"
  "feature/local-abs:feat: local abs"
  "fix/local-readme:docs: local readme tweak"
  "docs/local-api:docs: local api note"
  "chore/local-changelog:chore: local changelog"
)

for spec in "${branches[@]}"; do
  branch="${spec%%:*}"
  msg="${spec#*:}"
  git checkout main && git pull origin main
  git checkout -B "$branch"
  case "$branch" in
    feature/local-multiply)
      printf 'def multiply(a, b):\n    return a * b\n' >> src/xr102232_test/extras.py 2>/dev/null || \
        printf 'def multiply(a, b):\n    return a * b\n' > src/xr102232_test/extras.py
      ;;
    feature/local-abs)
      cat >> src/xr102232_test/extras.py <<'PY'

def abs_int(n):
    return -n if n < 0 else n
PY
      ;;
    fix/local-readme)
      echo "" >> README.md
      echo "<!-- local pr -->" >> README.md
      ;;
    docs/local-api)
      echo "Local PR activity." >> docs/api.md
      ;;
    chore/local-changelog)
      echo "- Local PR batch" >> CHANGELOG.md
      ;;
  esac
  git add -A && git commit -m "$msg"
  git push -u origin "$branch" --force
  PR=$(gh pr create --base main --head "$branch" --title "$msg" --body "Local PR activity.")
  sleep 3
  gh pr merge "$PR" --squash
done

git checkout main && git pull origin main
echo "Local achievements script done."
