# Interfaces and current support

| Function | Current bounded evidence |
|---|---|
| Boot, console and CPU | microSD boot, serial console and all cores tested in the inherited record |
| Wi-Fi | 2.4 GHz works; large transfers stall |
| Temperature | Sensor tested |
| Ethernet | No onboard port |
| Bluetooth, USB, I2C, audio and GPIO | Not validated |
| Watchdog, frequency control and random generator | Not validated |

No fan or onboard RTC is recorded. Long-duration stability is not established.
The source's absent regulator entry does not establish the board's electrical power topology.
A VM application result does not qualify this board's camera or graphics.

Source: `os-zero2w-reference` in [sources.json](../../sources.json).
