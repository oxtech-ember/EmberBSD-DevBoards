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
also handles the retained splash.

On one V1.2 sample, factory firmware showed a visible UI, touch response and a
changing camera preview; these remain separate vendor-firmware observations.
The standard EmberBSD CO5300 framebuffer/genfb/LVGL path displayed a visible
interface in a RAM trial, and the operator confirmed changing touch coordinates
in that run. The published [row-pair worker fix](https://github.com/oxtech-ember/EmberBSD/commit/ded5f5242c6c8cb9cf17bb60d62ea0a520df7255)
replaces invalid one-row RASET windows with even-height two-row windows and
1920-byte width-4 pixel transfers, satisfying the CO5300 requirement. See the
[bounded display/touch observation](evidence/row-pair-display-touch.json).
This confirms one configured V1.2 sample only. Touch orientation and quantitative
calibration, audio playback and sustained operation remain unverified. The
optional SC101IOT EmberBSD configuration now has a target-built sensor/DVP/video(4)
capture path, but no physical EmberBSD frame has been captured. The mode table
describes 640 × 480 UYVY at a required 20 MHz XCLK; oscillator frequency and
actual frame rate remain unmeasured. See [camera and other peripherals](#camera-and-other-peripherals).
A software transfer trace is not a voltage measurement of the switched LCD supply.

The guides name CST9220-series touch; the pinned BSP names CST9217. On one
V1.2 sample the EmberBSD driver identified CST9220, project 0x6854, at 480 × 480
and attached `wsmouse`. A [subsequent input check](evidence/touch-input.json)
observed contact/release events and changing absolute coordinates; orientation
and calibration have not been verified.
The earlier peripheral observation read BMI270 and ES8311 identification registers; it did not
verify motion measurements or audio playback. EmberBSD now has target-built sensor,
fuel-gauge and audio paths; their physical telemetry and audio operation remain
unverified. See the [bounded observation](evidence/gui-peripherals.json) and the
table below.

## Wireless

The [scan-cache check](evidence/wifi-scan.json) reached 18 net80211 entries
without ring or allocation failures. One strict SAE/PMF-required trial and the
WPA2-PSK/CCMP/PMF0 control reached native `RUN`, but neither reached
`WPA_COMPLETED`; both ended after the PTK handshake timeout (reason 204).
In the latest WPA2 diagnostic, the live `pp_wdev_funcs+0x198` protocol hook
counted 123 management frames with `rxmatch0` set and no control, data or
extension frames; the normal STA callback saw the same 123 management frames.
The `pp_wdev_funcs+0x414` sublength hook and ROM caller at +0x1f4 matched and
counted 127 management frames in the latest legacy-PHY WPA2 run; invalid and
short counts were zero. The legacy protocol set/get calls both returned 0 and
read back bitmap `0x3` (11b|11g); this did not resolve the timeout, so HT/HE
mode alone does not explain the failure. The DATA-state histogram prints only
nonzero bins, so it is empty as expected when no DATA frames were observed.
Association-stage STA and BSSID register readbacks were valid and matched, and
the association snapshot was captured; begin/end BSSID mismatch occurred
during transition outside association. These hooks do not observe all hardware or over-the-air
traffic, so they do not establish whether the AP transmitted a frame or where
any earlier loss occurred. The separate WDEV-candidate SAE/PMF2 attempt also reached
`ASSOCIATED` (last status `key_mgmt=SAE`, `pmf=1`) but not `WPA_COMPLETED`;
the AP log recorded an `sae_key` event, association and station deauthentication
after PTK timeout. These records do not establish an accepted SAE commit/confirm
or EAPOL exchange. Local `ieee80211w` is policy: 0 disables PMF, 1 permits it
when supported, and 2 requires it. In wpa_supplicant 2.12
[STATUS generation](https://w1.fi/cgit/hostap/tree/src/rsn_supp/wpa.c?h=hostap_2_12#n5303),
`pmf=1` means AP MFPC set/MFPR clear and `pmf=2` means AP MFPR set; STATUS is
not the local policy. The attempt did not reach `WPA_COMPLETED`, so negotiated
PMF/IGTK remains unverified. The AP log records station deauthentication after
the PTK timeout, not M1 transmission or acknowledgement. Hardware RX values
are opaque; internal-pool misses, fallback and NULL were zero, with 197136
bytes minimum free. No EAPOL input, negotiated PMF, IPv4 address or accepted
network data exchange followed. See the
[association evidence](evidence/wifi-association.json). WPA2 authentication,
DHCP/DNS, reconnect, roaming and sustained transfer remain unverified.

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
[ESP_MOSAICO_SC101IOT configuration](https://github.com/oxtech-ember/EmberBSD/blob/4ac7924ecb7/sys/arch/riscv/conf/ESP_MOSAICO_SC101IOT)
uses the [SC101IOT driver](https://github.com/oxtech-ember/EmberBSD/blob/4ac7924ecb7/sys/dev/i2c/sc101iot.c)
at 7-bit SCCB address `0x68`; it identifies the sensor and configures the
source-backed 640 × 480 UYVY mode. The [S31 DVP driver](https://github.com/oxtech-ember/EmberBSD/blob/4ac7924ecb7/sys/arch/riscv/espressif/esp32s31_dvp.c)
transports frames through video(4). Both standard and Wi-Fi kernel configurations
target-build. No physical EmberBSD capture is established. The mode table requires
20 MHz XCLK and names 15 fps; fitted oscillator frequency and actual frame rate
are unmeasured. The earlier identity and factory-preview observations remain
separate from this source/build result.
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

## Camera and other peripherals

The hardware details below follow the [BSP revision 7cbfb39](https://github.com/esp-mosaico/esp-mosaico-bsp/tree/7cbfb390638dcb93522fc3cde094b2d43cf907c2).
The OS support statements refer to the linked published sources and target builds,
not physical peripheral acceptance.

| Device | BSP/source interface | EmberBSD source status |
| --- | --- | --- |
| BMI270 | Shared I²C at 7-bit address `0x69`; BSP `onboard/sensors.c` initializes it. | The [native envsys driver](https://github.com/oxtech-ember/EmberBSD/blob/718a9c6ba45/sys/dev/i2c/bmi270_driver.c) is present and the `ESP_MOSAICO_SC101IOT_WIFI` kernel linked with it. Motion samples have not been checked on the board. |
| BMM150 ×2 | Shared I²C at addresses `0x11` and `0x12`; BSP `onboard/sensors.c` configures and reads both. | The [native SensorAPI-backed envsys driver](https://github.com/oxtech-ember/EmberBSD/blob/718a9c6ba45/sys/dev/i2c/bmm150_driver.c) is present; both addresses are configured in the board tree and the target kernel linked. Physical magnetometer samples remain unverified. |
| BQ27220 | Shared I²C at address `0x55`; BSP `onboard/battery.c` attaches and reads the gauge. | The [read-only native envsys driver](https://github.com/oxtech-ember/EmberBSD/blob/df97773b7b3/sys/dev/i2c/bq27220.c) is present and included in the target kernel build. Board telemetry has not been checked. |
| ES8311 audio | I²S codec on the onboard audio bus; BSP `onboard/audio.c` and the V1.2 schematic describe the codec and amplifier path. | The [S31 I²S/AHB-DMA driver](https://github.com/oxtech-ember/EmberBSD/blob/d27e2d790a2/sys/arch/riscv/espressif/esp_i2s.c) and [ES8311 codec driver](https://github.com/oxtech-ember/EmberBSD/blob/d27e2d790a2/sys/dev/i2c/es8311ac.c) are present and the target kernel linked. No EmberBSD playback or capture has been tested. |
| SPI NAND | BSP identifies GigaDevice GD5F1GM7UEYIGR on SPI3, using GPIO20–25 for clock, data, chip select, HOLD and WP. | SPI3 pin routing and the [read-only `spinandctl` utility](https://github.com/oxtech-ember/EmberBSD/blob/88fea10b9fd/usr.sbin/spinandctl/spinandctl.c) are present. It issues READ ID and status-register commands only. No NAND page data, ECC, bad-block table, filesystem, boot or physical ID/status test is established. |
| USB | Type-C ROM USB-OTG download/readback is recorded in [ROM evidence](evidence/rom-readback.json). S31 USB 2.0 HS OTG uses dedicated package pads 44/45. | The board kernel does not integrate an S31 OTG controller/role path. ROM download is not EmberBSD USB support. Host VBUS/CC role and power behavior are not verified, so USB host mode is not part of the prepared board configuration. |

Package pads 44 and 45 are USB_D+ and USB_D−; they are not GPIO44 and GPIO45.
The V1.2 schematic and BSP assign GPIO44 to LCD reset and GPIO45 to audio PA
enable. Do not treat the dedicated USB pads as GPIOs or reassign those board GPIOs
to USB. The Type-C connector's host-power and role path has not been established.

The generic OS source includes [`i2cscan`](https://github.com/oxtech-ember/EmberBSD/blob/88fea10b9fd/usr.sbin/i2cscan/i2cscan.c),
[`usbdevs`](https://github.com/oxtech-ember/EmberBSD/tree/4ac7924ecb7/usr.sbin/usbdevs)
and [`usbhidctl`](https://github.com/oxtech-ember/EmberBSD/tree/4ac7924ecb7/usr.bin/usbhidctl);
their presence in a particular root image is not established here. The BSP implementation
links for [sensors](https://github.com/esp-mosaico/esp-mosaico-bsp/blob/7cbfb390638dcb93522fc3cde094b2d43cf907c2/components/esp-mosaico-bsp/onboard/sensors.c),
[battery gauge](https://github.com/esp-mosaico/esp-mosaico-bsp/blob/7cbfb390638dcb93522fc3cde094b2d43cf907c2/components/esp-mosaico-bsp/onboard/battery.c)
and [SPI NAND](https://github.com/esp-mosaico/esp-mosaico-bsp/blob/7cbfb390638dcb93522fc3cde094b2d43cf907c2/components/esp-mosaico-bsp/onboard/nand_flash.c)
show vendor-side implementations, not BSD support.

## Vendor application observations

The checked application exposes WebUI status, capability and Lua-module catalogs.
The Lua catalog includes display/LVGL, audio, GPIO, I²C, UART, magnetometer and camera modules.
Catalog presence does not establish successful acquisition, output, permissions or module compatibility.
The [evidence record](evidence/vendor-webui.json) lists the read-only requests and their limits.
Application API contracts remain with the vendor software owner.
