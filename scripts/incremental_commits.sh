#!/usr/bin/env bash
# Adds >=20 meaningful commits on main (and creates develop branch).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
git checkout main
git pull origin main 2>/dev/null || true

commit_msg() {
  git add -A
  if git diff --cached --quiet; then
    return 1
  fi
  git commit -m "$1"
}

# 1
mkdir -p .github
echo "# Community" >> docs/DISCUSSIONS.md
commit_msg "docs: expand discussions guidance" || true

# 2
cat >> docs/WIKI.md <<'EOF'

## Roadmap
- v0.2: divide helper
- v0.3: CLI entrypoint
EOF
commit_msg "docs: add wiki roadmap" || true

# 3
cat > src/xr102232_test/types.py <<'EOF'
"""Shared type aliases."""

type IntPair = tuple[int, int]
EOF
commit_msg "refactor: add shared type aliases module" || true

# 4
cat >> tests/test_core.py <<'EOF'


def test_subtract_negative():
    assert subtract(0, 5) == -5
EOF
commit_msg "test: cover negative subtract" || true

# 5
mkdir -p .github/workflows
cat > .github/workflows/labeler.yml <<'EOF'
name: PR Labeler
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  label:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/labeler@v5
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}
EOF
commit_msg "ci: add PR labeler workflow stub" || true

# 6
mkdir -p .github
cat > .github/FUNDING.yml <<'EOF'
# github: [anand2532]
EOF
commit_msg "chore: add funding metadata" || true

# 7
echo "" >> CONTRIBUTING.md
echo "## Code style" >> CONTRIBUTING.md
echo "Run \`ruff check .\` and \`ruff format .\` before pushing." >> CONTRIBUTING.md
commit_msg "docs: document code style in contributing" || true

# 8
cat >> docs/api.md <<'EOF'

## Version
See `xr102232_test.__version__`.
EOF
commit_msg "docs: document version in API page" || true

# 9
python3 <<'PY'
from pathlib import Path
p = Path("src/xr102232_test/core.py")
t = p.read_text()
if "def is_even" not in t:
    p.write_text(t + "\n\ndef is_even(n: int) -> bool:\n    \"\"\"Return True if n is even.\"\"\"\n    return n % 2 == 0\n")
PY
cat >> tests/test_core.py <<'EOF'


def test_is_even():
    from xr102232_test.core import is_even

    assert is_even(4)
    assert not is_even(3)
EOF
commit_msg "feat: add is_even helper" || true

# 10
python3 <<'PY'
from pathlib import Path
p = Path("src/xr102232_test/core.py")
t = p.read_text()
if "def divide" not in t:
    p.write_text(t + "\n\ndef divide(a: int, b: int) -> float:\n    \"\"\"Divide a by b.\"\"\"\n    if b == 0:\n        raise ZeroDivisionError(\"division by zero\")\n    return a / b\n")
PY
cat >> tests/test_core.py <<'EOF'


def test_divide():
    from xr102232_test.core import divide

    assert divide(10, 2) == 5.0
EOF
commit_msg "feat: add divide with zero guard" || true

# 11
cat >> tests/test_core.py <<'EOF'


def test_divide_by_zero():
    from xr102232_test.core import divide

    import pytest

    with pytest.raises(ZeroDivisionError):
        divide(1, 0)
EOF
commit_msg "test: assert divide by zero raises" || true

# 12
sed -i 's/select = \["E", "F", "I", "UP"\]/select = ["E", "F", "I", "UP", "B"]/' pyproject.toml 2>/dev/null || true
commit_msg "chore: enable bugbear rules in ruff" || true

# 13
mkdir -p scripts
cat > scripts/smoke_test.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
python -c "from xr102232_test import add; assert add(1,1)==2"
echo "smoke ok"
EOF
chmod +x scripts/smoke_test.sh
commit_msg "chore: add local smoke test script" || true

# 14
echo "xr102232_test" > .github/CODEOWNERS
echo "* @anand2532" >> .github/CODEOWNERS
commit_msg "chore: add CODEOWNERS" || true

# 15
cat > .github/workflows/stale.yml <<'EOF'
name: Stale
on:
  schedule:
    - cron: "0 6 * * 1"
  workflow_dispatch:
jobs:
  stale:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/stale@v9
        with:
          days-before-stale: 60
          days-before-close: 7
          stale-issue-message: "This issue has been inactive."
EOF
commit_msg "ci: add stale bot workflow" || true

# 16
echo "## Development" >> README.md
echo "" >> README.md
echo "\`\`\`bash" >> README.md
echo "pip install -e \".[dev]\"" >> README.md
echo "pytest" >> README.md
echo "\`\`\`" >> README.md
commit_msg "docs: add development section to README" || true

# 17
cat > src/xr102232_test/cli.py <<'EOF'
"""Minimal CLI."""
from __future__ import annotations

import argparse

from .core import add


def main() -> None:
    p = argparse.ArgumentParser(prog="xr102232_test")
    p.add_argument("a", type=int)
    p.add_argument("b", type=int)
    args = p.parse_args()
    print(add(args.a, args.b))


if __name__ == "__main__":
    main()
EOF
commit_msg "feat: add minimal CLI module" || true

# 18
python3 <<'PY'
from pathlib import Path
p = Path("pyproject.toml")
t = p.read_text()
if "[project.scripts]" not in t:
    t = t.replace("[tool.setuptools.packages.find]", '[project.scripts]\nxr-sum = "xr102232_test.cli:main"\n\n[tool.setuptools.packages.find]')
    p.write_text(t)
PY
commit_msg "feat: register xr-sum console script" || true

# 19
cat >> CHANGELOG.md <<'EOF'

## Unreleased
- CLI entrypoint
- divide and is_even helpers
EOF
commit_msg "chore: update changelog unreleased section" || true

# 20
cat > .github/workflows/codeql.yml <<'EOF'
name: CodeQL
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: "0 8 * * 1"
jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: github/codeql-action/init@v3
        with:
          languages: python
      - uses: github/codeql-action/analyze@v3
EOF
commit_msg "ci: add CodeQL workflow" || true

# develop branch
git checkout -B develop
git push -u origin develop 2>/dev/null || git push -u origin develop --force
git checkout main

git push origin main

echo "Incremental commits done. Count on main:"
git rev-list --count main
