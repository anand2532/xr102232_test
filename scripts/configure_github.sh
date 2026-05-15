#!/usr/bin/env bash
# Enable Discussions and configure GitHub Pages (requires: gh auth login)
set -euo pipefail

REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"

echo "Configuring $REPO ..."

# Enable Discussions
gh api -X PATCH "repos/$REPO" -f has_discussions=true || echo "Note: enable Discussions manually in Settings if API fails."

# Pages: deploy from gh-pages branch (MkDocs workflow creates it)
gh api -X POST "repos/$REPO/pages" \
  -f build_type=legacy \
  -f source[branch]=gh-pages \
  -f source[path]=/ 2>/dev/null || \
gh api -X PUT "repos/$REPO/pages" \
  -f build_type=legacy \
  -f source[branch]=gh-pages \
  -f source[path]=/ 2>/dev/null || \
echo "Note: set Pages source to gh-pages branch in Settings → Pages after first docs deploy."

# Optional: PyPI token (skip if not set)
if [ -n "${PYPI_API_TOKEN:-}" ]; then
  gh secret set PYPI_API_TOKEN --body "$PYPI_API_TOKEN"
  echo "Set PYPI_API_TOKEN secret."
else
  echo "Skip PYPI_API_TOKEN (export PYPI_API_TOKEN to set)."
fi

echo "Done. Verify: https://github.com/$REPO/settings/pages"
