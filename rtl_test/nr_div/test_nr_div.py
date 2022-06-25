import cocotb, random
import matplotlib.pyplot as plt

from cocotb.triggers import RisingEdge

from math import floor, log2

import sys
from os import path
import numpy as np


sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))

from lib.axi_driver import AxiDriver, generator_constant
from lib.init import initialize


MANTISSA_W = 16
EXP_W = 8


def mask(i):
    return (1 << i) - 1


def s_mask(i):
    return 1 << (i - 1)


def to_special_float(f):
    exponent = floor(log2(abs(f))) + 1
    mantissa = floor(f / 2**exponent * 2 ** (MANTISSA_W - 1)) & mask(MANTISSA_W)
    return (mantissa << EXP_W) | (exponent & mask(EXP_W))


def from_special_float(i):
    exponent = (i & mask(EXP_W - 1)) - (i & s_mask(EXP_W))
    mantissa = (i >> EXP_W) & mask(MANTISSA_W - 1)
    mantissa_sgn = -((i >> EXP_W) & s_mask(MANTISSA_W))
    return (mantissa_sgn + mantissa) * 2 ** (exponent - MANTISSA_W + 1)


@cocotb.test()
async def test_inverse_of_a_lots_of_random(dut):
    driver = AxiDriver(
        clk=dut.clk, data=dut.d, valid=dut.in_valid, ready=dut.in_ready, valid_generator=generator_constant(0)
    )
    vals = [random.random() for _ in range(10000)]
    res = []
    await initialize(dut)
    dut.out_ready.value = 1
    for val in vals:
        to_send = to_special_float(val)
        await driver.send(to_send)
        while not dut.out_valid.value:
            await RisingEdge(dut.clk)

        res.append((from_special_float(dut.out.value), dut.out.value, val, to_send))

    log_error = [np.log2((abs(r[0] - 1 / r[2]) * r[2])) for r in res]
    for err in log_error:
        assert err < -13
    plt.hist(log_error, 50)
    plt.xlim(-20, -12)
    plt.savefig("foo.png")


@cocotb.test()
async def test_inverse_of_a_number(dut):
    driver = AxiDriver(
        clk=dut.clk, data=dut.d, valid=dut.in_valid, ready=dut.in_ready, valid_generator=generator_constant(0)
    )
    clk = RisingEdge(dut.clk)
    val = 0.4

    await initialize(dut)
    await driver.send(to_special_float(val))
    dut.out_ready.value = 1

    for _ in range(30):
        await clk
    err_log = np.log2(abs(from_special_float(dut.out.value) - 1 / val) * val)
    assert (
        err_log < -13
    ), f"should be less than -13 log2 relative error 1/{val}={1/val} !~= {from_special_float(dut.out.value)}"
