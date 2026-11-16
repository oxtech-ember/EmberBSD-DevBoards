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
after a normal POWER press. Its FFS root is an in-memory disk, so that boot did
not test writes to a persistent filesystem. NAND, full PSRAM read/write and
general application support remain unverified.

A [bounded NOR littlefs check](evidence/ram-nor-littlefs.json) on the
reported V1.2 sample boots the NOR SPL/FIT/kernel and mounts littlefs from
`flash1` (10 MiB at 0x600000) to a single-user shell after a normal POWER
cycle without BOOT. Read-write remount, tmpfs on `/tmp` and `/var/run`, and
separate `/dev/null` `O_APPEND` and `O_TRUNC` checks passed. The RAM-loaded
diagnostic scenario separately passed the full VFS checker. Exact image inputs
and evidence scope are in [the check record](evidence/ram-nor-littlefs.json).
Sudden-power-loss durability, repeated-cycle reliability, endurance, full
services, NAND and full PSRAM read/write remain unverified.

The separate [RAM littlefs acceptance](evidence/ram-littlefs.json) remains
evidence for the RAM-root path; its filesystem image was loaded into RAM and it
did not test NOR filesystem access.

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

The [earlier WPA association baseline](evidence/wifi-association.json) records bounded WPA2/SAE completion, IPv4/DNS and gateway reachability from previous runs. The historical [kernel #30 record](evidence/wifi-connected-scan-roam.json) documents an unsuccessful roam attempt.

A bounded [SSH diagnostic profile](evidence/ssh-diagnostics.json) passed on one reported V1.2 sample after ordinary NOR boot: pinned-host-key Ed25519 access, PTY, dmesg read, and byte-verified file transfers, with WPA/IPv4 still present afterward. Its local logging and mDNS checks used the then-installed root; its mDNS answer required one `mdnsd` restart while WPA/IPv4 were active. A separate [cold-start mDNS and logging check](evidence/mdns-cold-start.json) passed after writing a new 10 MiB root while preserving FIT #33 and SPL: after ordinary POWER boot, syslogd started, WPA/IPv4 were available, and mDNS A, `getaddrinfo`, and strict pinned-key SSH by name passed without restarting mdnsd. The cold-start result is one bounded boot; repeated reliability and full Wi-Fi behavior remain unestablished. Neither record establishes peer acknowledgement of Wi-Fi TX, RRM or BTM acceptance.

In a later ordinary NOR boot, the [44b FIT connected-scan and roam record](evidence/wifi-connected-scan-roam-nor.json) passed a bounded strict-SAE probe: the connected scan preserved the baseline association, and ROAM reached the requested alternate BSSID, which matched the final BSSID and differed from baseline. Post-roam status remained WPA_COMPLETED/SAE/PMF=1; the selected check helper read IPv4 from `wpa_cli status`, and DNS plus gateway ping passed. This is one successful roam scenario on one reported V1.2 sample.

A separate temporary WPA2-PSK profile reached WPA2-PSK/COMPLETED and host ping passed in the earlier [immutable observation](https://github.com/oxtech-ember/EmberBSD-DevBoards/blob/9d598e40eed77c84e7894f742510973b3dfd3985/boards/esp-mosaico/evidence/wifi-connected-scan-roam-nor.json). A later router-side association view showed WPA3-PSK/PMF restored on the original AP. The shared station Action path is integrated. On the 44b FIT and refreshed LittleFS root, one ordinary NOR boot retained pinned-key SSH and WPA COMPLETED/SAE/PMF=1/IPv4 across a connected scan and station-initiated ROAM. Neighbor Report requests returned four entries at the initial AP and three at the alternate AP. Both APs advertised RRM/BTM capability. Each BTM query produced correlated TX completion, but firmware does not report peer ACK; no peer response arrived during either 12-second window, and no incoming BTM Request was seen after ROAM. The bounded run confirms the tested Neighbor Report exchanges, not a completed BTM peer exchange or full IEEE 802.11k/v behavior. See the [bounded Action transport observation](evidence/wifi-action-transport.json). AP-initiated BTM/802.11v and 802.11r, forged-frame protection, throughput and sustained reliability remain unverified.

A separate RAM-only follow-up used the reviewed association-capability changes later published in [OS commit 107b018](https://github.com/oxtech-ember/EmberBSD/commit/107b01843ada72042c0be9913f23bb352552ecfa), leaving NOR SPL/FIT/root unchanged. UART showed SAE/PMF=1 and IPv4; the live router association showed station k/v, and one Neighbor Report request returned three entries. BTM TX ACK is unknown and no peer request/response arrived in 12 seconds; SSH became available after recovery. This does not extend the 44b scan/roam evidence.

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
