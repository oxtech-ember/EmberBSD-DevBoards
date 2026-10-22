# Interfaces and current support

The reference sample and the unopened installation sample have different evidence scopes.
Board and panel assembly revisions are unknown. The first sample supplies the peripheral checks below.
The closed-enclosure sample supplies [installation evidence](evidence/cable-install.json); attachment there does not repeat touch or audio acceptance.

| Function | Hardware and current bounded evidence |
|---|---|
| CPU and storage | Four Cortex-A53 cores; 1 GiB RAM and nominal 32 GB eMMC; FFSv2 root within UDISK |
| Ethernet | IP101 PHY, 100 Mbit/s full duplex; SSH and image transfer |
| Display | Vendor scanout, genfb and software wsfb; landscape 1280×800 desktop. No GPU acceleration acceptance |
| Touch | GT9271 firmware 1020 at TWI3 address 0x5d; physical press, drag, release and landscape directions |
| I2C | S_TWI0 for MCU/PMIC/RTC and TWI3 for touch; other buses unvalidated |
| Watchdog | MCU7502 firmware 17.03.07; keepalive works, stopping it can cycle power |
| RTC | PCF8563 reads and retained time across reboot |
| Audio | Bounded audible playback, MIC1 capture and simultaneous streams; one processed phrase intelligible |
| USB-A | EHCI/OHCI, powered four-port hub and one CDC serial device through ordinary eMMC reboot |
| Wi-Fi | RTL8723DS SDIO discovery, register reads and function-ready/restore only; no network interface |
| Bluetooth and USB-C peripherals | Not validated |

Touch exposes one wscons pointer polled every 20 ms. Multitouch, interrupt-driven input and suspend/resume are unvalidated.
The framebuffer rotates clockwise. Observed touch coordinates already increase right/down in the landscape mount.
The sample's Xorg adaptation does not establish a published shared graphics package.

## Wiring and ownership

TWI3 uses PH12/PH13 in i2c3 mode. PH13 is touch SDA, not an Ethernet clock.
Ethernet uses PH9/PH10 and PH11 PHY reset. Touch reset uses PH14 and PL10 for INT/address selection.
The reset sequence must preserve PL0/PL1 for the MCU bus. Do not transfer this wiring to another panel.

USB1 uses OHCI base 0x05200400. Its internal hub and downstream power gates use PF0, PF2, PF3, PF4 and PF5.
PF6 belongs to audio. USB0/USB-C ownership remains separate.
In the vendor seven-cell GPIO binding, the mux-selection cell is not a native active-low flag.
The OS FDT and GPIO implementations own conversion and validation.

## Audio boundary

Speaker and MIC1 routes start disabled. Explicit routing is required; the driver never records or plays automatically at boot.
The hardware scenarios used 48 kHz stereo playback and 48 kHz mono capture; 16 kHz files passed through MI conversion.
Raw microphone level is low and startup clipping remains unexplained. One phrase became intelligible after startup trimming, DC removal and application gain.
This does not qualify general speech quality, latency, acoustic level or sustained duplex. Pickup versus electrical crosstalk remains unisolated.
PF6-low direct-register playback was audible, but amplifier polarity was not isolated by a confirmed high-state comparison.
AVCC and CPVIN are 1.8 V; do not substitute 3.3 V supplies. DMA and suspend/resume are unaccepted.

## Radio boundary

MMC1 uses PG0–PG5 at four-bit width and 25 MHz in the bounded diagnostic.
Common CIS identifies 024c:d723; per-function MANFID is absent.
CMD52 register reads and function 1 readiness/restoration succeeded in RAM-only diagnostics.
These results do not establish cold power sequencing, firmware loading, CMD53 traffic, SDIO interrupts or association.
The diagnostic opt-ins and exact resource guards belong to the OS implementation.

Sources: `os-ys-m33-reference`, `os-a133-audio-driver`, `os-a133-audio-streams`, `os-a133-usb-host`,
`os-a133-sdio-probe`, `os-a133-rtl8723ds-read` and `os-a133-rtl8723ds-function` in [sources.json](../../sources.json).
