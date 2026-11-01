# Interfaces and revision limits

The vendor guides specify 16 MB PSRAM, 16 MB SPI NOR and 128 MB SPI NAND.
The kit includes a 480 × 480 CO5300 QSPI display, touch, ES8311 audio,
BMI270 motion sensing, two BMM150 magnetometers and a BQ27220 fuel gauge.
The BSP has no onboard camera capability; cameras are expansion modules.
These are hardware/source descriptions, not EmberBSD driver acceptance.

## Select the revision before configuring pins

The following are SoC GPIO numbers, not connector contact numbers.
Source: the [pinned BSP header](https://github.com/esp-mosaico/esp-mosaico-bsp/blob/7cbfb390638dcb93522fc3cde094b2d43cf907c2/components/esp-mosaico-bsp/include/bsp/esp_mosaico.h).

| Signal | V1.0 | V1.2 |
| --- | --- | --- |
| Internal I²C SDA / SCL | GPIO0 / GPIO1; shared with slots | GPIO56 / GPIO3; separate from slots |
| Slot I²C SDA / SCL | GPIO0 / GPIO1 | GPIO0 / GPIO1 |
| LCD reset / clock | GPIO42 / GPIO44 | GPIO44 / GPIO42 |
| Status LED | GPIO3, active-low | Removed |
| Separate codec power control | GPIO56 | Removed |

The BSP reads the revision from eFuse USER_DATA through `bsp_board_variant_get()`.
Its [README](https://github.com/esp-mosaico/esp-mosaico-bsp/blob/7cbfb390638dcb93522fc3cde094b2d43cf907c2/README.md)
states that unknown or unprogrammed versions return `ESP_ERR_NOT_SUPPORTED`.
Legacy header aliases retain V1.0 values; they are not universal pin selections.
Do not write eFuses to resolve an identification gap.

## V1.2 LCD connector and power nets

The [CoreBoard V1.2 schematic (sheets 2, 3 and 5)](https://dl.espressif.com/AE/Mosaico/SCH_SCH_ESP-Mosaico_CoreBoard_V1_2_1_2026-09-24.pdf)
shows the 24-contact LCD board-to-board connector. These are connector contacts,
not GPIO numbers or pins from the display module's separate datasheet.

| LCD connector contact | CoreBoard V1.2 connection |
| --- | --- |
| 2, 4 | `VCC_3V3` |
| 5 | `VCC_3V3` through R18 (0 Ω) |
| 7 | `MCU_3V3` (touch supply) |
| 12 | LCD D0, GPIO36 through R53 (0 Ω) |
| 14 | LCD D1, GPIO51 through R52 (0 Ω) |
| 16 | LCD clock, GPIO42 through R20 (0 Ω) |
| 18 | LCD CS, GPIO50 |
| 19 | LCD D3, GPIO9 through R55 (0 Ω) |
| 21 | LCD D2, GPIO35 through R54 (0 Ω) |
| 24 | LCD reset, GPIO44; active-low per the pinned BSP |

On CoreBoard sheet 5, GPIO60 drives `VCC_PW` to control Q5 (AO3401A), the
high-side switch for `VCC_3V3`; the BSP defines this control as active-low.
This switched LCD supply is distinct from `MCU_3V3` at LCD contact 7. On the
[BaseBoard V1.2 schematic (sheet 1)](https://dl.espressif.com/AE/Mosaico/SCH_SCH_ESP-Mosaico_BaseBoard_A_V1_2_1_2026-09-24.pdf),
left-slot H2 contact 19 is `OUT_3V3` from a separate TLV62569 converter whose
input is `5V_OUT` and enable is `VCC_3V3`; it is not the CoreBoard `VCC_3V3` net.
Touch input or codec-register communication therefore does not establish the
LCD's switched supply state.

The vendor's [H0216F002AMT004-1 V1 display datasheet](https://dl.espressif.com/AE/H0216F002AMT004-1%20V1%E8%A7%84%E6%A0%BC%E4%B9%A62.16%E5%AF%B8%20480X480%20QSPI%20MIPI%20%20AMOLED.pdf)
describes a 31-pin display-module interface. The CoreBoard schematic instead
shows a 24-contact connector, so the module datasheet numbering must not be
applied to CoreBoard contacts. The exact electrical mapping within the display
module remains unestablished; use the CoreBoard schematic and pinned BSP for
board-side wiring.

## Touch and peripheral support

The vendor's [HMI example](https://github.com/esp-mosaico/esp-mosaico-bsp/tree/7cbfb390638dcb93522fc3cde094b2d43cf907c2/examples/hmi_demo)
is the LVGL reference. Its [BSP display implementation](https://github.com/esp-mosaico/esp-mosaico-bsp/blob/7cbfb390638dcb93522fc3cde094b2d43cf907c2/components/esp-mosaico-bsp/onboard/display.c)
distinguishes cold panel initialization from adopting an initialized boot splash.
The [Utils boot splash](https://github.com/esp-mosaico/esp-mosaico-utils/blob/be151ae047014e79a9c7ae0092dd203844499003/esp-mosaico-vibe-mode/firmware/vibe-mode/bootloader_components/main/mosaico_boot_splash.c)
provides a separate SPI output reference before LVGL starts; [Claw's panel setup](https://github.com/esp-mosaico/esp-mosaico-claw/blob/2654a4a9f76f5d7ea108e4dff7ade7b1df4c1c5c/boards/esp_mosaico/setup_device.c)
also handles the retained splash. These software revisions do not identify the
factory firmware in the [vendor application observation](evidence/vendor-webui.json),
and rendering a framebuffer does not establish visible panel output. A published
[ESP32-S31 SPI initialization change](https://github.com/oxtech-ember/EmberBSD/commit/37fb3aec46352034ad4b7ae78d354b39295a00ff)
leaves the controller's data lines high while idle. A RAM run of that revision
still produced a black screen; CO5300 status reads returned all-0xff values without
bus errors, which does not establish a valid panel response.

The guides name CST9220-series touch; the pinned BSP names CST9217. On one
V1.2 sample the EmberBSD driver identified CST9220, project 0x6854, at 480 × 480
and attached `wsmouse`. A [subsequent input check](evidence/touch-input.json)
observed contact/release events and changing absolute coordinates; orientation
and calibration have not been verified.
The earlier peripheral observation also read BMI270 and ES8311 identification registers; it did not
verify motion sensing or audio playback. See the [bounded observation](evidence/gui-peripherals.json).

## Expansion and debug routing

Use the revision-specific vendor schematic for connector orientation and contact numbers.
The left slot exposes USB Serial/JTAG; the right slot exposes UART.
These paths are distinct from Type-C OTG.
For the [V1.2 right slot H1](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp-mosaico/user_guide.html#right-module-slot-h1-pins),
contact 13 is board RX0/GPIO59, contact 15 is board TX0/GPIO58 and contact 20 is GND.
Identify Pin 1 from the marking/schematic before counting contacts.
The back pads also carry RX, TX and GND labels. With a 3.3 V logic USB-UART
adapter, cross adapter TX to board RX and adapter RX to board TX, and join
ground. Keep adapter supply pins disconnected when the board is powered by USB-C.
Make connections with the board powered off. This is the vendor wiring route;
it does not establish a working EmberBSD serial console.

The [UART ROM check](evidence/uart-rom.json) verified request/response through
an FT232R adapter at 115200 baud, 8N1, with only TX, RX and ground connected.
Board power came separately through USB-C. A ROM identification response matched
the earlier USB readback identity. That ROM check established both UART directions; the separate operating-system
boot evidence establishes an EmberBSD console, but not sustained transfers.

Camera modules use the left slot only. On one V1.2 sample, the CRC-valid EEPROM
descriptor's hardware-version field was 0x0102; this identifies descriptor metadata,
not sensor silicon, and is independent of the CoreBoard revision. The vendor guide's
sensor mapping is a reference, not definitive part identification. In a separate
[restored factory-firmware observation](evidence/factory-peripherals.json), UART
reported SC101IOT PID 0xda4a and the first 1280 × 720 UYVY preview frame rendered;
the operator confirmed a changing live image. This establishes factory-firmware
operation on that sample only, not the sensor identity of other modules or EmberBSD
camera support. The optional published
[ESP_MOSAICO_SC101IOT configuration](https://github.com/oxtech-ember/EmberBSD/blob/7da47e2c1f0bb3829275a189904a5c97fb50f7f8/sys/arch/riscv/conf/ESP_MOSAICO_SC101IOT)
uses the [SC101IOT identity-only driver](https://github.com/oxtech-ember/EmberBSD/blob/5f706391bfc94d6f349a78ad56e477504267637e/sys/dev/i2c/sc101iot.c)
at 7-bit SCCB address `0x68`: it selects page `0x31` through `0xf0` and reads ID
registers `0xf7` and `0xf8`. One V1.2 RAM trial identified PID `0xda4a`.
The driver does not implement DVP capture or establish an EmberBSD camera preview.
The common kernel configuration no longer selects the OV3640 driver. Its FDT node
is marked disabled, and the generic FDT I²C enumerator skips disabled children.
See the bounded
[display and camera observation](evidence/display-output.json).
Some camera signals conflict with USB Serial/JTAG; the BSP directs affected examples
to UART.
Five right-slot signals share the onboard audio I²S bus.
Do not allocate those signals to another function while the codec uses them.

The two slots use EEPROM addresses `0x50` and `0x51` for discovery.
The BSP module manager validates descriptors and provides exclusive slot ownership.
A descriptor or a software module name does not prove that the corresponding hardware is fitted.
Follow the [BSP examples and resource rules](https://github.com/esp-mosaico/esp-mosaico-bsp/tree/7cbfb390638dcb93522fc3cde094b2d43cf907c2).

## Vendor application observations

The checked application exposes WebUI status, capability and Lua-module catalogs.
The Lua catalog includes display/LVGL, audio, GPIO, I²C, UART, magnetometer and camera modules.
Catalog presence does not establish successful acquisition, output, permissions or module compatibility.
The [evidence record](evidence/vendor-webui.json) lists the read-only requests and their limits.
Application API contracts remain with the vendor software owner.
