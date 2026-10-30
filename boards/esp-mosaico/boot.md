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
None of these write or recovery paths has been exercised by this profile's evidence.

The cited tools describe a retained `vibe_mode` partition and a separate application.
Do not infer the installed partition table from a repository release or a screen version.
Use the vendor's current update-selection rules and establish recovery before replacing firmware.
The generic ESP32-S31 port's loader chain and flash-root layout are not a Mosaico installation recipe.

## Diagnose connectivity by layer

Check power-on, host USB enumeration and the console interface separately.
A network settings page can work without an enumerated USB console.
A missing serial port does not establish ROM mode, a defective cable or a failed driver.
Check the data cable, host accessory authorization and active firmware before choosing recovery.
WebUI live logs require the device's `Settings > Debug > Live Logs in WebUI` option.
The observed stream contains new messages; it does not recover the earlier boot log.

See the [vendor-firmware observation](evidence/vendor-webui.json) for the checked scope.
