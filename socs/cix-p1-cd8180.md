# CIX P1/CD8180 research entry

Start with the [Orange Pi 6 Plus profile](../boards/cix-p1-orangepi6plus/README.md).
The cited firmware identifies the video-codec ACPI device as `CIXH3010`.
The native diagnostic reads ID `0x56648002`, four cores and four slots on the observed platform.
These observations do not define connector wiring, electrical limits or every CD8180 firmware configuration.

The [ACPI attachment](https://github.com/oxtech-ember/EmberBSD/blob/75f0decfa1a02288f1bca8520b96811f9d5567a6/sys/dev/acpi/cixvpu_acpi.c),
[VPU contract](https://github.com/oxtech-ember/EmberBSD/blob/75f0decfa1a02288f1bca8520b96811f9d5567a6/ember/boot/cix-vpu.md) and
[clock/reset providers](https://github.com/oxtech-ember/EmberBSD/blob/75f0decfa1a02288f1bca8520b96811f9d5567a6/ember/boot/cix-platform.md) remain owned by EmberBSD.
Clock ID67, resource validation, CPU preparation and a complete codec are separate evidence levels.
A bounded firmware bootstrap reaches SWITCHED_IN and PONG and retains exposed DMA owners with IRQ masked.
See the current [board boundary](../boards/cix-p1-orangepi6plus/interfaces.md#vpu-resources-and-acceptance); no codec frame is accepted.
No production video interface is established by this record.

Sources: `os-cix-vpu-attachment`, `os-cix-vpu`, `os-cix-platform`, `os-cix-p1-reference` in [sources.json](../sources.json).
