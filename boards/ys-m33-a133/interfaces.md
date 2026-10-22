# Interfaces and software ownership

| Path | Hardware | EmberBSD evidence and limits |
|---|---|---|
| USB-C device connection | USB-C port used for host access; separate DC power is required during the tested installation | ADB inspection and signed recovery were used on one unopened factory sample. Cable-role negotiation and factory-image access must be checked on each device. |
| eMMC | 32 GB eMMC on the recorded sample | EmberBSD boot, root and resource areas were installed with full readback hashes on one sample. Do not reuse its partition assumptions without fresh inspection. |
| Ethernet | IP101 10/100 PHY | Ethernet SSH and file transfer were checked after installation on one sample. This is separate from the USB installation path. |
| UART | J1 serial console exists on the board | The closed-enclosure installation scenario did not use UART. Connector pin mapping is not established by this profile. |
| Wi-Fi | RTL8723DS SDIO device is present | Radio initialization and network association are not implemented in the cited EmberBSD board record. |

The OS owns kernel, device-tree, installation and executable-check details.
Follow the exact [EmberBSD board record](https://github.com/oxtech-ember/EmberBSD/blob/12c35f22fd899b4d697e20986521226efaf6d8cb/ember/boards/ys-m33-a133.md) and [cable installation guide](https://github.com/oxtech-ember/EmberBSD/blob/12c35f22fd899b4d697e20986521226efaf6d8cb/ember/boards/ys-m33-a133-cable-install.md).
