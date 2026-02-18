import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def test(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.rst_n.value = 0
    dut.ctrl_write_req.value = 0
    dut.ctrl_addr.value = 0
    dut.ctrl_wdata.value = 0

    for _ in range(3):
        await RisingEdge(dut.clk)

    dut.rst_n.value = 1
    for _ in range(3):
        await RisingEdge(dut.clk)

    # Drive a "write"
    dut.ctrl_addr.value = 0x10
    dut.ctrl_wdata.value = 0xDEADBEEF
    dut.ctrl_write_req.value = 1

    await RisingEdge(dut.clk)
    dut.ctrl_write_req.value = 0
    
    # await RisingEdge(dut.clk)
    # dut.ctrl_write_req.value = 1
    # await RisingEdge(dut.clk)

    # dut.ctrl_write_req.value = 0
    for _ in range(30):
        await RisingEdge(dut.clk)
