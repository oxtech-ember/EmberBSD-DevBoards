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

The guides name CST9220-series touch; the cited BSP names CST9217.
Confirm the fitted controller and BSP detection path before selecting a touch driver.

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
the earlier USB readback identity. This establishes both UART directions;
it does not establish OpenSBI/EmberBSD console output or sustained transfers.

Camera modules use the left slot only. Some camera signals conflict with USB Serial/JTAG;
the BSP directs affected examples to UART.
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
