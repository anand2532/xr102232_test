# GitHub setup (one-time)

## Enable Actions to open/merge PRs (required for YOLO + PR workflows)

1. Open **Settings → Actions → General**
2. Under **Workflow permissions**, choose **Read and write permissions**
3. Enable **Allow GitHub Actions to create and approve pull requests**
4. Re-run workflow: **Actions → Achievement activity → Run workflow**

Or locally (after `gh auth login`):

```bash
./scripts/local_achievements.sh
```

## Discussions

**Settings → General → Features → Discussions** (or run **Setup repository features** workflow)

## Pages

After **Docs (MkDocs)** succeeds, set **Settings → Pages → Deploy from branch `gh-pages`**.

## PyPI (optional)

```bash
export PYPI_API_TOKEN=pypi-...
gh secret set PYPI_API_TOKEN --body "$PYPI_API_TOKEN"
```
