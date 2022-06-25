from cocotb.triggers import Timer
from cocotb.clock import Clock
import cocotb
from cocotb.triggers import RisingEdge


async def initialize(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    dut.rstn.value = 1
    await Timer(2, units="ns")
    dut.rstn.value = 0
    await Timer(2, units="ns")
    dut.rstn.value = 1
    await Timer(2, units="ns")
    await RisingEdge(dut.clk)
