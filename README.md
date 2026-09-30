# rv32i-firmware

Bare-metal Rust firmware for RISC-V RV32I, written from scratch with no runtime crates. It is developed first on QEMU's `virt` machine, then retargeted to run on my own CPU core, [rv32i-core](https://github.com/floresgl1/rv32i-core).

The two repos are meant to meet in the middle: the core implements RV32I in SystemVerilog, and this firmware is built for exactly that instruction set (`riscv32i-unknown-none-elf`, no M/A/C extensions) so the same binary can run on both.

## Current status

**Stage 0: Setup.** Toolchain and project structure in place. No firmware logic yet. See [ROADMAP.md](ROADMAP.md) for the full plan and pass/fail gates.

## Design choices

| Choice | Decision | Why |
|---|---|---|
| Target | `riscv32i-unknown-none-elf` | Matches rv32i-core exactly; no retargeting needed later |
| Emulator | QEMU `virt` | Simple, well-documented memory map and UART |
| Startup | Hand-written `_start` and linker script | Understand every step from reset to `main` |
| Dependencies | `core` only | No `riscv-rt`, no HAL crates; every register access is written by hand |

## Toolchain

All free and open-source:

- Rust (stable) with the `riscv32i-unknown-none-elf` target
- QEMU (`qemu-system-riscv32`)
- GDB with RISC-V support (`gdb-multiarch` or `riscv64-unknown-elf-gdb`)
- `cargo-binutils` (optional, for `objdump` / `size` on the ELF)

### Setup

```sh
rustup target add riscv32i-unknown-none-elf
# Ubuntu/Debian
sudo apt install qemu-system-misc gdb-multiarch
```

### Build and run

```sh
cargo check    # type-checks now (Stage 0)
cargo build    # links once Stage 1 (link.ld + _start) is written
cargo run      # launches QEMU via the runner in .cargo/config.toml
```

Exit QEMU with `Ctrl-A` then `X`.

## Repository layout

```
rv32i-firmware/
├── src/          # Firmware source (Rust + startup assembly)
├── link.ld       # Linker script: memory map and section placement
├── .cargo/       # Build target and QEMU runner config
├── docs/         # Notes, diagrams, blog drafts
├── scripts/      # Helper scripts (debug, test runs)
├── CLAUDE.md     # Learning contract for AI-assisted work
├── ROADMAP.md    # Stage-by-stage plan with pass/fail gates
└── LICENSE       # MIT
```

## License

MIT
