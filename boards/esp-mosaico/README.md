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

A [standard EmberBSD framebuffer/LVGL trial](evidence/row-pair-display-touch.json)
on one V1.2 sample displayed a visible interface; the operator also confirmed
changing touch coordinates. The published [CO5300 row-pair fix](https://github.com/oxtech-ember/EmberBSD/commit/ded5f5242c6c8cb9cf17bb60d62ea0a520df7255)
uses two-row RASET windows to satisfy the panel's even-height requirement,
with 1920-byte width-4 pixel transfers. This confirms that configured RAM-boot
scenario on one sample; it does not establish support for other revisions.
Touch orientation/calibration, audio playback and sustained operation remain
unverified. Factory UI, touch and changing camera preview are separate
vendor-firmware evidence in the [factory observation](evidence/factory-peripherals.json).
The optional sensor, fuel-gauge and I²S/ES8311 paths now compile into the
SC101IOT target kernel; physical sensor telemetry and audio playback/capture
remain unverified. The SPI NAND tool only reads identification and status; NAND
data, ECC/BBT and filesystem support are not established. See [interface
limits](interfaces.md#camera-and-other-peripherals).

The optional [SC101IOT EmberBSD configuration](https://github.com/oxtech-ember/EmberBSD/blob/4ac7924ecb7/sys/arch/riscv/conf/ESP_MOSAICO_SC101IOT)
now includes sensor mode control and a DVP-to-video(4) capture path. The
configuration and Wi-Fi variant compile for the target. No physical EmberBSD
frame or preview has been captured; the earlier [identity observation](evidence/display-output.json)
is separate evidence. The mode table describes 640 × 480 UYVY and requires a
20 MHz XCLK; the fitted oscillator frequency and actual frame rate have not
been measured. See [interface limits](interfaces.md#camera-and-other-peripherals).

The [scan-cache check](evidence/wifi-scan.json) reached 18 net80211 entries
without ring or allocation failures. The normal multiuser RAM trial with the
published [SAE feature-capability fix](https://github.com/oxtech-ember/EmberBSD/commit/04ab058b06ce9ce1617691b9ad53cb443f0389b3)
reached the shell without the earlier null-callback panic. In the [recorded
association trial](evidence/wifi-association.json), a one-shot DEBUG capture
confirmed that the vendor rejected both encrypted AP candidates before SAE:
its internal STA profile had an empty password. The vendor emitted
`wifi:receive encrypted ap, but password is empty and no DPP credentials`,
then disconnect reason 210 `NO_AP_FOUND_W_COMPATIBLE_SECURITY`; the kernel
decoded the same reason. The vendor Wi-Fi auth mode was
`WIFI_AUTH_WPA3_PSK` (6), PMF capable and required were both set, and the PWE
configuration input was 0. No SAE callbacks, completed
association, IP address or data exchange followed. WPA2-only authentication,
DHCP/DNS, reconnect, roaming and sustained transfer remain unaccepted.

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
