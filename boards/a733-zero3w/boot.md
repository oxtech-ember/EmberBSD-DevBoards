# Boot and recovery

The recorded chain uses vendor boot0, U-Boot, a board-specific device tree and an EmberBSD kernel on microSD.
[The OS boot script](https://github.com/oxtech-ember/EmberBSD/blob/ad698a6e40ea89d72249f76d06913be29a5ab90c/ember/boot/orangepi-zero4-boot.cmd) distinguishes this board from the related Zero 4.
The boards share silicon but do not expose the same Ethernet hardware.
Follow the shared [U-Boot image and entry contract](../../bootloaders/u-boot-native-image.md).
For FAT storage, also read the [filesystem startup checks](../../bootloaders/fat-boot-volume.md).
Keep firmware, DTB, kernel and storage assumptions explicit when adapting a custom board.

A separate recovery card and a verified serial connection provide recovery independent of Wi-Fi.
Use the UART0 wiring below for the documented V1.2 board.
Check the revision and connector orientation before you connect another board.
The boot-button sequence remains unknown.
The OS record reports no power button.
Its accepted stock-fan power-off scenario uses `shutdown -p now`; plain `halt` leaves power applied.
Fan speed control and a full power-off are different operations.

## Diagnostic boot selection

The normal Zero 3W DTB requests GPU startup at 600 MHz after the root mount, before init(8).
Single-user mode cannot prevent this startup. A spare kernel that uses the normal DTB is not an observe-only recovery path.
For diagnosis, use a separate DTB that selects observe-only mode for both GPU and display.
Select that DTB through an independent loader entry before kernel execution.
Verify access to that entry through the actual loader before updating the normal bundle. The [update recipe](update.md) lists the checks.
Check that a failed diagnostic entry cannot silently continue into normal boot.
A mode variable or a saved DTB file alone does not establish an independent recovery route.

The [GPU startup contract](https://github.com/oxtech-ember/EmberBSD/blob/60058290e0dfc8813f79e3c675532addfb292935/sys/arch/arm/sunxi/docs/a733-gpu-identification.md#native-startup)
defines the current source behavior. Source review does not establish successful automatic startup or physical recovery on a board.
Source ID: `os-a733-gpu-native-startup` in [sources.json](../../sources.json).

## UART0 console, V1.2

Use physical pin numbers on the 40-pin header, not GPIO numbers.
The [manual](https://drive.google.com/file/d/1R1MC9erKTztd87GvJ_UFE132x6KgPATe/view), section 2.11.1, shows the debug connection on this header.
The [V1.2 schematic](https://drive.google.com/file/d/1layhtSvMpQo-z_iMJjNfNVvhPhObpsvW/view), sheets 9 and 18, identifies PB9/PB10 and confirms these physical pins.

| Board pin | Board signal | USB-to-TTL adapter connection |
|---|---|---|
| 6 | GND | GND |
| 8 | PB9 / UART0 TX | RX |
| 10 | PB10 / UART0 RX | TX |

Find the square pin 1 pad at the header end next to Mini-HDMI.
The row toward the board components has odd pin numbers.
The outer row has even pin numbers.
Count 2, 4, 6, 8 and 10 along that outer row from the pin 1/2 end.

Use a USB-to-TTL adapter with 3.3 V signal levels.
Leave the adapter's 3.3 V and 5 V power pins disconnected.
Set 115200 baud, eight data bits, no parity and one stop bit.
Disable hardware and software flow control.
The EmberBSD device tree selects `serial0:115200n8` and enables the PB9/PB10 pin group.

The manual labels the separate corner test pads `POWER ON/BOOT`.
Do not treat those pads as a separate three-pin UART connector.
These sources establish wiring; they do not establish physical serial operation on another specimen or revision.

Sources: `os-zero3w`, `os-a733-boot`, `os-a733-console-dts`,
`vendor-zero3w-manual` and `vendor-zero3w-schematic` in [sources.json](../../sources.json).
