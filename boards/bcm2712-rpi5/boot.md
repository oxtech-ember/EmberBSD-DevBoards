# Boot and recovery

The recorded chain is board boot firmware → UEFI → EmberBSD `efiboot` → ELF `/netbsd` on the microSD root partition.
The kernel uses ACPI for this path.
Read the shared [UEFI console policy](../../bootloaders/rpi5-uefi-console.md) when selecting serial and HDMI output.
Follow the shared [efiboot artifact contract](../../bootloaders/efiboot.md) for kernel format, selected entry and matching modules.
Firmware, kernel and module revisions differ between published checks.
Read the selected receipt before reproducing a result.
Preserve a working boot medium and identify the replacement medium before writing it.

The board's power button and console have earlier support records.
Those records do not specify every timing, electrical connection or firmware setting.
Do not reuse the CM5 carrier's BOOT button procedure on this SBC.
Keep connector orientation and recovery wiring unknown until checked against its exact hardware documents.

Source: [the pinned OS board record](https://github.com/oxtech-ember/EmberBSD/blob/39547d144888a9286ccc58304048efc68cd8e966/ember/boards/raspberry-pi-5.md), ID `os-rpi5`.
