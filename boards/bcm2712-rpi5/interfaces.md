# Interface and driver paths

| Research path | Implementation owner | Check before reuse |
|---|---|---|
| Ethernet and Wi-Fi | EmberBSD board record, `cemac`/`bwfm`, vendor radio firmware | Link lifecycle, authentication and sustained traffic |
| I2C audio | OS WM8960 codec/HAT path | Exact HAT, pinmux, clock and audio stream |
| USB | OS host-controller drivers and control-recovery checks | Required transfer type, peripheral and power budget |
| GPIO and high-speed connectors | Exact SBC hardware documentation and OS description | Physical pin map and complete peripheral operation |
| Display/GPU | OS graphics and Ports Mesa stack | Independent SBC display and render evidence |

The WM8960 result does not qualify an arbitrary codec or every I2C peripheral.
The USB control-transfer check does not qualify bulk or isochronous transfers.
A module's V3D result does not qualify this SBC's display path.
Pin numbers are intentionally absent until their source and viewing orientation are established.
Source: [the pinned OS board record](https://github.com/oxtech-ember/EmberBSD/blob/39547d144888a9286ccc58304048efc68cd8e966/ember/boards/raspberry-pi-5.md), ID `os-rpi5`.

## Current bounded support

The original profile names C1; later checks report an 8 GiB SBC with DMI `D04170`.
DMI alone does not establish silicon revision. Firmware and kernel pins differ between scenarios.
MicroSD/UEFI/ACPI boot, all cores, Ethernet, temperature, fan, watchdog and CPU frequency control have published physical results.
The power-button scenario powers off and powers on by a later press. Classic Bluetooth works; BLE is not accepted.
GPIO, RTC, regulators and hardware random generation remain unvalidated in the cited record.

WPA2/CCMP traffic passed a bounded 1 GiB transfer with exact returned bytes on 5 GHz VHT80 with one stream.
DHCP reconnect, fallback and return were checked with IPv4LL enabled. Receive errors occurred, so this is not a zero-error radio result.
SAE/required PMF, Neighbor Reports and host-managed BTM acceptance/rejection belong to a separately scoped mesh scenario.
Those results do not establish every AP, seamless roaming or endurance.

USB evidence is limited to 1024 descriptor reads and 1024 STALL/recovery requests to one high-speed device.
The check does not qualify bulk, isochronous, sustained load, power management or another device's boot path.
The historical base-update result did not establish installed-library acceptance after its final reboot.
Later network success does not retroactively qualify that entire base update, camera or GPU operation.
Source: `os-rpi5-reference` in [sources.json](../../sources.json).

## Accessory and Bluetooth boundary

The WM8960 HAT check confirmed microphones and speaker output. Loudness depends
on the attached speakers. One USB Audio Module A repeatedly disconnected during
playback; stable playback is not confirmed. A classic Bluetooth headset connected,
but reliable audio quality and microphone operation remain unconfirmed. There is
no physical ELM327 adapter acceptance.

The UART Bluetooth check covered the H4 receive correction, SSP/Secure Connections,
authentication, encryption and reconnection with one phone peer. It does not
qualify arbitrary peers or headset audio. BLE is not implemented in the added
Bluetooth management tools. Source: `os-accessory-boundaries` in
[sources.json](../../sources.json).
