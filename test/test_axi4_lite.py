import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

@cocotb.test()
async def smoke_test(dut):

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Apply reset
    dut.rst_n.value = 0
    await Timer(50, units="ns")
    dut.rst_n.value = 1

    # Let a few cycles run
    for _ in range(5):
        await RisingEdge(dut.clk)
