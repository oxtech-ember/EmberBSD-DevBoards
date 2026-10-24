# Interfaces and support limits

| Function | Current evidence |
|---|---|
| SoC | The vendor identifies Zynq-7010. An independent project reports XC7Z010-CLG400; the tested package marking and PCB revision remain unknown. |
| Memory and storage | The tested variant reported 512 MiB RAM and 32 MiB QSPI. This does not resolve conflicting vendor claims for other variants. EmberBSD used a 12 MiB FFS RAM root. |
| RF transceiver | The live tree selects AD9363A and the family product ID reads 0x0a. Finite RX1 capture and tuning across 325 MHz–3.8 GHz passed on the recorded configuration. |
| FPGA RX path | The original device bitstream exposed AXI-DMAC 4.5.c, ADC 10.3 and PS SPI0. RX DMA at 0x7C400000 used FIFO-to-memory mode. ADC at 0x79020000 required FCLK0 for register access. The RF reference was 40 MHz. These facts apply to the recorded FPGA image. |
| UART | Separate USB-C CH340 path, PS UART1 at 0xE0001000, 115200 baud, 8N1; EmberBSD console verified. |
| USB data | Stock firmware access was observed. USB networking, IIO service and mass storage under EmberBSD remain unqualified. The RX kernel disabled the USB controller. |
| RX application | The default sweep completed 1160 centers. Explicit experimental RX opt-in also completed 1978 centers from 70 MHz to 6 GHz. Capture, PLL checks and TX inhibition passed; RF calibration remains unqualified. |
| TX | Disabled in the RX configuration. No TX sample submission or RF transmission was part of this scenario. |

See [physical evidence](evidence/ram-rx.json) for source and artifact pins.
No calibrated dBm, antenna band coverage, frequency accuracy or continuous-stream claim is made.
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
