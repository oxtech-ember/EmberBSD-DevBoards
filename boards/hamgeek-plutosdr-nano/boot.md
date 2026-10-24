# Boot and recovery

The vendor guide identifies separate USB-C data and UART connectors.
One Nano variant exposed stock Linux through the data port and a CH340 UART through the other port.
The UART gave the PS UART1 console at 115200 baud, 8N1.
The observed vendor U-Boot identified the ADI source revision below with local modifications.
A revision prefix does not prove an identical vendor binary.

## Verified RAM route

Read the [Pluto FIT handoff contract](../../bootloaders/pluto-ram-fit.md) before preparing an image.
The bounded [physical scenario](evidence/ram-rx.json) used the original live device tree and FPGA image.
It loaded an EmberBSD `PLUTO_NANO_RX` kernel and an FFS RAM root through the RAM DFU alternate.
U-Boot checked image hashes, configured the original bitstream in volatile fabric, and started EmberBSD.
No QSPI partition or persistent environment was written.

Keep the device-specific FDT, wiring and original FPGA image together.
Do not substitute an ADALM-PLUTO Rev.B bitstream: its package and pin map differ.
A configured fabric and enabled register clocks must precede AXI peripheral access.
A soft PS reset alone does not establish that condition.

## Recovery limits

The data and UART connectors can both power the board.
To remove power, disconnect both cables.
Hardware BREAK did not give reliable EmberBSD debugger entry on the tested UART.
A software console-magic sequence worked after explicit configuration in a running shell.
A guarded DMA shutdown can refuse reset when hardware drain cannot be proved.
In that state, complete power removal is the recovery boundary.

This profile does not qualify a persistent firmware update or QSPI restoration procedure.
Keep the original firmware intact until those independent scenarios have passed.
Source IDs: `adi-pluto-uboot-fit`, `ember-pluto-rx-scenario`.
