# Interfaces and support limits

| Function | Current evidence |
|---|---|
| SoC | The vendor identifies Zynq-7010. An independent project reports XC7Z010-CLG400; the tested package marking and PCB revision remain unknown. |
| Memory and storage | The tested variant reported 512 MiB RAM and 32 MiB QSPI. This does not resolve conflicting vendor claims for other variants. EmberBSD used a 12 MiB FFS RAM root. |
| RF transceiver | The live tree selects AD9363A and the family product ID reads 0x0a. Finite RX1 capture and tuning across 325 MHz–3.8 GHz passed on the recorded configuration. |
| FPGA RX path | The original device bitstream exposed AXI-DMAC 4.5.c, ADC 10.3 and PS SPI0. RX DMA at 0x7C400000 used FIFO-to-memory mode. ADC at 0x79020000 required FCLK0 for register access. The RF reference was 40 MHz. These facts apply to the recorded FPGA image. |
| UART | Separate USB-C CH340 path, PS UART1 at 0xE0001000, 115200 baud, 8N1; EmberBSD console verified. |
| USB data | Stock firmware access was observed. USB networking, IIO service and mass storage under EmberBSD remain unqualified. The RX kernel disabled the USB controller. |
| RX application | A static ARMv7 hard-float scanner completed all 1160 centers in one finite sweep. A shifted 935–960 MHz repeat also returned zero. |
| TX | Disabled in the RX configuration. No TX sample submission or RF transmission was part of this scenario. |

See [physical evidence](evidence/ram-rx.json) for source and artifact pins.
No calibrated dBm, antenna band coverage, frequency accuracy or continuous-stream claim is made.
A telescopic antenna can receive signals without providing uniform sensitivity across the tuning range.
The local GCC16 experiment is not a qualified SDK release.
