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

## Power-button contacts: PCB V1.1

Source: `vendor-cix-opi6plus-v11-schematic` in [sources.json](../../sources.json).
The [vendor support page](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-6-Plus.html) links `OPi 6 PLUS V11 DSN 0612.pdf`.
The recorded SHA256 identifies the PDF served by the official preview, not the original download bytes.
This record describes schematic revision 1.1. It does not identify another physical board revision.

Sheet 48 of 66, `RESET/BUTTON/LEDS`, defines the POWER switch `SW0`, part `TS-026-3`:

| Switch contact | Circuit | External dry-contact relay |
|---|---|---|
| SW0 pin 1 | R927, 10 ohm, then `PWRBTN_L_HW` | Normally open contact, NO |
| SW0 pin 2 or 3 | GND; both connect to ground in this schematic | Common contact, COM |

R925 pulls `PWRBTN_L_HW` to `+3.3V_LDO` through 1 kohm. C612 is 0.1 microfarad to ground.
Sheet 46 routes this active-low signal to the IT5570 EC input `PWRSW/GPB3`.
The 40-pin connector on sheet 44 has no named `PWRBTN_L_HW` contact.
The source shows the button route on sheets 46 and 48, without a dedicated external POWER header.
These are switch package pin numbers. They are not 40-pin or debug-header pin numbers.

Use an isolated, normally open dry contact across SW0 pin 1 and pin 2 or 3.
Do not feed relay-module VCC, UART TX, DTR or RTS into the switch circuit.
With power and backfeeding cables disconnected, verify the PCB revision and locate SW0 by continuity to R927 and GND.
Do not infer the pad orientation from this schematic or from a different switch footprint.
Verify that the physical button shorts the selected pair only while pressed.
Attach insulated wires across the button only after these checks.
Start with a bounded short pulse, such as 0.2 seconds, then verify release and the resulting board state.
That pulse duration is a test starting point, not a vendor timing specification.

A dry contact emulates the physical button. It does not guarantee recovery from a failed S5 wake path.
Provide independently controlled input power when a complete cold reset is required.
No relay installation, electrical measurement or remote power cycle was performed for this source review.
