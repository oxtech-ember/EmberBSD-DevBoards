# Boot and recovery

The recorded chain is vendor SPL → OpenSBI → U-Boot → kernel-copy stub → PSRAM kernel.
A device-tree flash range supplies the read-only root. The firmware console becomes a tty.
The port uses Sv32, CLIC through the interrupt matrix and the system timer.
SPI flash boot and multi-user execution are recorded. The exact flash map, recovery controls and console contacts are not established here.
Preserve matching loader, device tree and flash contents before replacing an image.
The code owner is [EmberBSD espressif](https://github.com/oxtech-ember/EmberBSD/tree/main/sys/arch/riscv/espressif).

Source: `os-esp32-s31-reference` in [sources.json](../../sources.json).
