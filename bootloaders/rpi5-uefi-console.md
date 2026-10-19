# BCM2712 UEFI: serial and graphical console policy

This note applies to the EmberBSD firmware recipe for the RPi5 UEFI family.
It describes firmware policy. Carrier wiring and the kernel tty remain separate contracts.

## Why SPCR can disappear

The upstream EDK2 `ConsolePrefDxe` callback reads `ConsolePref` at ReadyToBoot.
With graphical preference and an available Graphics Output Protocol (GOP), it removes the ACPI SPCR table.
It also removes the device-tree `stdout-path` property.
Without GOP, it keeps the serial description.
Connecting a monitor can therefore change the advertised serial console before the kernel starts.
An attached UART driver does not prove that it is the selected console.

## EmberBSD serial firmware variants

The `--rp1-console` and `--rp1-trace` variants retain SPCR when GOP exists.
Their `RP1_UART_CONSOLE` build define guards both the SPCR removal helper and its call.
GOP and the upstream device-tree stdout policy remain available.
The standard firmware variant keeps the upstream preference behavior.
See the [firmware recipe and regression](https://github.com/oxtech-ember/EmberBSD/blob/9caf9c621e2df2de2760e39fc55cca98a49f9b78/ember/firmware/README.md).

Before using serial as the replacement for a firmware framebuffer, check that SPCR and the native UART resource describe the same device.
Verify the actual tty, interrupt attachment and console device number after boot.
A retained table alone does not close framebuffer writers or transfer display ownership.
GPU rendering, native scanout and KMS require their own acceptance.

When replacing firmware, preserve the device's variable-store region with a checked layout.
Verify the new code, retained variable bytes and recovery image before restarting.
Do not transplant another device's variable store.

Sources: `edk2-console-preference` and `os-rp1-console-gop` in [sources.json](../sources.json).
