# Transfer to another tablet or device

The cable evidence applies to one unopened YS-M33 factory sample with Allwinner A133. A separate reference sample supplies peripheral checks.
It does not establish compatibility with another YS-M33 revision or another A133 board.

Before adapting this path, identify the exact board, panel, vendor image, eMMC layout, USB role and signed recovery behavior.
Validate root access and preserve a complete per-device backup before any unlock or write.
Keep vendor boot components, environment, device credentials and recovery data specific to each tablet.

Do not transfer the tested eMMC offsets, boot environment, Android build assumptions or credentials to a custom device.
The vendor boot chain, memory initialization, panel handoff, external MCU and power behavior need separate evidence.
See the [common design worksheet](../../docs/device-design.md) and the [boot and installation boundaries](boot.md).
