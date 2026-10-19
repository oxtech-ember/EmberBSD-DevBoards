# Boot and recovery

The recorded chain is module boot firmware → UEFI → EmberBSD `efiboot` → ELF `/netbsd` on the root filesystem.
The kernel uses ACPI for this path.
Read the shared [UEFI console policy](../../bootloaders/rpi5-uefi-console.md) when selecting serial and HDMI output.
Follow the shared [efiboot artifact contract](../../bootloaders/efiboot.md) for kernel format, selected entry and matching modules.

| Stage | Design dependency | Diagnostic boundary |
|---|---|---|
| Module boot firmware | Module variant, boot storage and boot configuration | Read firmware identity; do not infer it from a later OS log |
| UEFI | Firmware build and carrier description | Check selected boot entry and console route |
| EmberBSD loader/kernel | Root device, ELF image and ACPI interfaces | Record kernel hash and matching modules |
| Userland | Root filesystem, services and firmware files | Prove the required device operation separately |

## USB recovery access

For inaccessible eMMC, the module supports USB boot with a RAM recovery environment.
See the [reference USB recovery profile](configs/usb-recovery/README.md).
Recovery access does not prove that EmberBSD boots or that the root filesystem is healthy.
The carrier owns the BOOT control and USB wiring; read its control map first.
Sources: `os-cm5`, `cm5-datasheet`, `usbboot-guide` in [sources.json](../../sources.json).
