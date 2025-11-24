# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import Timer, RisingEdge

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 100, units="us")
    cocotb.start_soon(clock.start())

    # --- Reset top ---
    dut.rst_n.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    # --- Instruction list ---
    # (30 - 10) << 2 = 80
    instr_list = [
        0x00a00093, # addi x1,x0,10
        0x00200113, # addi x2,x0,2
        0x01e00193, # addi x3,x0,30
        0x401181b3, # sub  x3,x3,x1
        0x002191b3  # sll  x3,x3,x2
    ]

    # --- Reset CPU ---
    dut.uio_in.value = 0b00
    for i in range(4):
        await RisingEdge(dut.clk)
    dut.uio_in.value = 0b01

    # --- Write instructions to IMEM ---
    dut.uio_in.value = 0b11
    for insn in instr_list:
        for i in range(4):
            # 32bit -> 8bit slices
            dut.ui_in.value = (insn >> (i*8)) & 0xFF
            await RisingEdge(dut.clk)
    dut.uio_in.value = 0b01

    # --- Reset PC ---
    dut.uio_in.value = 0b00
    for i in range(4):
        await RisingEdge(dut.clk)
    dut.uio_in.value = 0b01

    # --- Execute instructions ---
    for insn in instr_list:
        print("#### insn ####")
        out = 0
        for i in range(4):
            await RisingEdge(dut.clk)
            await Timer(10, units="us")
            out |= dut.uo_out.value.integer << (i * 8)
        print(out)

    # --- Debug output ---
    dut._log.info("CPU test completed.")
