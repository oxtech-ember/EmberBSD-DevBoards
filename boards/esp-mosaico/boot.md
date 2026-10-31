# Power, boot and recovery

A [RAM-only first-stage check](evidence/ram-spl.json) on one operator-reported
V1.2 kit with ESP32-S31 silicon revision 0.0 reached the SPL UART receiver.
The SPL reported 16 MiB PSRAM density after its mode-register sequence; this
is not a full-memory read/write test. FIT reception, later boot stages and
permanent installation were not tested in that check. A subsequent
[RAM firmware check](evidence/ram-firmware.json) verified the FIT image hashes,
started OpenSBI and reached the U-Boot prompt on the same sample. It did not
establish EmberBSD kernel boot or a persistent installation.

On the same V1.2 sample, a subsequent [RAM OS boot](evidence/ram-os.json)
reached a single-user shell with an FFS memory-disk root. UART input, a child
shell and one Ctrl-C were observed. This is a RAM-only scenario; full PSRAM
testing, persistent boot and broader runtime support remain unverified.

The charge LED reports charging, not processor execution or USB data connectivity.
The [V1.2 hardware guide](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp-mosaico/user_guide.html#hardware-revision-details)
specifies orange while charging and white when fully charged; V1.0 used red and green.
Press POWER once to turn the board on. USB power can charge it while it is off.
The Type-C connector carries USB 2.0 High-Speed OTG as well as power.
Use a data-capable cable. The vendor application supplies its USB CDC console;
the running application and its USB configuration therefore affect enumeration.
See the [hardware guide](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp-mosaico/user_guide.html#hardware-notes).

White is also compatible with ROM Download Mode: in the
[LED and ROM check](evidence/charge-led-rom.json), the operator reported white
while a ROM security query succeeded without a reset or RAM stub.
A change to white therefore does not establish exit from ROM.
No ROM idle timeout was established by that check; confirm the mode through a
ROM response rather than the charge LED color.

## Distinct startup paths

| Path | Purpose and prerequisite |
| --- | --- |
| Normal application | Runs the selected application. ESP-Iris is available only if the application integrates and starts it. |
| Vibe Mode | Retained application installation and maintenance firmware. Hold AI while powering on; release when the mode starts. Working retained firmware and its bootloader are required. |
| ROM Download Mode | Chip ROM for low-level provisioning and recovery. Hold BOOT while powering on. This mode does not run ESP-Iris. |

AI and BOOT are different buttons. The
[pinned device-mode guide](https://github.com/esp-mosaico/esp-mosaico-vibe/blob/1872fd88c01d7807556d01fd2a19864e40a307c9/docs/device-modes.md)
defines these paths. Vibe Mode can download an Idea over Wi-Fi; download and boot
selection are separate operations. The vendor's
[full firmware updater](https://mosaico.ai/en/firmware) uses USB and ROM mode.
ROM access and NOR backup verification were exercised in the
[ROM readback check](evidence/rom-readback.json). Firmware writing, restoration
and the Vibe update path have not been exercised.

The cited tools describe a retained `vibe_mode` partition and a separate application.
Do not infer the installed partition table from a repository release or a screen version.
Use the vendor's current update-selection rules and establish recovery before replacing firmware.
The generic ESP32-S31 port's loader chain and flash-root layout are not a Mosaico installation recipe.

## ESP32-S31 firmware sources

The shared [ROM working-memory boundary](../../socs/esp32-s31.md#rom-working-memory-during-early-boot)
applies when placing SRAM boot stages and their stacks.

Espressif publishes a developer-preview Linux boot chain for the ESP32-S31.
Its [U-Boot SPL](https://github.com/espressif/u-boot/blob/333c7a31f49d0ecc796edc7b6f7d44c4fcd1e9f8/board/espressif/esp32s31/spl.c)
initializes the SoC and loads OpenSBI, U-Boot and a device tree; its
[PSRAM initialization](https://github.com/espressif/u-boot/blob/333c7a31f49d0ecc796edc7b6f7d44c4fcd1e9f8/board/espressif/esp32s31/spl_psram.c)
is part of that SPL. The matching
[OpenSBI platform](https://github.com/espressif/opensbi/tree/5395e03e1cb295257142cfdeaade6334f1543bcb/platform/generic/espressif/esp32s31)
implements the S31 firmware services. Espressif's
[image layout and packaging](https://github.com/espressif/esp-linux-bsp/tree/a427cfbf5cccebd4f4e571db8a111ff1f5d31d71)
are for its Linux preview, not an EmberBSD Mosaico image.

The preview's [U-Boot device tree](https://github.com/espressif/u-boot/blob/333c7a31f49d0ecc796edc7b6f7d44c4fcd1e9f8/arch/riscv/dts/esp32s31.dts)
uses root compatible `espressif,esp32s31`, whereas the
[EmberBSD platform](https://github.com/oxtech-ember/EmberBSD/blob/9fb4f116466938027d200f582ea0c1beca8c6ab0/sys/arch/riscv/espressif/esp32s31_platform.c)
matches `esp,esp32s31`. Its interrupt-controller bindings also differ from the
[EmberBSD driver](https://github.com/oxtech-ember/EmberBSD/blob/9fb4f116466938027d200f582ea0c1beca8c6ab0/sys/arch/riscv/espressif/esp_intmtx.c).
The preview device tree therefore cannot be assumed to select the EmberBSD
platform or attach its interrupt controller. These sources do not identify the
loader, device tree or kernel-copy stub used in the earlier S31 board result,
and do not establish an EmberBSD boot on Mosaico.

## Observed factory layout

The sample reported as V1.2, with screen labels `Software 0.4.0` and `GSP 1.5.1`,
has an ESP-IDF partition table at NOR offset `0x9000`. Its MD5 was checked
against a complete private NOR readback. These are observed source offsets,
not write instructions or a layout for all Mosaico firmware versions.

| Label | Type / subtype | Offset | Size |
| --- | --- | --- | --- |
| `nvs` | `0x01 / 0x02` | `0x00a000` | `0x006000` |
| `otadata` | `0x01 / 0x00` | `0x010000` | `0x002000` |
| `phy_init` | `0x01 / 0x01` | `0x012000` | `0x001000` |
| `factory` | `0x00 / 0x00` | `0x020000` | `0x7d0000` |
| `ui_apps` | `0x01 / 0x41` | `0x7f0000` | `0x320000` |
| `system` | `0x01 / 0x83` | `0xb10000` | `0x2ee000` |

The presence of `otadata` does not supply an OTA application partition.
This table has no `vibe_mode`, `ota_0` or `ota_1` entry. Establish the actual
loader and layout before choosing an application-only updater.
The NOR backup does not cover the separate 128 MB NAND or eFuses.

## Diagnose connectivity by layer

Check power-on, host USB enumeration and the console interface separately.
A network settings page can work without an enumerated USB console.
A missing serial port does not establish ROM mode, a defective cable or a failed driver.
Check the data cable, host accessory authorization and active firmware before choosing recovery.
WebUI live logs require the device's `Settings > Debug > Live Logs in WebUI` option.
The observed stream contains new messages; it does not recover the earlier boot log.

On the reported V1.2 sample, BOOT held during power-on produced an `ESP32-S31`
USB device and a serial port. POWER is a toggle: the charge LED does not tell
whether the processor is on. The serial path must be rediscovered after a
reset or reconnect. ROM `verify-flash` succeeded after manual ROM re-entry;
the cause of the USB disconnect after the RAM-stub read was not established.

See the [vendor-firmware observation](evidence/vendor-webui.json) for the checked scope.
