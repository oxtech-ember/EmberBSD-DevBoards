# Boot and recovery

The recorded chain uses vendor boot0, U-Boot, a board-specific device tree and an EmberBSD kernel on microSD.
[The OS boot script](https://github.com/oxtech-ember/EmberBSD/blob/39547d144888a9286ccc58304048efc68cd8e966/ember/boot/orangepi-zero4-boot.cmd) distinguishes this board from the related Zero 4.
The boards share silicon but do not expose the same Ethernet hardware.
Keep firmware, DTB, kernel and storage assumptions explicit when adapting a custom board.

A separate recovery card and a verified serial connection provide recovery independent of Wi-Fi.
This profile does not yet provide a sourced UART pin map or boot-button sequence.
Do not borrow CM5 or Zero 4 wiring to fill those gaps.
The OS record reports no power button.
Its accepted stock-fan power-off scenario uses `shutdown -p now`; plain `halt` leaves power applied.
Fan speed control and a full power-off are different operations.

Sources: `os-zero3w` and `os-a733-boot` in [sources.json](../../sources.json).
