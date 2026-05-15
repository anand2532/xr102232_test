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


def is_even(n: int) -> bool:
    """Return True if n is even."""
    return n % 2 == 0
