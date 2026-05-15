#!/usr/bin/env bash
set -euo pipefail

if [ ! -d .git ]; then
  echo "Run this from the git repo root." >&2
  exit 1
fi

REPO_NAME="$(basename "$(git rev-parse --show-toplevel)")"

mkdir -p src/xr102232_test tests docs .github/workflows .github/ISSUE_TEMPLATE scripts

cat > .gitignore <<'EOF'
# Python
__pycache__/
*.py[cod]
*.pyd
*.so
*.egg-info/
.eggs/
.build/
dist/
.venv/
.venv.bak/

# Tooling
.mypy_cache/
.pytest_cache/
.ruff_cache/
.coverage*
htmlcov/

# OS
.DS_Store
EOF

cat > LICENSE <<'EOF'
MIT License

Copyright (c) 2026 Anand

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF

cat > CODE_OF_CONDUCT.md <<'EOF'
# Code of Conduct

We follow a welcoming, community-first approach.

## Expected behavior
- Be respectful and constructive.
- Assume good intent.
- Provide actionable feedback.

## Unacceptable behavior
- Harassment, hate speech, or bullying.
- Threats or discrimination.
- Disruptive spam or trolling.

## Enforcement
If you witness unacceptable behavior, please open an issue describing what happened.
EOF

cat > CONTRIBUTING.md <<'EOF'
# Contributing

Thank you for contributing! This project uses:
- Conventional Commits (for automated release notes)
- Pull requests for changes

## How to propose changes
1. Fork/branch from `main`
2. Use a descriptive branch name, e.g. `feature/fast-parse`.
3. Open a PR with a clear description and test results.

## Commit message format
Use Conventional Commits, for example:
- `feat: add new parser`
- `fix: handle empty input`
- `docs: update README`
- `chore: bump dependencies`

## Tests
Run:
- `pytest`
- `ruff check .`
EOF

cat > .github/SECURITY.md <<'EOF'
# Security Policy

If you discover a security issue, please do not open a public issue.

Send a report to: security@example.com

Include:
- what you observed
- affected versions/paths
- steps to reproduce
EOF

cat > README.md <<'EOF'
# xr102232_test

A small Python package scaffolded as a realistic engineering project: CI, tests, release automation, and documentation.

