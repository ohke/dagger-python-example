from dagger_python_example import __version__
from dagger_python_example.main import dot
import numpy as np


def test_version():
    assert __version__ == "0.1.0"


def test_dot():
    assert dot(np.array([1, 2, 3]), np.array([1, 2, 3])) == 14
