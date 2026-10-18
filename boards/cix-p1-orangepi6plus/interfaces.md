# Selected interface contracts

| Interface | Reusable description | Boundary |
|---|---|---|
| DEBUG console | UART2; stock SPCR routes to UART3 | Exact-table RAM correction; electrical pin map unknown |
| VPU ACPI | `CIXH3010`, two 64 KiB fixed memory windows, GSI 358, `_CCA=0` on the observed firmware | Running descriptions must be validated; do not hardcode another board's addresses |
| VPU clock and identity | Clock ID67 is the VPU APB gate; the native diagnostic reads four cores and four slots | Clock exchange and identity do not establish a usable codec or measured clock waveform |
| VPU CPU preparation | The selected one-core firmware-layout fixture uses 256 unique backing owners | Allocation, zero audit, image copy and CPU page tables are distinct from device DMA and firmware readiness |
| Power button | Native ACPI event delivery and orderly filesystem shutdown have a bounded observation | Short-button power-on after shutdown remains unresolved; hardware power ownership is separate |

`_CCA=0` requires the native noncoherent DMA contract; identity is not a cache-coherence test.
The four-core identity does not turn the one-core preparation fixture into four-core runtime acceptance.
A firmware boot diagnostic reached address publication and an IRQ observation, then stopped before SWITCHED_IN/PONG.
On that terminal path, the driver retains exposed pages and claims and masks the IRQ. A codec workflow is not established.
Do not infer the exact firmware request from its ENOTSUP receive error.

The [VPU owner](https://github.com/oxtech-ember/EmberBSD/blob/75f0decfa1a02288f1bca8520b96811f9d5567a6/ember/boot/cix-vpu.md) owns resources, DMA lifetime, firmware and interrupt handling.
The [platform owner](https://github.com/oxtech-ember/EmberBSD/blob/75f0decfa1a02288f1bca8520b96811f9d5567a6/ember/boot/cix-platform.md) owns clock/reset diagnostics and their prerequisites.
Firmware must be supplied locally under its applicable terms; this profile grants no redistribution rights.

This selection does not establish camera capture, general GPIO/PPS, UART1/UART3 operation, NPU or GPU support.
Physical header contacts, pinmux, voltage limits and peripheral wiring need primary board documentation.
Sources: `os-cix-p1`, `os-cix-vpu`, `os-cix-platform` in [sources.json](../../sources.json).
