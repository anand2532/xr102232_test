#!/usr/bin/env bash
# Run after bootstrap: creates branches, incremental commits, PRs, Quickdraw, YOLO.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI required for PR/issue automation" >&2
  exit 1
fi

OWNER_REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"

# --- Quickdraw: open and close issue within 5 minutes ---
echo "=== Quickdraw ==="
ISSUE_URL=$(gh issue create --title "chore: quickdraw test issue" --body "Temporary issue for achievement verification. Safe to close immediately.")
ISSUE_NUM=$(echo "$ISSUE_URL" | grep -oE '[0-9]+$')
sleep 2
gh issue close "$ISSUE_NUM" --comment "Resolved immediately (Quickdraw test)."
echo "Closed issue #$ISSUE_NUM"

# --- Feature branches with meaningful commits ---
branches=(
  "feature/multiply"
  "feature/clamp"
  "fix/parse-sign"
  "docs/readme-badges"
  "chore/ci-matrix"
)

for branch in "${branches[@]}"; do
  git checkout main
  git pull origin main 2>/dev/null || true
  git checkout -B "$branch"
  case "$branch" in
    feature/multiply)
      cat >> src/xr102232_test/core.py <<'PY'


def multiply(a: int, b: int) -> int:
    """Multiply two integers."""
    return a * b
PY
      sed -i 's/__all__ = \["add", "parse_int", "subtract"\]/__all__ = ["add", "parse_int", "subtract", "multiply"]/' src/xr102232_test/__init__.py
      sed -i 's/from .core import add, parse_int, subtract/from .core import add, parse_int, subtract, multiply/' src/xr102232_test/__init__.py
      cat >> tests/test_core.py <<'PY'


def test_multiply():
    from xr102232_test import multiply

    assert multiply(3, 4) == 12
PY
      git add -A && git commit -m "feat: add multiply helper"
      ;;
    feature/clamp)
      cat >> src/xr102232_test/core.py <<'PY'


def clamp(value: int, low: int, high: int) -> int:
    """Clamp value to [low, high]."""
    return max(low, min(high, value))
PY
      sed -i 's/"subtract"\]/"subtract", "clamp"\]/' src/xr102232_test/__init__.py
      sed -i 's/subtract$/subtract, clamp/' src/xr102232_test/__init__.py
      cat >> tests/test_core.py <<'PY'


def test_clamp():
    from xr102232_test import clamp

    assert clamp(10, 0, 5) == 5
    assert clamp(-1, 0, 5) == 0
PY
      git add -A && git commit -m "feat: add clamp utility"
      ;;
    fix/parse-sign)
      python3 <<'PY'
from pathlib import Path
p = Path("src/xr102232_test/core.py")
text = p.read_text()
old = '    return int(value)'
new = '    if value.startswith("+"):\n        value = value[1:]\n    return int(value)'
if old in text and "startswith" not in text:
    p.write_text(text.replace(old, new, 1))
PY
      cat >> tests/test_core.py <<'PY'


def test_parse_int_plus_sign():
    assert parse_int("+7") == 7
PY
      git add -A && git commit -m "fix: accept leading plus in parse_int"
      ;;
    docs/readme-badges)
      echo "" >> README.md
      echo "## License" >> README.md
      echo "MIT — see [LICENSE](LICENSE)." >> README.md
      git add README.md && git commit -m "docs: add license section to README"
      ;;
    chore/ci-matrix)
      # already has matrix in ci.yml from bootstrap
      echo "# CI notes" >> docs/getting_started.md
      echo "" >> docs/getting_started.md
      echo "CI runs on Python 3.10–3.12." >> docs/getting_started.md
      git add docs/getting_started.md && git commit -m "docs: document CI Python versions"
      ;;
  esac
  git push -u origin "$branch" 2>/dev/null || git push -u origin "$branch" --force
  gh pr create --base main --head "$branch" --title "${branch//\//: }" --body "Automated PR for project activity."
  git checkout main
done

# --- YOLO: merge without review ---
echo "=== YOLO ==="
git checkout -B yolo/no-review-merge
echo "# YOLO merge test" >> docs/WIKI.md
git add docs/WIKI.md && git commit -m "docs: yolo merge test note"
git push -u origin yolo/no-review-merge 2>/dev/null || git push -u origin yolo/no-review-merge --force
YOLO_PR=$(gh pr create --base main --head yolo/no-review-merge --title "docs: yolo merge without review" --body "Merge without review for YOLO achievement.")
sleep 2
gh pr merge "$YOLO_PR" --merge --admin 2>/dev/null || gh pr merge "$YOLO_PR" --merge
git checkout main
git pull origin main 2>/dev/null || true

# --- Merge other PRs (not YOLO - those had reviews skipped only on yolo) ---
for branch in "${branches[@]}"; do
  PR_NUM=$(gh pr list --head "$branch" --json number -q '.[0].number' 2>/dev/null || true)
  if [ -n "${PR_NUM:-}" ] && [ "$PR_NUM" != "null" ]; then
  gh pr merge "$PR_NUM" --merge --admin 2>/dev/null || gh pr merge "$PR_NUM" --merge || true
  sleep 3
  fi
done

git checkout main
git pull origin main 2>/dev/null || true
echo "Activity script complete."
