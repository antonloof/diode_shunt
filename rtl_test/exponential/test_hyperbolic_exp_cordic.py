import cocotb

from cocotb.triggers import RisingEdge

from math import exp

import sys
from os import path

sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))

from lib.axi_driver import AxiDriver, generator_constant
from lib.init import initialize


def to_2s_comp(f):
    return round(f * 2**14) & 0xFFFF


def from_2s_comp(i):
    return (-(i & 0x8000) + (i & 0x7FFF)) / 2**14


@cocotb.test()
async def test_an_exponential(dut):
    driver = AxiDriver(
        clk=dut.clk, data=dut.z0, valid=dut.in_valid, ready=dut.in_ready, valid_generator=generator_constant(0)
    )
    clk = RisingEdge(dut.clk)
    val = 0.3

    await initialize(dut)
    await driver.send(to_2s_comp(val))
    dut.out_ready.value = 1

    for _ in range(30):
        await clk

    calc = from_2s_comp(dut.w.value)
    assert abs(exp(val) - calc) < 1e-4, f"Result not within 1e-4. e^{val}!~={calc}"
