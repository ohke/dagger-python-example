import numpy as np


def dot(a, b):
    return a.dot(b)


if __name__ == "__main__":
    print(dot(np.array([1, 2, 3]), np.array([1, 2, 3])))
