# Boot and recovery

The recorded chain uses vendor boot0, U-Boot, a board-specific device tree and an EmberBSD kernel on microSD.
[The OS boot script](https://github.com/oxtech-ember/EmberBSD/blob/ad698a6e40ea89d72249f76d06913be29a5ab90c/ember/boot/orangepi-zero4-boot.cmd) distinguishes this board from the related Zero 4.
The boards share silicon but do not expose the same Ethernet hardware.
Follow the shared [U-Boot image and entry contract](../../bootloaders/u-boot-native-image.md).
For FAT storage, also read the [filesystem startup checks](../../bootloaders/fat-boot-volume.md).
Keep firmware, DTB, kernel and storage assumptions explicit when adapting a custom board.

A separate recovery card and a verified serial connection provide recovery independent of Wi-Fi.
This profile does not yet provide a sourced UART pin map or boot-button sequence.
Do not borrow CM5 or Zero 4 wiring to fill those gaps.
The OS record reports no power button.
Its accepted stock-fan power-off scenario uses `shutdown -p now`; plain `halt` leaves power applied.
Fan speed control and a full power-off are different operations.

Sources: `os-zero3w` and `os-a733-boot` in [sources.json](../../sources.json).
