# Design transfer notes

This record covers a vendor product family, not a verified board revision. The reviewed public sources do not establish a Nano schematic, exact populated memory, QSPI part, PS MIO wiring, FPGA clock, RF reset GPIO, or the image-selection and recovery controls for every unit.

The independent Nano pin-map report is useful technical prior art. It reports measurements on a Nano sample and different FPGA package pins from the ADALM-PLUTO Rev.B reference. Confirm every value against the actual specimen before using it in a device tree or FPGA design.

For a custom carrier, separately validate the AD9363 supply and reference clock, SPI and reset, 1.8 V FPGA I/O, RX data clock and frame, DMA stream format, USB power, thermal behavior, and a recovery route. This profile does not provide a connector pin map or authorize a persistent firmware update.
