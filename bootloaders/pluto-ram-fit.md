# Pluto U-Boot RAM FIT handoff

This contract describes the ADI Pluto U-Boot RAM route at source revision
`90401ce9ce029e5563f4dface63914d42badf5bc`.
It is separate from AArch64 `booti` and the efiboot ELF route.
Confirm the actual device environment and DFU alternate table before transfer.
Do not infer RAM behavior from a filename or a shared USB product ID.

## Image and memory contract

The reference environment loads a FIT at `0x02080000` through the `firmware.dfu` RAM alternate.
Its RAM region is limited to `0x01E00000` bytes.
Require the observed alternate set to match the RAM route before downloading.
A persistent flash alternate is a different operation.

The verified Nano scenario used these non-overlapping destinations:

| Component | Address |
|---|---|
| FIT transfer | 0x02080000 |
| FFS RAM root | 0x04000000 |
| ARM kernel load and entry | 0x08000040 |
| Original FPGA image | 0x0F000000 |

An ARM kernel FIT node with `os = "linux"` selects the U-Boot ARM handoff.
It passes the selected FDT in register r2, as the EmberBSD ARM entry expects.
The payload remains an EmberBSD native kernel image; renaming an ELF file does not convert it.
Check every component size, destination, relocation and reserved memory against actual RAM.
The selected FIT configuration must bind the kernel, FDT, RAM root and exact FPGA image.
Verify component hashes on the host and in U-Boot.

## Board and environment requirements

Load the original board FPGA image before enabling its AXI devices.
A PS-only soft reset can leave the fabric unconfigured or level shifters disabled.
Register access in that state can stop the system.
Keep the live FDT, pin map, clock inputs and original FPGA image matched.

The reference `adi_loadvals` path can save environment changes for recognized model strings.
Inspect that path before claiming a transfer is RAM-only.
The tested Nano FDT used model `ADI PlutoSDR Nano (EmberBSD RAM RX)`;
it did not enter the reference `Analog Devices Pluto` model branch.
Do not generalize that condition to an uninspected loader revision.

An exit timeout after a completed DFU manifest does not prove either boot failure or success.
Require UART evidence of hash verification, FPGA programming, kernel entry and the intended root filesystem.
The [Nano profile](../boards/hamgeek-plutosdr-nano/boot.md) describes the bounded observed route.
Persistent installation and recovery need separate acceptance.

Source IDs: `adi-pluto-uboot-fit`, `adi-pluto-uboot-arm-handoff` in [sources.json](../sources.json).
