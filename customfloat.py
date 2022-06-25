from math import log2, floor


class LimitedInt:
    def __init__(self, val: int, size: int) -> None:
        self.v = val
        self.resize(size)

    def resize(self, size):
        self.mask: int = (1 << size) - 1
        self.size = size
        self.v: int = self.v & self.mask

    def __add__(self, other):
        return LimitedInt(self.v + other.v, max(self.size, other.size) + 1)

    def __mul__(self, other):
        return LimitedInt(self.v * other.v, self.size + other.size)

    def __str__(self) -> str:
        return str(self.v)


class CustomFloat:
    def __init__(self, v: float, mantissa_size: int, exp_size: int) -> None:
        self.exp = LimitedInt(floor(log2(v) + 1), exp_size)
        self.mantissa = LimitedInt(int(v / 2**self.exp.v * 2**mantissa_size), mantissa_size)

    def __str__(self) -> str:
        return f"{self.mantissa.v * 2**(-self.mantissa.size)}*2**{self.exp.v}"

    def __add__(self, other):
        return CustomFloat(self.mantissa.v + (other.mantisa.v << (other.exp.v - self.exp.v)), self.exp.size)

    def as_float(self):
        return self.mantissa.v * 2 ** (-self.mantissa.size) * 2**self.exp.v


if __name__ == "__main__":
    f1 = CustomFloat(100, 16, 6)
    f2 = CustomFloat(64, 16, 6)
    f3 = CustomFloat(63.9, 16, 6)
    print(f1.as_float())
    print(f2.as_float())
    print(f3.as_float())
    print((f1 + f2).as_float())
