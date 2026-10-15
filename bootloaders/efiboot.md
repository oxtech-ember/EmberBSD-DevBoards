# EmberBSD efiboot: kernel artifact contract

This document covers EmberBSD's AArch64 `efiboot` loader and its selected ELF kernel.
It does not define a universal UEFI requirement or a format for every ARM64 boot path.
The board profile identifies the firmware, storage, console route and loader used by that board.
Apply this contract only after establishing that `efiboot` is the active loader.

The recorded [CM5](../boards/bcm2712-cm5/boot.md) and [RPi5](../boards/bcm2712-rpi5/boot.md) paths use this loader.
The [A733 Zero 3W path](../boards/a733-zero3w/boot.md) uses U-Boot and has its own image contract.

## Match the artifact to the selected entry

For this loader path, `boot.cfg` selects a device, partition and kernel filename.
Inspect that selected file, not another copy on the EFI partition.
The AArch64 EFI loader passes it to `loadfile`, which checks the executable header before loading kernel segments.
A native ARM64 image named `netbsd.img` belongs to a different boot path.
Renaming that image to `/netbsd` does not convert it to ELF.

## Recorded installation error

A read-only CM5 eMMC inspection on 2026-10-15 found this installation error:

| Item | Observation |
|---|---|
| Selected entry | `default=1` selected `hd0b:netbsd` |
| Active `/netbsd` | Native ARM64 image; first bytes `10 00 00 14`; SHA256 matched the native build output |
| Retained previous kernel | ELF64, little-endian, AArch64; first bytes `7f 45 4c 46` |
| Active board modules | Four modules remained from the previous accepted kernel build |

Inspection fingerprints:

- Active `/netbsd`: SHA256 `beb316f4f300d505e8147d49d6bcd6fd8b9209746b032db5c404fb15d4e09189`.
- Retained previous kernel: SHA256 `c8600af1c6a31404fe6b3a3995196a910efda594c708194369925adb54ff1886`.

These hashes identify the inspected files. They are not download references or current release recommendations.
This establishes an incorrect artifact at the selected path and an inconsistent installation.
It does not establish that the GPU buffer-size change caused a kernel crash.
No successful boot after correction or fresh installation is claimed by this observation.

## Check a kernel replacement

Before replacing an accepted kernel:

1. Resolve the active loader entry and its device, partition, filename and kernel arguments.
2. Check the candidate's actual format: ELF64, little-endian and AArch64 for this EFI path.
3. Check ELF headers and segments; the four magic bytes alone are insufficient.
4. Match the kernel SHA256 to the manifest from a successful build.
5. Match every installed board module to that build's source revision, configuration and module hashes.
6. Confirm that the selected build completed. An old file left after a failed build is not a new candidate.
7. Keep the previous kernel and its matching modules available through a verified recovery route.
8. After installation, read back the selected kernel and module files and verify their hashes before reboot.

The destination path and the artifact format are separate manifest fields.
Record them together with the source revision, configuration, compiler and build result.
Implementation sources: `os-efiboot-exec`, `os-loadfile-format` and `os-evbarm-kernel-format` in [sources.json](../sources.json).
The [loader call](https://github.com/oxtech-ember/EmberBSD/blob/6245a565b06486186c0159a1315ed89c893148a7/sys/stand/efiboot/exec.c#L182)
and [header selection](https://github.com/oxtech-ember/EmberBSD/blob/6245a565b06486186c0159a1315ed89c893148a7/sys/lib/libsa/loadfile.c#L167)
show why a renamed native image cannot satisfy this path.

