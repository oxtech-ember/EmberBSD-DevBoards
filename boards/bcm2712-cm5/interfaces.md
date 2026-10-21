# Interface and driver paths

| Interface or function | Integration entry | Boundary to check |
|---|---|---|
| eMMC | Module variant and EmberBSD UEFI/ACPI storage path | Boot, data integrity and recovery on that variant |
| Ethernet | `if_cemac_acpi` and carrier PHY/connector wiring | Link and traffic; repeated down/up is a separate scenario |
| Wi-Fi | `bwfm`, vendor radio firmware and `wpa_supplicant` | Required authentication, PMF, reconnect and throughput |
| GPU | Native V3D DRM path and Mesa in Ports | Accelerated HDMI Plasma and automatic startup checked; see [graphics](graphics.md) for prerequisites and limits |
| GPIO, I2C and camera | Module signals, carrier routing and pinmux | No general application acceptance in the cited board record |
| Cooling and power control | [Generic four-wire PWM fan profile](configs/thermal-fan/README.md), OS thermal policy and carrier wiring | Tested minimum duty and reboot persistence; another fan and cold starts need separate checks |

[The OS board record](https://github.com/oxtech-ember/EmberBSD/blob/39547d144888a9286ccc58304048efc68cd8e966/ember/boards/compute-module-5.md) owns the support evidence and driver links.
The [shared Plasma service](https://github.com/oxtech-ember/EmberBSD-Ports/blob/main/probes/plasma-mobile/toolkit/service/README.md) owns the current package workflow and its physical HDMI boundary.
[The module datasheet](https://datasheets.raspberrypi.com/cm5/cm5-datasheet.pdf) owns signal and power constraints.
The [CM5-NANO-B pin map](../../carriers/cm5-nano-b/pins.md) applies only to that carrier.
It does not number the module connectors.
