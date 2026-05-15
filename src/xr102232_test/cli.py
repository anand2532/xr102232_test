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
