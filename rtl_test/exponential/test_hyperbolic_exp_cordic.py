from curses.ascii import RS
import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb_bus.drivers import Driver

from cocotb.triggers import RisingEdge

from math import exp, atanh


class AxiDriver(Driver):
    def __init__(self, clk, data, valid, ready, valid_generator):
        super().__init__()
        self.clk = clk
        self.data = data
        self.valid = valid
        self.ready = ready
        self.valid_generator = valid_generator

    async def _driver_send(self, transaction, sync=True, **kwargs):
        clock = RisingEdge(self.clk)

        await clock
        self.valid.value = 1
        self.data.value = transaction

        await clock
        while not self.ready.value:
            await clock

        self.valid.value = 0
        for _ in range(next(self.valid_generator)):
            await clock


async def initialize(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    dut.rstn.value = 1
    await Timer(10, units="ns")
    dut.rstn.value = 0
    await Timer(10, units="ns")
    dut.rstn.value = 1
    await Timer(10, units="ns")
    await RisingEdge(dut.clk)


def generator_constant(c):
    while True:
        yield c


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
    val = -1.1

    await initialize(dut)
    await driver.send(to_2s_comp(val))
    dut.out_ready.value = 1

    for _ in range(30):
        await clk

    calc = from_2s_comp(dut.w.value)
    print(abs(exp(val) - calc), to_2s_comp(val))
