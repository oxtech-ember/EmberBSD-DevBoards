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
The factory Linux log shows the hub at 1-1 and a device at 1-1.1. Its wireless service selected AIC8800DC and reported successful initialization. [Reset observation](evidence/factory-reset-uart.json) [Schematic](https://github.com/LuckfoxTECH/Luckfox-Lyra-docs/blob/4d6c261ba996937b420e19494a6ff8e5cd0ccbbb/Hardware/Schematic/Luckfox-Lyra-Zero-W.pdf) · [SDK USB driver](https://github.com/EliSofke/LuckfoxLyraSDK/tree/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/external/rkwifibt/drivers/aic8800/aic8800/aic8800_fdrv)

U12 supplies the radio with 3.3 V from the 5 V system rail. GPIO1_C5 controls `WIFI_PWRKEY` at U10 pin 12 (`WL_DIS#`).
R77 pulls it high to enable the radio. GPIO1_C7 controls RF switch U9. Low selects the external antenna socket, the default.
High selects the onboard antenna. The vendor Linux number for GPIO1_C7 is 55. [Luckfox Zero W radio guide](https://wiki.luckfox.com/Luckfox-Lyra/Luckfox-Lyra-Zero-W/WIFI-BT/)

EmberBSD's `aicwf` driver matches AIC8800D80 SDIO function 1 with ID `c8a1:0082`.
The Zero W needs the RK3506 USB PHY and DWC2 host, hub enumeration, a USB AIC8800DC transport and matching DC firmware patches.
The SDK supplies revision-specific radio patches and calibration files. Establish the chip revision and firmware inputs before testing association.
Bluetooth has a separate USB interface and needs its own check.
[EmberBSD SDIO match](https://github.com/oxtech-ember/EmberBSD/blob/5789d27f00d9c1694b5085730b067e32cd846915/sys/dev/sdmmc/if_aicwf.c) · [SDK DC firmware inventory](https://github.com/EliSofke/LuckfoxLyraSDK/tree/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/external/rkwifibt/firmware/aicsemi/aic8800DC)
