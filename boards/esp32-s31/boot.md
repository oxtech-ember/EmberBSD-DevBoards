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

On one operator-reported ESP-Mosaico V1.2 sample, a NOR-mapped SPL received a
1,529,856-byte FIT over YMODEM at 460800 baud in 52.093 seconds. The kernel
then mounted the NOR LittleFS root from `flash1` with the console at 115200.
This is a single-sample transfer measurement, not a general throughput
guarantee. Before changing the console rate, the S31 UART driver must wait for
both an empty TX FIFO and an idle TX state machine; see the
[EmberBSD Ports U-Boot source at commit 738d7b62](https://github.com/oxtech-ember/EmberBSD-Ports/commit/738d7b621445b6d39ff07acc7005d978628d07e2).

The code owner is [EmberBSD espressif](https://github.com/oxtech-ember/EmberBSD/tree/main/sys/arch/riscv/espressif).

Source: `os-esp32-s31-reference` in [sources.json](../../sources.json).
