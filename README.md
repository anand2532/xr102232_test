# xr102232_test

A small Python package scaffolded as a realistic engineering project: CI, tests, release automation, and documentation.

## Badges
[![CI](https://github.com/anand2532/xr102232_test/actions/workflows/ci.yml/badge.svg)](https://github.com/anand2532/xr102232_test/actions/workflows/ci.yml)
[![Docs](https://github.com/anand2532/xr102232_test/actions/workflows/pages.yml/badge.svg)](https://github.com/anand2532/xr102232_test/actions/workflows/pages.yml)

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
## Development

```bash
pip install -e ".[dev]"
pytest
```

<!-- pr branch -->
