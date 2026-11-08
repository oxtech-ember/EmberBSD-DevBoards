# Boot and recovery

The recorded chain is vendor SPL → OpenSBI → U-Boot → kernel-copy stub → PSRAM kernel.
A device-tree flash range supplies the read-only root. The firmware console becomes a tty.
The port uses Sv32, CLIC through the interrupt matrix and the system timer.
SPI flash boot and multi-user execution are recorded. The exact flash map, recovery controls and console contacts are not established here.
Preserve matching loader, device tree and flash contents before replacing an image.

A RAM-loaded kernel with a NOR-backed root requires the RAM loader to establish
NOR initialization before handing off to firmware. A PSRAM-only loader does not
establish NOR initialization. The S31 SBI provider reports the detected ROM
`chip_size`; it does not initialize NOR. The kernel uses the reported geometry
and its device-tree map when locating `flash1`. This boot-path prerequisite is
demonstrated in the [Mosaico RAM-to-NOR check](../esp-mosaico/evidence/ram-nor-littlefs.json).

The code owner is [EmberBSD espressif](https://github.com/oxtech-ember/EmberBSD/tree/main/sys/arch/riscv/espressif).

Source: `os-esp32-s31-reference` in [sources.json](../../sources.json).
