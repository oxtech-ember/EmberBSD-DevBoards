# Interface and driver paths

| Interface or function | Integration entry | Boundary to check |
|---|---|---|
| eMMC | Module variant and EmberBSD UEFI/ACPI storage path | Boot, data integrity and recovery on that variant |
| Ethernet | `if_cemac_acpi` and carrier PHY/connector wiring | Link and traffic; repeated down/up is a separate scenario |
| Wi-Fi | `bwfm`, vendor radio firmware and `wpa_supplicant` | Required authentication, PMF, reconnect and throughput |
| GPU | Native V3D DRM path and Mesa in Ports | Accelerated HDMI Plasma and automatic startup checked; see [graphics](graphics.md) for prerequisites and limits |
| GPIO, I2C and camera | Module signals, carrier routing and pinmux | No general application acceptance in the cited board record |
| Cooling and power control | [Generic four-wire PWM fan profile](configs/thermal-fan/README.md), OS thermal policy and carrier wiring | Tested minimum duty and reboot persistence; another fan and cold starts need separate checks |

[The OS board record](https://github.com/oxtech-ember/EmberBSD/blob/39547d144888a9286ccc58304048efc68cd8e966/ember/boards/compute-module-5.md) preserves source evidence and driver links; this profile owns current hardware applicability.
The [shared Plasma service](https://github.com/oxtech-ember/EmberBSD-Ports/blob/main/probes/plasma-mobile/toolkit/service/README.md) owns the current package workflow and its physical HDMI boundary.
[The module datasheet](https://datasheets.raspberrypi.com/cm5/cm5-datasheet.pdf) owns signal and power constraints.
The [CM5-NANO-B pin map](../../carriers/cm5-nano-b/pins.md) applies only to that carrier.
It does not number the module connectors.

## Module-specific current limits

The bounded module record uses BCM2712 D0, module Rev 1.0, 4 GiB RAM and nominal 64 GB eMMC on CM5-NANO-B.
Carrier PCB revision and exact fan model were not established. Four cores, eMMC readback and file round trips passed.
Normal gigabit Ethernet traffic works; repeated administrative down/up and its interaction with Wi-Fi remain unqualified after an unexplained restart.
A source lifecycle repair alone does not establish the restart's cause.

CYW43455 firmware 7.45.265 has scoped WPA2/CCMP and SAE group 19/H2E with required PMF results.
Bidirectional 8 MiB data, reconnect, wrong-password rejection and warm reboot recovery passed in the accepted 5 GHz scenarios.
A later 2.4 GHz path had incomplete transfers; general throughput and sustained service remain unqualified.
CM5 Neighbor Reports do not inherit the SBC's separate BTM acceptance.

The fan evidence and current physical graphics boundary remain in their existing [fan profile](configs/thermal-fan/README.md) and [graphics reference](graphics.md).
Do not replace that newer HDMI evidence with an older virtual-output-only result.
The button fallback loads, but this module/carrier's physical PSW shutdown and restart remain unqualified.
Bluetooth, general GPIO/I2C, audio, RTC, watchdog and running-OS USB peripherals remain unvalidated in the cited module check.
USB recovery provisioning is a separate scenario.
Source: `os-cm5-reference` in [sources.json](../../sources.json).
