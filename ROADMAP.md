# Roadmap

Each stage ends with a gate: a concrete check that either passes or fails. Don't start the next stage until the gate passes, and write down what you learned in `docs/` before moving on.

This is also a first Rust project. Rust is learned one concept at a time, when a stage first needs it, rather than up front. Each stage lists the Rust concepts it introduces, and every gate includes being able to explain those concepts, not just the hardware.

## Stage 0: Setup

- Install Rust via `rustup` (not the distro `cargo` package), plus QEMU and a RISC-V capable GDB
- Push this scaffold to GitHub
- Study the compile → link → load pipeline (reading list below)
- Inspect real binaries: a small C `hello` and the firmware ELF, using `readelf -h`, `readelf -S`, `readelf -s` / `nm`, and `size`
- Write `docs/stage0.md` from scratch, in your own words

**Rust concepts:** `rustup` vs distro `cargo`, compilation targets, `rust-toolchain.toml`, `cargo check` vs `cargo build`

**Concepts to lock down before the gate:**

- Build time vs run time: build time only writes bytes into a file; anything that touches the target's RAM or registers is run time
- Who does each job: rustc (type checks), linker (symbol resolution, addresses), loader/kernel/QEMU (copying segments into RAM), `_start` (stack, `.bss` on bare metal)
- Execution begins at the ELF entry address (`_start`), not `main`; on Linux, `_start` comes from `crt1.o`
- `.bss` is `NOBITS`: the file stores only its size, so something must zero it at run time (the kernel on Linux, `_start` on bare metal)
- A "Finished" build is not a working binary: check `size` and `readelf -h` (an unreachable `main` gets discarded by the linker)

**Reading list:**

1. CS:APP (Bryant & O'Hallaron), Chapter 7 "Linking": symbol resolution, relocation, loading executables
2. *Writing an OS in Rust*, "A Freestanding Rust Binary" (os.phil-opp.com)
3. The Embedonomicon, "Memory layout" chapter (docs.rust-embedded.org/embedonomicon): read before writing `link.ld`, don't copy

**`docs/stage0.md` must answer:**

- Why `rustup` instead of apt's `cargo`: what did the apt version lack?
- `rust-toolchain.toml` (what to install) vs `.cargo/config.toml` (what to build for)
- The B/R table with who does each job, plus the rule used to decide
- What `cargo check` proves, what `cargo build` proves, and what neither proves (use real `size` output as evidence)
- Why `_start` exists and which jobs it takes over from the kernel on bare metal
- What `cargo check` reports on the empty crate, and what each error says the target is missing

**Gate:** `rustup target list --installed` shows `riscv32i-unknown-none-elf`, `qemu-system-riscv32 --version` prints a version, and `cargo check` has been run on the empty crate with its error explained in `docs/stage0.md`. `docs/stage0.md` is reviewed, and the Stage 0 knowledge check (warm-up quiz, predict-then-run, explain-it-out-loud; see CLAUDE.md) is passed.

## Stage 1: Boot to `main`

- Find the `virt` machine's RAM base address and where QEMU starts executing with `-bios none`
- Write `link.ld`: memory region, section placement (`.text`, `.rodata`, `.data`, `.bss`), stack top symbol
- Write `_start` in assembly: set the stack pointer, zero `.bss`, jump to `main`
- `main` spins in a loop

**Rust concepts:** `#![no_std]`, `#![no_main]`, `extern "C"`, `#[no_mangle]`, the `!` (never) type, `#[panic_handler]`, `global_asm!`, linker symbols as `extern` statics

**Gate:** `cargo check` and `cargo build` pass. Under GDB, execution reaches `main` and `.bss` is verified zeroed. You can explain why each step in `_start` must happen before any Rust code runs.

## Stage 2: UART output

- Find the address and register layout of `virt`'s UART (NS16550A compatible)
- Write a minimal driver using volatile MMIO reads and writes
- Print a string

**Rust concepts:** primitive integer types, raw pointers, `unsafe`, `core::ptr::read_volatile` / `write_volatile`, `const`

**Gate:** `cargo run` prints text to the terminal. You can explain why the accesses must be volatile and what the compiler might do otherwise.

## Stage 3: Formatting and panics

- Implement `core::fmt::Write` for the UART
- Panic handler prints the panic message and location, then halts

**Rust concepts:** traits (`core::fmt::Write`), `Result`, `write!` / `format_args!`, `&str`

**Gate:** A deliberate panic prints its file and line number.

## Stage 4: Traps and timer interrupts

- Set up `mtvec` and a trap handler in assembly that saves and restores registers
- Configure the CLINT timer to fire periodically
- Distinguish exceptions from interrupts using `mcause`

**Rust concepts:** `asm!` for CSR access, `static mut` and why it's dangerous, `enum` + `match` for decoding `mcause`

**Gate:** A tick counter prints on a fixed interval, and an illegal instruction is caught and reported instead of hanging.

## Stage 5: Self-reporting tests

- Write a small test harness that runs checks and reports pass/fail
- Use a memory-mapped status address to end the run with an exit code (on QEMU `virt`, find the test/finisher device)

**Rust concepts:** function pointers, arrays and slices, modules

**Gate:** `cargo run` exits with code 0 on pass and nonzero on fail, so a script can run it without a human watching.

## Stage 6: Cooperative scheduler

- Task control blocks, context switch in assembly, round-robin `yield`
- Two tasks sharing the UART

**Rust concepts:** structs, `#[repr(C)]` for a fixed TCB layout, pointers to structs

**Gate:** Two tasks interleave output correctly. You can walk through exactly which registers a context switch saves and why.

## Stage 7: Retarget to rv32i-core

- Match the core's memory map (reset vector, RAM size, MMIO status address)
- Swap the UART driver for whatever output the core provides
- Run the Stage 5 test suite on the core in Verilator

**Rust concepts:** `#[cfg(...)]` and Cargo features to switch between QEMU and rv32i-core builds

**Gate:** The same test binary passes on QEMU and on rv32i-core in simulation.