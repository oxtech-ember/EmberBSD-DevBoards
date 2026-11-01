# ESP-Mosaico

An ESP32-S31 interaction kit with a CoreBoard and its supplied BaseBoard.
Use this profile for the assembled kit. It is a separate target from the
[unspecified ESP32-S31 development board](../esp32-s31/README.md).

[Power, boot and recovery](boot.md) · [Interfaces](interfaces.md) ·
[Design transfer](design.md) · [Profile](board.json)

## Identity and evidence

The [vendor BSP](https://github.com/esp-mosaico/esp-mosaico-bsp/tree/7cbfb390638dcb93522fc3cde094b2d43cf907c2)
supports V1.0 and V1.2 mappings; it maps V1.1 to V1.2.
Read the CoreBoard marking or the BSP hardware-version result before selecting pins.
The operator identified the physical sample as V1.2. Its eFuse revision and
the supplied BaseBoard marking were not independently read.

A [bounded vendor-firmware observation](evidence/vendor-webui.json) confirms
network access to the settings page, a live log connection and module catalog reads.
The operator reported the screen labels `Software 0.4.0` and `GSP 1.5.1`.
These labels do not identify an EmberBSD build or an ESP-Claw source revision.
USB enumeration, recovery and peripheral operation were not established by this check.
The separate [ROM readback check](evidence/rom-readback.json) established Type-C
download access and verified a complete 16 MiB NOR backup against the device.
Its installed partition table differs from the cited Vibe source layout;
see [boot and recovery](boot.md#observed-factory-layout).
The [UART ROM check](evidence/uart-rom.json) also verified bidirectional
identification through H1 with an external USB-UART adapter.
The [RAM-only SPL check](evidence/ram-spl.json) reached its UART receiver and
reported 16 MiB PSRAM density on this sample. It did not test full PSRAM
read/write, U-Boot proper, OpenSBI or an EmberBSD kernel.
A subsequent [RAM firmware check](evidence/ram-firmware.json) received and
verified a firmware FIT, started OpenSBI and reached the U-Boot prompt.
That check did not establish an EmberBSD kernel boot or persistent installation.
A later [RAM operating-system check](evidence/ram-os.json) booted the
`ESP_MOSAICO` kernel with an FFS memory-disk root to a single-user shell.
UART input, a child shell and one Ctrl-C were observed. A subsequent
[battery-powered NOR boot](evidence/nor-os.json) reached a single-user shell
after a normal POWER press. Its FFS root is an in-memory disk; persistent
filesystem writes, NAND, full PSRAM read/write and general application
support remain unverified.

A bounded [RAM graphics trial](evidence/gui-peripherals.json) attached the CO5300
framebuffer and CST9220 touch driver and kept LVGL running; the display remained
black. The [touch input check](evidence/touch-input.json) confirmed raw contact,
release and changing-coordinate events. Factory UI, touch and changing camera
preview are separate vendor-firmware evidence in the
[factory observation](evidence/factory-peripherals.json).

The normal EmberBSD CO5300 framebuffer/LVGL path remains black on this sample,
including after the published [SPI data-line mode fix](https://github.com/oxtech-ember/EmberBSD/commit/6bd36b7ada1290598cd2c04696b00fbf55793ab9).
Nonzero pixel buffers and zero SPI transfer errors do not establish visible
output. A separate reference-core diagnostic produced a solid red field from
inside the OS (result 0, no LVGL) using a temporary unpublished kernel adapter;
see [its bounded observation](evidence/reference-core-red.json). The cause and
standard framebuffer display acceptance remain unresolved. The [earlier
U-Boot/kernel comparison](evidence/uboot-red-kernel-black.json) retains its
historical register snapshot; it is not a current diagnosis. Touch calibration
and audio function remain unverified.

The same [camera identity check](evidence/display-output.json) read SC101IOT PID
`0xda4a` at `0x68` with the optional EmberBSD identity-only driver. DVP capture
is not implemented, so this is not an EmberBSD camera preview.

A separate [factory-firmware observation](evidence/factory-peripherals.json) followed a
restore that wrote only the two ranges replaced by the OS installation. Before
writing, the full NOR matched the expected installed state; afterward, it matched
the original factory backup. On this sample the factory UI was visible,
touch worked, and a changing SC101IOT preview (PID 0xda4a, 1280 × 720 UYVY) rendered.
Factory Wi-Fi STA, DHCP and read-only status requests also succeeded. This is vendor-
firmware evidence only and does not establish EmberBSD camera, touch or display support.

## Sources

- [CoreBoard V1.0 guide](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp-mosaico/user_guide_v1.0.html)
- [CoreBoard V1.2 guide and schematic links](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp-mosaico/user_guide.html)
- [Vendor user guide](https://mosaico.ai/en/guide)
- [BSP pin and revision interface](https://github.com/esp-mosaico/esp-mosaico-bsp/blob/7cbfb390638dcb93522fc3cde094b2d43cf907c2/components/esp-mosaico-bsp/include/bsp/esp_mosaico.h)
- [Vendor device modes](https://github.com/esp-mosaico/esp-mosaico-vibe/blob/1872fd88c01d7807556d01fd2a19864e40a307c9/docs/device-modes.md)

Review dates and source pins are in [sources.json](../../sources.json).
Vendor source pins describe the reviewed documentation, not the installed firmware.
