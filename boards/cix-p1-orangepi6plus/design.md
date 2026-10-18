# Transfer to your device

Re-establish board revision, memory setup, PMIC rails, oscillator, boot storage and recovery access on a custom CD8180 design.
Shared silicon does not establish the same ACPI tables, connector wiring or firmware defaults.
Source connector orientation, contact numbers, logic voltage and voltage tolerance before connecting an adapter.
The DEBUG console routing result supplies none of those electrical limits.

Treat clock ownership, reset, power resources, DMA translation, cache synchronization and firmware readiness as separate obligations.
The CPU preparation fixture establishes no frame queues, throughput or codec application API.
Do not release exposed DMA owners without a qualified hardware teardown.

Provide independently recoverable firmware settings and a verified console path.
Distinguish orderly OS shutdown from rail removal and from the hardware wake path.
Cold SPCR retention and short-button restart need their own acceptance on the intended firmware and power design.

Use [the device-design worksheet](../../docs/device-design.md).
Sources: `os-cix-p1`, `os-cix-vpu`, `os-cix-platform` in [sources.json](../../sources.json).
