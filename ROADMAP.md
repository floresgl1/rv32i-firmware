# Roadmap

Each stage ends with a gate: a concrete check that either passes or fails. Don't start the next stage until the gate passes, and write down what you learned in `docs/` before moving on.

## Stage 0: Setup

- Install the Rust target, QEMU, and a RISC-V capable GDB
- Push this scaffold to GitHub

**Gate:** `rustup target list --installed` shows `riscv32i-unknown-none-elf`, and `qemu-system-riscv32 --version` prints a version.

## Stage 1: Boot to `main`

- Find the `virt` machine's RAM base address and where QEMU starts executing with `-bios none`
- Write `link.ld`: memory region, section placement (`.text`, `.rodata`, `.data`, `.bss`), stack top symbol
- Write `_start` in assembly: set the stack pointer, zero `.bss`, jump to `main`
- `main` spins in a loop

**Gate:** Under GDB, execution reaches `main` and `.bss` is verified zeroed. You can explain why each step in `_start` must happen before any Rust code runs.

## Stage 2: UART output

- Find the address and register layout of `virt`'s UART (NS16550A compatible)
- Write a minimal driver using volatile MMIO reads and writes
- Print a string

**Gate:** `cargo run` prints text to the terminal. You can explain why the accesses must be volatile and what the compiler might do otherwise.

## Stage 3: Formatting and panics

- Implement `core::fmt::Write` for the UART
- Panic handler prints the panic message and location, then halts

**Gate:** A deliberate panic prints its file and line number.

## Stage 4: Traps and timer interrupts

- Set up `mtvec` and a trap handler in assembly that saves and restores registers
- Configure the CLINT timer to fire periodically
- Distinguish exceptions from interrupts using `mcause`

**Gate:** A tick counter prints on a fixed interval, and an illegal instruction is caught and reported instead of hanging.

## Stage 5: Self-reporting tests

- Write a small test harness that runs checks and reports pass/fail
- Use a memory-mapped status address to end the run with an exit code (on QEMU `virt`, find the test/finisher device)

**Gate:** `cargo run` exits with code 0 on pass and nonzero on fail, so a script can run it without a human watching.

## Stage 6: Cooperative scheduler

- Task control blocks, context switch in assembly, round-robin `yield`
- Two tasks sharing the UART

**Gate:** Two tasks interleave output correctly. You can walk through exactly which registers a context switch saves and why.

## Stage 7: Retarget to rv32i-core

- Match the core's memory map (reset vector, RAM size, MMIO status address)
- Swap the UART driver for whatever output the core provides
- Run the Stage 5 test suite on the core in Verilator

**Gate:** The same test binary passes on QEMU and on rv32i-core in simulation.
