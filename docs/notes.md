# Signetics 2650 Ghidra Processor Module Notes

This file will collect insights, references, and findings during the process of adding Signetics 2650 support to Ghidra.

## Key Documentation
- Signetics 2650 Manual (2650UM.guide)
- Wikipedia: https://en.wikipedia.org/wiki/Signetics_2650
- Archive.org: https://archive.org/search.php?query=signetics%202650

## Insights
- Absolute branch/call families now decode the full 15-bit destination from the
  encoded page bits plus low-13 address and update `page_latch` when the branch
  is taken.
- Direct absolute data accesses are modeled as page-local to the executing
  instruction (`inst_start` page bits + encoded low 13 bits). This gives
  concrete disassembly labels and decompiler constants for non-indirect forms.
- Absolute indirect data accesses fetch the pointer from the current page, then
  dereference the full 15-bit pointer value. This is the current practical
  analysis model for indirect paging semantics.
- The language remains `BE:16` intentionally: the 2650 is an 8-bit CPU, but
  Ghidra's language size is the address width, and the manual describes
  indirect addresses as 15-bit values stored right-justified in two contiguous
  memory bytes, which matches the current big-endian 16-bit pointer handling.
- Register operands `r1` through `r3` are now resolved through the PSL `RS`
  bit so semantics and decompilation select bank 0 (`r1`-`r3`) or bank 1
  (`r1p`-`r3p`) correctly while preserving the original assembly syntax.
- 2650B-only status instructions and disassembly should remain out of the
  default 2650 definition. If that variant is added later, it should be a
  separate processor/language definition rather than extending the base 2650
  spec in-place.
- A synthetic 32 KB paging test ROM now exists at `tests/paging_test.bin`.
- The paging test harness now lives entirely under `tests/`:
  `tests/paging_test.2650` is the assembly source and
  `tests/build_tests.sh` rebuilds every `tests/*.2650` source with `asm2650`.
- The synthetic ROM places one routine at the top of each 8 KB page and exercises direct absolute load/store within page.
- The synthetic ROM also exercises indirect absolute load/store through page-local pointer tables.
- The synthetic ROM also exercises relative branch within page.
- The synthetic ROM also exercises absolute branch to the next page, with the last page looping back to page 0.
- Validation results from the synthetic ROM:
  disassembly shows page-qualified labels for direct and indirect absolute
  accesses in every page.
- With volatile memory enabled, decompilation shows concrete page-local accesses such as `DAT_ram_2100`, `DAT_ram_4300`, and dereferenced pointer copies across all four pages.
- Deferred non-goal: hardware-accurate transient latch override/restore for
  non-branch indirect accesses is intentionally not modeled. Ghidra is aimed at
  static analysis rather than fine-grained bus-timing reconstruction, and the
  current practical 15-bit dereference model gives good disassembly,
  decompilation, and CFG recovery.
