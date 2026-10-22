# Interfaces and current support

| Function | Current bounded evidence |
|---|---|
| CPU and memory | RV32IMAFC silicon, 16 MB PSRAM; one of two cores used |
| Ethernet | DesignWare GMAC, 100 Mbit/s with short rings |
| Wi-Fi | `ESP32S31W` and `espwifi`: WPA2 on 2.4 GHz; 6000 pings in 100 minutes without loss |
| Root and console | SPI-flash read-only root and firmware tty tested |
| Other paths | Second core, radio power saving, Bluetooth, 802.15.4 and USB unimplemented in the cited port |

Closed vendor radio libraries are linked into the kernel behind an OS shim. They are not supplied by this catalog or the cited OS tree.
The cited configuration obtains network selection from the device tree; keep credentials outside public artifacts.
I2C, audio, GPIO, RTC, watchdog, frequency control and random generation have no accepted port path in the source.
Network time replaces an RTC path. These software gaps do not prove absent silicon blocks.
The ping interval is bounded radio evidence, not general system stability.

Source: `os-esp32-s31-reference` in [sources.json](../../sources.json).
