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
shell and one Ctrl-C were observed. This was a RAM-only scenario; full PSRAM
testing and broader runtime support remain unverified.

A later [RAM littlefs acceptance](evidence/ram-littlefs.json) booted the
`ESP_MOSAICO_LITTLEFS` kernel with a littlefs RAM root on the same reported
V1.2 sample. The root was remounted read-write, the full VFS checker passed,
and `sync` returned successfully. The filesystem image was loaded into RAM;
this did not exercise NOR filesystem access or persistence across power loss.

A later [RAM-only NOR read check](evidence/ram-nor-read.json) compared two
4 KiB samples with an independently checked backup, then continued to OpenSBI
and U-Boot. It did not write NOR or test persistent boot.

A subsequent [NOR write and ROM digest verification](evidence/nor-write.json)
covered the selected SPL and FIT ranges on that sample; the verification did
not read back the entire device byte for byte. A separate
[battery-powered NOR boot](evidence/nor-os.json) with USB-C disconnected
reached the ESP_MOSAICO kernel and a single-user shell. Its FFS root is an
in-memory disk; repeated power cycles and NAND were not tested. After USB-C
was connected, the existing shell continued to accept input and produce
output; this did not test a separate power-on boot with USB-C attached.

A [bounded NOR littlefs check](evidence/ram-nor-littlefs.json) first passed
the full VFS checker against `flash1` after a RAM-loaded diagnostic boot. In a
separate ordinary POWER off/on without BOOT, the installed NOR SPL/FIT/kernel
mounted the littlefs root from `flash1` (10 MiB at 0x600000) and reached a
single-user shell. An earlier synced marker remained after this one normal power
cycle; the read-write remount and separate write/sync/read smoke check returned
0. The normal NOR boot did not repeat the full VFS checker. This does not test
sudden power loss, crash consistency, repeated-cycle reliability or endurance.

POWER is a toggle: one press turns the board on or off. The SAM8108 controls
whole-device power. V1.2's charge LED reports battery charge only: orange while
charging and white when full. V1.2 has no programmable GPIO3 LED or separate
3.3 V power LED. LED color does not identify processor power, USB connectivity,
or boot mode. To enter chip ROM Download Mode, start with the board off, hold
BOOT, then press POWER. BOOT is separate from the AI application button. USB
power can charge the board while it is off. See the vendor's
[hardware notes](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp-mosaico/user_guide.html#hardware-notes),
[revision details](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s31/esp-mosaico/user_guide.html#hardware-revision-details),
and [CoreBoard schematic, sheet 5](https://dl.espressif.com/AE/Mosaico/SCH_SCH_ESP-Mosaico_CoreBoard_V1_2_1_2026-09-24.pdf#page=5).
The Type-C connector carries USB 2.0 High-Speed OTG as well as power. Use a
data-capable cable. The vendor application supplies its USB CDC console, so
enumeration depends on the running application and its USB configuration.

White is also compatible with ROM Download Mode: a ROM security query succeeded
while the charge LED was reported white. No ROM idle timeout was established;
confirm the mode through a ROM response rather than the LED color
([bounded LED and ROM observation](evidence/charge-led-rom.json)).

## Distinct startup paths

| Path | Purpose and prerequisite |
| --- | --- |
| Normal application | Runs the selected application. ESP-Iris is available only if the application integrates and starts it. |
| Vibe Mode | Retained application installation and maintenance firmware. Hold AI while powering on; release when the mode starts. Working retained firmware and its bootloader are required. |
| ROM Download Mode | Chip ROM for low-level provisioning and recovery. From power-off, hold BOOT and press POWER. This mode does not run ESP-Iris. |

AI and BOOT are different buttons. The
[pinned device-mode guide](https://github.com/esp-mosaico/esp-mosaico-vibe/blob/1872fd88c01d7807556d01fd2a19864e40a307c9/docs/device-modes.md)
defines these paths. Vibe Mode can download an Idea over Wi-Fi; download and boot
selection are separate operations. The vendor's
[full firmware updater](https://mosaico.ai/en/firmware) uses USB and ROM mode.
ROM access and NOR backup verification were exercised in the
[ROM readback check](evidence/rom-readback.json). A later [bounded factory restore](evidence/factory-peripherals.json)
wrote only the two ranges replaced by the OS installation. A full 16 MiB NOR
digest check first matched the expected installed state; after writing, it matched
the original factory backup on that sample. This does not establish a general
recovery procedure or exercise the vendor updater or Vibe update path.

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
