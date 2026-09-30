/* link.ld: memory map and section placement for QEMU virt.
 *
 * Stage 1 TODO (write these yourself):
 *   1. ENTRY(...)  - which symbol does execution start at?
 *   2. MEMORY { }  - where is RAM on `virt`, and how big? (look it up; don't guess)
 *   3. SECTIONS { } - place .text first (why first?), then .rodata, .data, .bss
 *   4. Export symbols _start needs: start/end of .bss, and a stack top
 *
 * Questions to answer in docs/ before moving on:
 *   - With `-bios none`, what address does QEMU jump to?
 *   - Why does .bss take no space in the ELF file but does take space in RAM?
 */
