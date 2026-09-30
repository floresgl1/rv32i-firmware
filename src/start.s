# start.s: reset entry point. Runs before any Rust code.
#
# Stage 1 TODO (write this yourself):
#   - Define and export _start, placed in its own section so link.ld can put it first
#   - Set sp to the stack top exported by link.ld
#   - Zero .bss (loop from bss start to bss end)
#   - Jump to main; if main ever returns, park the hart in a loop
#
# Constraint: RV32I only. No M, A, or C instructions.
