"""Pruebas básicas del paquete: que se instale e importe correctamente."""

import importlib

import pytest

import darwin


def test_version_is_defined():
    assert darwin.__version__ == "0.1.0.dev0"


@pytest.mark.parametrize(
    "subpackage", ["algorithms", "simulation", "circuits", "problem", "results"]
)
def test_subpackage_imports(subpackage):
    importlib.import_module(f"darwin.{subpackage}")
