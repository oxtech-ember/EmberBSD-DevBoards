# Design transfer

Keep the 16 MB memory budget, flash map, recovery access and radio-library licensing explicit.
The cited kernel uses no floating-point instructions. Its RV32 userland uses the `ilp32` soft-float ABI; hardware ISA letters do not imply a compatible floating-point ABI.
The OS owner maintains compiler flags and runtime contracts.
A roughly 2 MB static application retained a TLS connection in the cited physical scenario; that does not qualify another application's memory or timing demands.

Source: `os-esp32-s31-reference` in [sources.json](../../sources.json).
