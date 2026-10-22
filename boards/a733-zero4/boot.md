# Boot and recovery

Vendor boot0 and U-Boot supply a device tree and boot the microSD root to multi-user.
Follow the shared [native AArch64 image contract](../../bootloaders/u-boot-native-image.md) for loader and artifact applicability.
Eight cores and serial console are recorded. Card signalling uses 1.8 V SDR104 at 150 MHz.
The recorded sequential read rate is 59 MB/s; no tuning was performed and sample delay stayed zero.
A reboot from that state worked. Preserve the exact memory and board firmware inputs.
The related Zero 3W uses a board-specific tree with Ethernet disabled; do not exchange their descriptions blindly.
No physical power button is populated in the source record; the PMIC power-key pads were not exercised.
Power-off uses PSCI. Exact connector and recovery-control wiring remain unspecified.

Source: `os-zero4-reference` in [sources.json](../../sources.json).
