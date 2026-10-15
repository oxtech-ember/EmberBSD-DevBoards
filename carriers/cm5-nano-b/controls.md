# Controls and recovery

| Control | Known purpose | Boundary |
|---|---|---|
| BOOT | Select USB boot for recovery when asserted during power-on | Confirm the carrier label and schematic; the recovery receipt used this control |
| Module power control | Module power/reset contract | Exact carrier button sequence and OS shutdown behavior are not qualified here |
| LEDs | Visual observations | A color alone does not establish boot-ROM mode, OS health or safe storage removal |

The recorded USB recovery scenario powered the board off, asserted BOOT, then applied USB power and released BOOT.
It used a direct host USB connection and the fixed vendor RAM image.
A prior hub scenario did not enumerate the storage gadget; the experiment also changed UART wiring.
The hub was not isolated as the cause, so this is not a general prohibition on hubs.

See [the recovery profile](../../boards/bcm2712-cm5/configs/usb-recovery/README.md) for exact software inputs and limits.
Do not infer a firmware-flash operation from a RAM recovery command.
Sources: `nano-b-schematic`, `cm5-datasheet`, `usbboot-guide` in [sources.json](../../sources.json).
