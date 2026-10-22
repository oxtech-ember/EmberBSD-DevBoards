# Interfaces and current support

| Function | Current bounded evidence |
|---|---|
| Ethernet | Gigabit with Motorcomm YT8531; board RGMII delays measured with random data |
| Wi-Fi | AIC8800D80 WPA2/CCMP, 2.4 and 5 GHz, one-stream 802.11n up to 40 MHz; 30–48 Mbit/s through SSH at 5 GHz |
| Bluetooth | Classic inquiry, service query, Secure Connections pairing and stored-key reconnect; BLE unsupported in the cited implementation |
| CPU and temperature | Eight cores, five calibrated sensors and speed-grade 0x04 voltage/frequency operation |
| PMIC and I2C | AXP8191 outputs read, two core supplies driven; always-on I2C works |
| GPIO | Pinmux and outputs tested; pin interrupts absent |
| RTC and watchdog | RTC retained time across reboot; watchdog tested |
| USB-C | High-speed storage read at 22 MB/s; one plug orientation; SuperSpeed untested |
| USB-A controllers | EHCI/OHCI attach; external devices not tested |
| Random generator | Crypto engine generator seeds the kernel |
| Audio and fan | No accepted audio or fan-control path |
| GPU/NPU | Software power/clock contracts exist; no board-specific accelerator acceptance |

Wi-Fi requires `fmacfw_8800d80_u02.bin`; Bluetooth requires four vendor patch files.
Their implementation owner is EmberBSD `aicwf`; firmware is not redistributed by this catalog.
The cited profile does not advertise 802.11ac or 802.11ax.
Do not import newer Zero 3W radio or accelerator results as Zero 4 acceptance.

FUSB302 polls the Type-C connection and gates VBUS through PL8. SuperSpeed PHY lock alone does not prove USB3 traffic.
The controller bus clock must remain 24 MHz for frame timing.
The source reports no sustained-use acceptance.

Source: `os-zero4-reference` in [sources.json](../../sources.json).
