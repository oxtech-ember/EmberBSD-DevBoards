# Interfaces

## UART0 console

Use the physical contact numbers on header PI1. With the component side up, the microSD slot at the top and PI1 on the right,
the even contacts run down the outer edge. Pin 2 is closest to the microSD end.
Use a 3.3 V TTL adapter at 1,500,000 baud, 8 data bits, no parity, one stop bit, no flow control.
Power H3 separately and leave the adapter power lead open.

| PI1 contact | SoC pad | Board direction | Adapter connection |
|---:|---|---|---|
| 6 | GND | Common ground | GND |
| 8 | GPIO0_C6 / UART0_TX | Output | RX |
| 10 | GPIO0_C7 / UART0_RX | Input | TX |

Sources cover the PI1 connector, the UART0 pad functions and the board-specific wiring image.
[Zero W schematic](https://github.com/LuckfoxTECH/Luckfox-Lyra-docs/blob/4d6c261ba996937b420e19494a6ff8e5cd0ccbbb/Hardware/Schematic/Luckfox-Lyra-Zero-W.pdf) · [RK3506B data sheet](../../socs/rockchip-rk3506b.md) · [Luckfox serial login](https://wiki.luckfox.com/Luckfox-Lyra/Login/)

## MicroSD

TF1 uses four data lines at 3.3 V. The vendor DTS selects up to 52 MHz, disables SDIO and sets active-low card detect on GPIO1_B6.
The clock uses GPIO3_A0, command uses GPIO3_A1 and DAT0–DAT3 use GPIO3_A2–A5. Check the card identity and read data through the kernel before mounting root.
[Zero W SD device tree](https://github.com/EliSofke/LuckfoxLyraSDK/blob/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/kernel-6.1/arch/arm/boot/dts/rk3506b-luckfox-lyra-zero-w-sd.dts)

## USB, Wi-Fi and antenna selection

The vendor DTS sets OTG0 to peripheral mode on H3 and OTG1 to host mode.
OTG1 feeds the CH334F hub (U4). Hub port 1 connects to the radio (U10), port 2 to the USB-C host connector (H1),
and port 3 to the four-contact USB header (H5). The schematic identifies U10 as `SKI.WB800DCS.2`.
Luckfox identifies its wireless chip as AIC8800DC. The USB driver matches `a69c:88dc` and the Wi-Fi interface class/subclass/protocol `ff/ff/ff`.
Factory Linux enumerated the hub at 1-1 and the radio at 1-1.1. Its wireless service initialized the module. [Reset observation](evidence/factory-reset-uart.json) [Schematic](https://github.com/LuckfoxTECH/Luckfox-Lyra-docs/blob/4d6c261ba996937b420e19494a6ff8e5cd0ccbbb/Hardware/Schematic/Luckfox-Lyra-Zero-W.pdf) · [SDK USB driver](https://github.com/EliSofke/LuckfoxLyraSDK/tree/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/external/rkwifibt/drivers/aic8800/aic8800/aic8800_fdrv)

With the factory driver active, USB configuration 1 groups Bluetooth interfaces 0 and 1. Wi-Fi uses interface 2, alternate setting 0.
Its four bulk endpoints have a maximum packet size of 512 bytes. The vendor driver uses 0x01/0x81 for data and 0x02/0x82 for commands. [Measured descriptors](evidence/radio-usb-descriptors.json) · [Vendor USB driver and build options](https://github.com/EliSofke/LuckfoxLyraSDK/tree/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/external/rkwifibt/drivers/aic8800/aic8800/aic8800_fdrv)

U12 supplies the radio with 3.3 V from the 5 V system rail. GPIO1_C5 controls `WIFI_PWRKEY` at U10 pin 12 (`WL_DIS#`).
R77 pulls it high to enable the radio. GPIO1_C7 controls RF switch U9. Low selects the external antenna socket, the default.
High selects the onboard antenna. The vendor Linux number for GPIO1_C7 is 55. [Luckfox Zero W radio guide](https://wiki.luckfox.com/Luckfox-Lyra/Luckfox-Lyra-Zero-W/WIFI-BT/)
The EmberBSD board driver controls GPIO1_C5 before DWC2 attaches. It holds the signal low for 20 ms and waits 20 ms after driving it high.
It retains a high output from an earlier boot stage. An input held high by R77 still requires the enable sequence. [EmberBSD board driver](https://github.com/oxtech-ember/EmberBSD/blob/fb17c849f50162762a0c4ce14647bf049cc9518c/sys/arch/arm/rockchip/rk3506_radio.c)

A RAM boot of Luckfox Linux confirmed GPIO55 high and 19 BSS entries after a fresh scan.
The station completed WPA3-SAE association on 2.4 GHz and obtained a DHCP lease. [Vendor Linux station check](evidence/radio-oem-station.json)

On Linux, the same USB WLAN interface reopened after driver unbind and bind. Both probes read the WLAN patch and its table.
The driver checked DPD during both probes. The observer recorded the U02 calibration program read inside the DPD function only during the first probe. With one USB device reset between binds, the driver read the calibration program inside the DPD function on both probes. All interface opens succeeded. [Factory WLAN rebind](evidence/radio-oem-rebind.json)

EmberBSD's `aicwf` driver matches AIC8800D80 SDIO function 1 with ID `c8a1:0082`.
The EmberBSD GENERIC kernel attached the RK3506 USB PHY and DWC2 host. It found the hub and the AIC8800DC at hub port 1. The first console kernel attached the radio as `ugen0`. [Physical USB and console observation](evidence/sd-console.json)
The `uaicfw0` driver selected configuration 1, interface 2. The radio reported chip ID `0x07`, sub-ID `0x01`, FullMAC version `0x06040301` and feature bits `0xb011fa5f`. The SDK supplies revision-specific radio patches and calibration files. [USB command-channel test after RESET](evidence/radio-usb-fullmac.json)
On the tested U02 radio, EmberBSD read the factory USB and baseband PLL conditions after the WLAN enable sequence. The factory conditions called for skipping both branches. The clock check reported no CPU crystal. [Native startup conditions](evidence/radio-usb-calibration.json)
On cold boot, the diagnostic kernel read the same radio IDs and FullMAC version. The DWC2 root hub reported `illegal enable change`.
The downstream hub and WLAN interface enumerated. Firmware returned status 1 to the request to create a station (`MM_ADD_IF_REQ`).
The diagnostic recorded no scan completion or beacon. The kernel exposed no WLAN interface to WPA or DHCP.
Multi-user init started `mdnsd` and `sshd`. SSH over Wi-Fi still requires a working association and IP configuration. [Cold boot observation](evidence/sd-multiuser.json)

After `/sbin/shutdown -r now`, the kernel loaded from microSD attached the receive-only station `aicwf0` to `uaicfw0`.
At the root console, `ifconfig aicwf0 up` succeeded. The scan command is `ifconfig aicwf0 list scan`.
With the earlier f0cb3f42 kernel, ifconfig returned status 0 and printed zero rows. The interface reported `status: no network`.
A host authenticated by SSH public key through a UART relay to the board loopback interface.
The native diagnostic kernel ran before and after a software reboot from a working Luckfox Linux station.
In each boot, both scan attempts stopped at station creation with firmware status 1. The matching ifconfig reported `EIO`.
The GENERIC kernel with the `c6531633` kernel sources booted from microSD, sequenced WLAN enable before DWC2, attached `aicwf0` and started `sshd`.
It reported that both factory USB and BBPLL setup conditions were false. The preceding `fb17c849` kernel and device tree provide the rollback.
Both trial scans returned `EIO`. After the normal boot, a new scan exited with status 1. Firmware returned status 1 during station creation.
The supplicant remained disconnected. Wi-Fi had no DHCP lease. A direct SSH attempt stopped at host name resolution.
[Physical station check](evidence/radio-usb-station.json) · [EmberBSD ifconfig implementation](https://github.com/oxtech-ember/EmberBSD/blob/e485e7de2689b7c1226b4803c1934adabdd7f071/sbin/ifconfig/ieee80211.c)

A later EmberBSD RAM diagnostic read GPIO1_C5 high as an input and GPIO1_C7 high as an output after root mount.
The onboard antenna was selected. The radio confirmed stack start, the transmit power setting and four RF table commands.
A factory comparison matched the outgoing stack request, transmit power and four RF settings byte for byte. Both fields in the stack confirmation also matched. [Factory command comparisons](evidence/radio-oem-station.json)
The first calibration request timed out after four seconds. A repeat after a successful Linux association waited eight seconds for calibration.
One subsequent firmware version query timed out after four seconds. Neither bulk IN endpoint returned a valid configuration record during those twelve seconds.
The radio stayed attached to USB in both captures. EmberBSD stopped before station attachment.
In a separate run without RF setup, the radio answered the MAC address query. During the reset request, the driver reported an error and USB enumerated the radio again.
After the calibration timeout, Linux scanned again without a power cycle. In a separate handoff test, Linux brought its wireless interface down and kept the USB driver bound.
After the software reboot, EmberBSD reported a bulk IN error during the first station start (`MM_START`). The radio enumerated again.
Only `lo0` appeared in single-user mode. Station creation and scan did not run. [Native initialization and handoff checks](evidence/radio-usb-calibration.json)

Direct ARM kexec also retained WL_DIS# high. One native kernel encountered a bulk IN error during first station start. A second received seven startup confirmations, then timed out at RF calibration. Both kernels mounted the EmberBSD root. [Direct handoff and radio checks](evidence/radio-kexec.json)

Bluetooth has a separate USB interface and needs its own check.
[EmberBSD SDIO match](https://github.com/oxtech-ember/EmberBSD/blob/5789d27f00d9c1694b5085730b067e32cd846915/sys/dev/sdmmc/if_aicwf.c) · [SDK DC firmware inventory](https://github.com/EliSofke/LuckfoxLyraSDK/tree/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/external/rkwifibt/firmware/aicsemi/aic8800DC)
