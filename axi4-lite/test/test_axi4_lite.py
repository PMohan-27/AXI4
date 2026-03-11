import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

async def axi_write_slave(dut, mem):

    dut.slave_write_done.value = 0
    dut.slave_bresp.value = 0

    while True:

        await RisingEdge(dut.send_slave_write)

        addr = int(dut.slave_waddr.value)
        data = int(dut.slave_wdata.value)

        mem[addr] = data

        latency = random.randint(1, 250)
        await ClockCycles(dut.clk, latency)

        dut.slave_bresp.value = 0
        dut.slave_write_done.value = 1

        await RisingEdge(dut.clk)

        dut.slave_write_done.value = 0


async def axi_read_slave(dut, mem):

    dut.slave_read_done.value = 0
    dut.slave_rresp.value = 0
    dut.slave_rdata.value = 0

    while True:

        await RisingEdge(dut.send_slave_read)

        addr = int(dut.slave_raddr.value)

        data = mem.get(addr, 0)

        latency = random.randint(1, 5)
        await ClockCycles(dut.clk, latency)

        dut.slave_rdata.value = data
        dut.slave_rresp.value = 0
        dut.slave_read_done.value = 1

        await RisingEdge(dut.clk)

        dut.slave_read_done.value = 0


async def write(dut, addr, data):

    dut.ctrl_waddr.value = addr
    dut.ctrl_wdata.value = data
    dut.ctrl_wstrb.value = 0xF

    dut.ctrl_write_req.value = 1
    await RisingEdge(dut.clk)

    dut.ctrl_write_req.value = 0

    await RisingEdge(dut.ctrl_write_done)


async def read(dut, addr):

    dut.ctrl_raddr.value = addr
    dut.ctrl_read_req.value = 1

    await RisingEdge(dut.clk)

    dut.ctrl_read_req.value = 0

    await RisingEdge(dut.ctrl_read_done)

    return int(dut.ctrl_rdata.value)


@cocotb.test()
async def axi_lite_test(dut):

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    dut.rst_n.value = 0
    dut.ctrl_write_req.value = 0
    dut.ctrl_read_req.value = 0

    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 5)

    mem = {}

    cocotb.start_soon(axi_write_slave(dut, mem))
    cocotb.start_soon(axi_read_slave(dut, mem))

    await write(dut, 0x10, 0xDEADBEEF)
    await write(dut, 0x20, 0xCAFEBABE)

    r0 = await read(dut, 0x10)
    r1 = await read(dut, 0x20)

    assert r0 == 0xDEADBEEF
    assert r1 == 0xCAFEBABE

    for _ in range(10):

        addr = random.randrange(0, 64, 4)
        data = random.getrandbits(32)

        await write(dut, addr, data)

        r = await read(dut, addr)

        assert r == data

    await ClockCycles(dut.clk, 20)