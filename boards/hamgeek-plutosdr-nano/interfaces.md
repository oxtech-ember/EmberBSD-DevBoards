# Interfaces and support limits

| Function | Current evidence |
|---|---|
| SoC | The vendor identifies Zynq-7010. An independent project reports XC7Z010-CLG400; the tested package marking and PCB revision remain unknown. |
| Memory and storage | The tested variant reported 512 MiB RAM and 32 MiB QSPI. This does not resolve conflicting vendor claims for other variants. EmberBSD used a 12 MiB FFS RAM root. |
| RF transceiver | The live tree selects AD9363A and the family product ID reads 0x0a. Finite RX1 capture and tuning across 325 MHz–3.8 GHz passed on the recorded configuration. |
| FPGA RX path | The original device bitstream exposed AXI-DMAC 4.5.c, ADC 10.3 and PS SPI0. RX DMA at 0x7C400000 used FIFO-to-memory mode. ADC at 0x79020000 required FCLK0 for register access. The RF reference was 40 MHz. These facts apply to the recorded FPGA image. |
| UART | Separate USB-C CH340 path, PS UART1 at 0xE0001000, 115200 baud, 8N1; EmberBSD console verified. |
| USB data | Native USB peripheral counter and USB IIO RX passed on one Nano unit. See the bounded scenario below. USB networking and mass storage remain unqualified. |
| RX application | The default sweep completed 1160 centers. Explicit experimental RX opt-in also completed 1978 centers from 70 MHz to 6 GHz. Capture, PLL checks and TX inhibition passed; RF calibration remains unqualified. |
| TX | Disabled in the RX configuration. No TX sample submission or RF transmission was part of this scenario. |

See [physical evidence](evidence/ram-rx.json) for source and artifact pins.
No calibrated dBm, antenna band coverage or frequency accuracy claim is made.
A telescopic antenna can receive signals without providing uniform sensitivity across the tuning range.
The local GCC16 experiment is not a qualified SDK release.

## Experimental receive range

The boolean `emberbsd,experimental-rx-extended-range` property opts an AD9363
receive-only instance into 70 MHz–6 GHz tuning. Device identity stays AD9363;
the 20 MHz RF bandwidth limit and transmitter limits remain unchanged.
The property is rejected for TX and other chip models.
The default path continues to enforce 325–3800 MHz.

This changes driver admission, not the physical filters, matching network or antenna.
A complete tuning sweep does not measure calibrated sensitivity or frequency accuracy.
No frequency below 70 MHz is accepted, including the 27 MHz CB band.
See [extended RX evidence](evidence/extended-rx.json) and the
[owning driver contract](https://github.com/oxtech-ember/EmberBSD/blob/7880482cfbb2d4b2e25a6ff76170f2af0cb9e172/sys/external/bsd/ad9361/README).

## Native USB and IIO RX

One unit passed RAM-only native USB peripheral and USB IIO RX checks.
This experimental path requires an enabled USB node with explicit peripheral role and ULPI PHY selection.
The default boot path keeps USB disabled; no generic installer or ready-to-flash image is qualified.
The no-FIR profile requested 2.4 MSPS and reported 2399999 complex samples/s.
Bounded multi-block transfers and alternating 1090 MHz/162 MHz windows returned zero native loss counters.
A 1090 MHz run received 289538048 complex samples with zero native/software loss reports.
This equals 120.64 seconds at the reported rate; the host stop timer was 125 seconds.
An independent CRC check accepted 32 received DF17 messages in this run.
LO-only retuning preserved the common sample rate; actual-rate read/write roundtrips preserved the requested profile.
A USB counter transfer ran for 30 minutes at 14.28 MB/s with verified payload ordering.
The counter result measures USB transport, not sustained RF sample throughput.
These bounded checks do not establish indefinite RF stability or independent per-sample continuity.
With 16 buffers and 32768-sample refills, an 81.68 ms host pause completed without reported loss.
A 253.66 ms pause correctly returned overflow and unknown loss; a fresh recovery epoch then passed.
These host pauses do not measure a universal buffer capacity or physical RF gap.
See [native RX evidence](evidence/native-usb-iio-rx.json) for the exact scope.

Sources: [native drivers](https://github.com/oxtech-ember/EmberBSD/blob/ec4a6f9e6d0b3f268b44732ffadeb620bb03f9f1/sys/arch/arm/xilinx/docs/zynq-usb-device.md)
and [IIO service](https://github.com/oxtech-ember/EmberBSD-Examples/tree/93a1ffbacc3a9b4bdef2695f0cb52e149ae14f3f/robotics/pluto-iio).
This experimental scenario does not qualify other units or revisions.
AIS RF message reception, GUI integration, CPR position decoding and persistent installation remain unqualified.
The no-FIR path rejects 1.536 MSPS; FIR configuration remains unsupported.
