# HamGeek PlutoSDR Nano

This profile identifies the HamGeek product variant named Development Board for PlutoSDR Nano. The product page also describes related Zynq7010 and AD9363 boards. It mixes variant claims: the overview mentions 1 GB memory and SD boot, while the detailed specification lists 512 MB DDR3 and 32 MB QSPI. Treat these as vendor claims that do not identify the exact memory or storage on every Nano unit. The board revision is unknown.

An independent project reports the Nano as XC7Z010-CLG400 and publishes a measured FPGA pin map. The ADALM-PLUTO Rev.B reference uses a different XC7Z010 package, CLG225. Do not reuse its board-specific FPGA pin assignments or boot image for Nano.

A bounded RAM-only EmberBSD boot and finite RX scenario is verified on one Nano variant.
The original device FPGA image was loaded into volatile fabric.
A complete 325 MHz–3.8 GHz sweep covered 1160 centers and returned zero.
See the [physical evidence](evidence/ram-rx.json) for exact inputs and exclusions.
An explicit experimental RX mode also completed a 1978-center 70 MHz–6 GHz sweep.
The default AD9363 limits and the 20 MHz RF bandwidth limit remain unchanged.
See [extended RX evidence](evidence/extended-rx.json); this does not qualify out-of-band analog performance.
Neither scenario establishes persistent installation or support for every Nano revision.

Experimental native USB peripheral and USB IIO RX passed on one Nano unit in a RAM-only boot.
The no-FIR profile requested 2.4 MSPS and reported 2399999 complex samples/s.
This opt-in scenario does not enable USB in the default boot path.
See [interfaces and support limits](interfaces.md#native-usb-and-iio-rx) for sources and exclusions.

[Machine-readable profile](board.json) · [Boot and recovery](boot.md) · [Interfaces](interfaces.md) · [Design transfer](design.md)
