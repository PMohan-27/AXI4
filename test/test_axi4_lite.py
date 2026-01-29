import cocotb


@cocotb.test()
async def test_axi(dut):
    cocotb.log.info("hello cocotb")