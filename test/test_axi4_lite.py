import cocotb
from cocotb.clock import Clock, Timer
from cocotb.triggers import RisingEdge

@cocotb.test()
async def test_axi(dut):
    cocotb.log.info("hello cocotb")

    clock = Clock(dut.ACLK, 10, unit='ns')
    cocotb.start_soon(clock.start())
    dut.ARESETn.value = 1
    await Timer(1,unit='ns')
    dut.ARESETn.value = 0
    await RisingEdge(dut.ACLK)
    dut.ARESETn.value = 1

    for i in range(10):
        await RisingEdge(dut.ACLK)
