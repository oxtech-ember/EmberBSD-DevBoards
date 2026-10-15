# Boot and recovery

The recorded EmberBSD path uses module firmware, UEFI, ACPI and an ELF kernel on the root filesystem.
The documented boot entry loads `/netbsd`. A native firmware image and an ELF kernel are different artifacts.
Keep the kernel and board modules from the same build.

| Stage | Design dependency | Diagnostic boundary |
|---|---|---|
| Module boot firmware | Module variant, boot storage and boot configuration | Read firmware identity; do not infer it from a later OS log |
| UEFI | Firmware build and carrier description | Check selected boot entry and console route |
| EmberBSD loader/kernel | Root device, ELF image and ACPI interfaces | Record kernel hash and matching modules |
| Userland | Root filesystem, services and firmware files | Prove the required device operation separately |

For inaccessible eMMC, the module supports USB boot with a RAM recovery environment.
See the [reference USB recovery profile](configs/usb-recovery/README.md).
Recovery access does not prove that EmberBSD boots or that the root filesystem is healthy.
The carrier owns the BOOT control and USB wiring; read its control map first.
Sources: `os-cm5`, `cm5-datasheet`, `usbboot-guide` in [sources.json](../../sources.json).
