# Power, boot and recovery

The charge LED reports charging, not processor execution or USB data connectivity.
Press POWER once to turn the board on. USB power can charge it while it is off.
The Type-C connector carries USB 2.0 High-Speed OTG as well as power.
Use a data-capable cable. The vendor application supplies its USB CDC console;
the running application and its USB configuration therefore affect enumeration.
See the [hardware guide](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp-mosaico/user_guide.html#hardware-notes).

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