## Badges
[![CI](https://github.com/{OWNER}/{REPO_NAME}/actions/workflows/ci.yml/badge.svg)](https://github.com/{OWNER}/{REPO_NAME}/actions/workflows/ci.yml)
[![Docs](https://github.com/{OWNER}/{REPO_NAME}/actions/workflows/pages.yml/badge.svg)](https://github.com/{OWNER}/{REPO_NAME}/actions/workflows/pages.yml)

## Status
- Tests: via GitHub Actions
- Docs: GitHub Pages (MkDocs)
- Releases: Release-Please (semantic versioning)

## Quick start
```bash
python -m pip install -e ".[dev]"
python -c "from xr102232_test import add; print(add(1, 2))"
```

## Contributing
See [`CONTRIBUTING.md`](CONTRIBUTING.md).
EOF

OWNER="$(git remote get-url origin | sed -E 's#.*github.com[:/]([^/]+)/([^/.]+)(\.git)?$#\1#')"
REPO="$(git remote get-url origin | sed -E 's#.*github.com[:/]([^/]+)/([^/.]+)(\.git)?$#\2#')"
sed -i "s/{OWNER}/$OWNER/g; s/{REPO_NAME}/$REPO/g" README.md

cat > .editorconfig <<'EOF'
root = true
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 4
EOF

cat > .pre-commit-config.yaml <<'EOF'
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.9
    hooks:
      - id: ruff
      - id: ruff-format
EOF

cat > pyproject.toml <<'EOF'
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "xr102232_test"
version = "0.1.0"
description = "A realistic repo scaffold for CI, releases, and achievements practice."
readme = "README.md"
requires-python = ">=3.10"
license = { text = "MIT" }
authors = [{ name = "Anand", email = "anandmohan.amp@gmail.com" }]
classifiers = [
  "Programming Language :: Python :: 3",
  "License :: OSI Approved :: MIT License",
  "Operating System :: OS Independent",
]

dependencies = []

[project.optional-dependencies]
dev = [
  "pytest>=8",
  "ruff>=0.6.0",
  "mypy>=1.10.0",
  "pre-commit>=3.7",
  "mkdocs>=1.6.1",
  "mkdocs-material>=9.5.0",
  "build>=1.2.0",
  "twine>=5.0.0",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
addopts = "-q"
testpaths = ["tests"]

[tool.ruff]
line-length = 100
target-version = "py310"

[tool.ruff.lint]
select = ["E", "F", "I", "UP"]
EOF

cat > src/xr102232_test/__init__.py <<'EOF'
"""xr102232_test package."""

from .core import add, parse_int, subtract

__all__ = ["add", "parse_int", "subtract"]

__version__ = "0.1.0"
EOF

cat > src/xr102232_test/core.py <<'EOF'
from __future__ import annotations


def add(a: int, b: int) -> int:
    """Add two integers."""
    return a + b


def subtract(a: int, b: int) -> int:
    """Subtract b from a."""
    return a - b


def parse_int(value: str) -> int:
    """Parse an integer from a string.

    Raises:
        ValueError: if the input cannot be parsed as an integer.
    """
    value = value.strip()
    if value == "":
        raise ValueError("empty string")
    return int(value)
EOF

cat > tests/test_core.py <<'EOF'
import pytest

from xr102232_test import add, parse_int, subtract


def test_add():
    assert add(1, 2) == 3


def test_subtract():
    assert subtract(5, 3) == 2


def test_parse_int_ok():
    assert parse_int(" 42 ") == 42


def test_parse_int_empty():
    with pytest.raises(ValueError):
        parse_int("   ")
EOF

cat > mkdocs.yml <<'EOF'
site_name: xr102232_test
site_url: https://{OWNER}.github.io/{REPO}/

theme:
  name: material
  features:
    - navigation.tabs

nav:
  - Home: index.md
  - Getting Started: getting_started.md
  - API: api.md
EOF

cat > docs/index.md <<'EOF'
# xr102232_test

Welcome. This site is deployed via GitHub Pages using MkDocs.

## What's inside
- A tiny Python library
- Tests running in CI
- Release automation via Release-Please
EOF

cat > docs/getting_started.md <<'EOF'
# Getting Started

Install in development mode:

```bash
pip install -e ".[dev]"
```

Example:

```python
from xr102232_test import add
print(add(1, 2))
```
EOF

cat > docs/api.md <<'EOF'
# API Reference

## `add(a, b)`
Returns the sum of two integers.

## `subtract(a, b)`
Returns `a - b`.

## `parse_int(value)`
Parses a stripped string into an integer.
EOF

cat > .github/ISSUE_TEMPLATE/config.yml <<'EOF'
blank_issues_enabled: false
contact_links:
  - name: Discussions
    url: https://github.com/{OWNER}/{REPO}/discussions
    about: Ask questions and share ideas
EOF

cat > .github/ISSUE_TEMPLATE/bug_report.yml <<'EOF'
name: Bug report
description: Report a bug.
title: "bug: "
labels:
  - bug
body:
  - type: markdown
    attributes:
      value: "Thanks for taking the time to report a bug."
  - type: textarea
    id: description
    attributes:
      label: What happened?
      description: Include a clear description.
    validations:
      required: true
  - type: textarea
    id: steps
    attributes:
      label: Steps to reproduce
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Expected behavior
    validations:
      required: true
  - type: textarea
    id: logs
    attributes:
      label: Logs / screenshots
  - type: dropdown
    id: severity
    attributes:
      label: Severity
      options:
        - low
        - medium
        - high
EOF

cat > .github/ISSUE_TEMPLATE/feature_request.yml <<'EOF'
name: Feature request
description: Suggest an improvement.
title: "feat: "
labels:
  - enhancement
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem statement
    validations:
      required: true
  - type: textarea
    id: solution
    attributes:
      label: Proposed solution
    validations:
      required: true
  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives considered
EOF

cat > .github/pull_request_template.md <<'EOF'
## Summary

## Type
- [ ] Bug fix
- [ ] New feature
- [ ] Docs
- [ ] Chore

## Testing
- [ ] pytest
- [ ] ruff

## Checklist
- [ ] I added/updated tests
- [ ] I updated docs if needed
EOF

cat > .github/dependabot.yml <<'EOF'
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
EOF

cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install deps
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"

      - name: Ruff (lint)
        run: ruff check .

      - name: Ruff (format check)
        run: ruff format --check .

      - name: Pytest
        run: pytest
EOF

cat > .github/workflows/pages.yml <<'EOF'
name: Docs (MkDocs)

on:
  push:
    branches: [main]

permissions:
  contents: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install deps
        run: |
          python -m pip install --upgrade pip
          pip install mkdocs mkdocs-material

      - name: Build and deploy
        run: mkdocs gh-deploy --force
EOF

cat > release-please-config.json <<'EOF'
{
  "packages": {
    ".": {
      "release-type": "python",
      "package-name": "xr102232_test",
      "changelog-path": "CHANGELOG.md"
    }
  }
}
EOF

cat > .release-please-manifest.json <<'EOF'
{
  ".": "0.1.0"
}
EOF

cat > .github/workflows/release-please.yml <<'EOF'
name: Release Please

on:
  push:
    branches: [main]

permissions:
  contents: write
  pull-requests: write
  issues: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          config-file: release-please-config.json
          manifest-file: .release-please-manifest.json
EOF

cat > .github/workflows/publish-pypi.yml <<'EOF'
name: Publish to PyPI

on:
  release:
    types: [published]

permissions:
  contents: read

jobs:
  publish:
    runs-on: ubuntu-latest
    if: ${{ secrets.PYPI_API_TOKEN != '' }}
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Build
        run: |
          python -m pip install --upgrade pip
          python -m pip install build
          python -m build

      - name: Publish
        env:
          TWINE_USERNAME: __token__
          TWINE_PASSWORD: ${{ secrets.PYPI_API_TOKEN }}
        run: |
          python -m pip install twine
          twine upload --non-interactive dist/*
EOF

sed -i "s/{OWNER}/$OWNER/g; s/{REPO}/$REPO/g" mkdocs.yml .github/ISSUE_TEMPLATE/config.yml

cat > CHANGELOG.md <<'EOF'
# Changelog

All notable changes to this project will be documented in this file.
EOF

cat > docs/DISCUSSIONS.md <<'EOF'
# Discussions setup

Enable Discussions in GitHub: **Settings → General → Features → Discussions**.

Suggested categories:
- General
- Ideas
- Q&A
- Show and tell
EOF

cat > docs/WIKI.md <<'EOF'
# Wiki suggestions

Suggested wiki pages:
- Architecture overview
- Release process
- Local development setup
EOF

cat > ACHIEVEMENTS.md <<'EOF'
# GitHub Achievement Tracker

| Achievement | Difficulty | Steps required | Automatable | Est. time | Progress |
|-------------|------------|----------------|-------------|-----------|----------|
| Quickdraw | Easy | Close issue/PR within 5 min of opening | Partial (gh CLI) | 5 min | [ ] |
| YOLO | Easy | Merge PR without review | Partial | 10 min | [ ] |
| Pull Shark | Hard | 2+ merged PRs in repos you don't own | No (needs others) | Weeks+ | [ ] |
| Pair Extraordinaire | Hard | Co-authored merged PRs | No (needs collaborator) | Weeks+ | [ ] |
| Galaxy Brain | Hard | 2+ accepted discussion answers | No | Weeks+ | [ ] |
| Starstruck | Very Hard | 16+ stars from other users | No | Months+ | [ ] |
| Public Sponsor | Medium | Sponsor via GitHub Sponsors | No (payment) | 15 min | [ ] |
| Arctic Code Vault | N/A | Historical 2020 archive program | No | N/A | [ ] |
| Mars 2020 Contributor | N/A | Historical mission repos | No | N/A | [ ] |

## Pull Shark tiers (external repos only)
- Default: 2 merged PRs
- Bronze: 16
- Silver: 128
- Gold: 1024

## Pair Extraordinaire tiers
- Default: 1 co-authored merged PR
- Bronze: 10 | Silver: 24 | Gold: 48

## Starstruck tiers
- Default: 16 stars | Bronze: 128 | Silver: 512 | Gold: 4096

## Galaxy Brain tiers
- Default: 2 accepted answers | Bronze: 8 | Silver: 16 | Gold: 32
EOF

cat > scripts/run_activity.sh <<'ACTIVITY_EOF'
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
ACTIVITY_EOF

chmod +x scripts/run_activity.sh

if git rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "Repo already has commits; skipping initial commit."
else
  git add -A
  git commit -m "chore: scaffold project"
  git branch -M main
  git push -u origin main
fi

echo "Bootstrap complete."
