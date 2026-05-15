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


def test_subtract_negative():
    assert subtract(0, 5) == -5
