from lib2to3.pgen2 import driver
from mimetypes import init
import cocotb

from cocotb.triggers import RisingEdge

from math import floor, log2, ceil, pi

import sys
from os import path

sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))

from lib.axi_driver import AxiDriver, generator_constant
from lib.init import initialize


def to_special_float(f):
    exponent = floor(log2(abs(f))) + 1
    mantissa = round(f / 2**exponent * 2**14) & 0x7FFF
    return (mantissa << 8) | (exponent & 0xFF)


def from_special_float(i):
    exponent = (i & 0x7F) - (i & 0x80)
    mantissa = (i >> 8) & 0x3FFF
    mantissa_sgn = -((i >> 8) & 0x4000)
    return (mantissa_sgn + mantissa) * 2 ** (exponent - 14)


@cocotb.test()
async def test_inverse_of_a_number(dut):
    driver = AxiDriver(
        clk=dut.clk, data=dut.d, valid=dut.in_valid, ready=dut.in_ready, valid_generator=generator_constant(0)
    )
    clk = RisingEdge(dut.clk)
    val = 2.99

    await initialize(dut)
    await driver.send(to_special_float(val))
    dut.out_ready.value = 1
    for _ in range(30):
        await clk
    print(log2(abs(from_special_float(dut.out.value) - 1 / val) * val))
