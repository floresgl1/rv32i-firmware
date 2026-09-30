//! rv32i-firmware: bare-metal entry point.

// No standard library: there is no OS underneath us.
#![no_std]
// No normal `main` signature: our own `_start` (src/start.s) sets up the
// machine and then calls the `main` function below.
#![no_main]

use core::panic::PanicInfo;

// Pull the hand-written startup assembly into the build.
core::arch::global_asm!(include_str!("start.s"));

/// Called from `_start` once the stack and .bss are ready.
/// Stage 1 question: why must this use the C ABI and an unmangled name?
#[no_mangle]
pub extern "C" fn main() -> ! {
    loop {}
}

/// Required in `no_std`: what to do when code panics.
/// Stage 3 TODO: print the message and location over the UART.
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
