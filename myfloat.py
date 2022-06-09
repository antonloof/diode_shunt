from math import log2, floor


class LimitedInt:
    def __init__(self, val: int, size: int) -> None:
        self.mask: int = (1 << size) - 1
        self.v: int = val & self.mask
        self.size: int = size

    def __add__(self, other):
        return LimitedInt(self.v + other.v, self.size)

    def __str__(self) -> str:
        return str(self.v)


class MyFloat:
    def __init__(self, v: float, mantissa_size: int, exp_size: int) -> None:
        self.exp = LimitedInt(floor(log2(v)) + 1, exp_size)
        self.mantissa = LimitedInt(int(v / 2 ** self.exp.v * 2 ** mantissa_size), mantissa_size)

    def __str__(self) -> str:
        return f"{self.mantissa.v * 2**(-self.mantissa.size)}*2**{self.exp.v}"


print(MyFloat(100, 16, 6))
