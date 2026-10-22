# Transfer to another tablet or device

The evidence applies to one YS-M33 factory sample with Allwinner A133.
It does not establish compatibility with another YS-M33 revision or another A133 board.

Before adapting this path, identify the exact board, panel, vendor image, eMMC layout, USB role and signed recovery behavior.
Validate root access and preserve a complete per-device backup before any unlock or write.
Keep vendor boot components, environment, device credentials and recovery data specific to each tablet.

Do not transfer the tested eMMC offsets, boot environment, Android build assumptions or credentials to a custom device.
The vendor boot chain, memory initialization, panel handoff, external MCU and power behavior need separate evidence.
See the [common design worksheet](../../docs/device-design.md) and the current [EmberBSD installation boundaries](https://github.com/oxtech-ember/EmberBSD/blob/12c35f22fd899b4d697e20986521226efaf6d8cb/ember/boards/ys-m33-a133-cable-install.md).
