# Boot and console routing

The cited chain uses stock UEFI, ACPI and EmberBSD's AArch64 efiboot loader.
Follow the shared [efiboot artifact contract](../../bootloaders/efiboot.md).
A loader-selected kernel and a usable serial console are separate prerequisites.

The observed DEBUG connection is UART2 at 115200 8N1, associated with `\_SB.COM2`.
Stock SPCR instead selects UART3. The opt-in
[SPCR correction](https://github.com/oxtech-ember/EmberBSD/blob/75f0decfa1a02288f1bca8520b96811f9d5567a6/ember/boot/cix-spcr.md)
constructs a RAM shadow for one exact SPCR/DBG2 table profile.
It changes the OS console route without rewriting firmware tables.
UART1 and UART3 remain separate peripheral interfaces; DEBUG is not a generic header UART alias.
No sourced connector pin numbering or logic-voltage limit is provided here.

Firmware must expose SPCR and DBG2 for that correction.
The [board record](https://github.com/oxtech-ember/EmberBSD/blob/75f0decfa1a02288f1bca8520b96811f9d5567a6/ember/boards/orange-pi-6-plus.md)
reports that Support SPCR can return to Disabled after complete power removal.
Saving the setting restored the console in that scenario; persistence across cold power loss remains unqualified.
Missing console output alone does not establish a kernel hang.

Keep a verified console and an independent recovery route when changing the boot chain.
OS shutdown, hardware power removal and wake by short button press require separate checks.
The cited short-button shutdown reaches powerd and filesystem unmount, but short-button restart remains unresolved.
Do not transfer a power-control sequence to another firmware revision without new evidence.

Sources: `os-cix-p1`, `os-cix-spcr` in [sources.json](../../sources.json).

## Persistent SD root and recovery applicability

The bounded profile targets CD8180, 32 GB, A4 PHECDA-Rev A and stock `BiosV1.5-W20260706-e321056a`.
It uses a reduced GCC16 static C root, not a complete base release or unattended disk installer.
The checked UART2 kernel passed automatic cold and warm default boots.
An exact DSDT-gated kernel fallback also works when SPCR is absent; it does not remove the need to match firmware tables.

Keep a working UART and a separately bootable kernel/RAM-root pair.
Inspect SD sector size, GPT identity and existing partition extents. Retain verified GPT copies and boot partitions.
The image is a 2 GiB filesystem for a new non-overlapping FFS partition named `ember-cix-root`; it is not a whole-disk image.
Verify complete write readback and check the unmounted partition before provisioning.
The persistent entry clears initrd and selects `root=NAME=ember-cix-root`; keep the original boot menu and recovery entry.
The opt-in menu also disables `acpibat`. This avoids the observed diagnostic boot obstruction but does not repair battery ACPI.
NVMe installation is not accepted by this evidence.

The root retains separate private wireless, account, entropy and SSH configuration. Shared images contain no credentials.
The [root-image owner](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/image/cix-p1.md) owns assembly, startup and provisioning commands.
The [userland owner](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/image/cix-p1-userland.md) owns the selected cohort and runtime contracts.
The reduced cohort and isolated C++ tests do not qualify an installed complete C++ environment.

Five unattended SD-root boots retained filesystem data and restored WPA2/DHCP, with separately scoped 2.4 and 5 GHz checks.
A later cold-default scenario restored authenticated SSH/PTY and bidirectional 2 MiB file integrity.
Network readiness remains asynchronous; console availability does not promise immediate association.
Clean restart is different from unclean power-loss recovery. Absent-AP behavior, repeated AP loss and sustained operation remain unqualified.
Firmware DDR training/BIST messages, RTC warnings and radio calibration-quality warnings remain outside these results.

Sources: `os-cix-p1-reference`, `os-cix-root-reference` and `os-cix-userland-reference` in [sources.json](../../sources.json).

## Isolated runtime scope

The isolated chroot checks used fork libraries and loader from OS
`4b2a919a119ddbd4f8a3893913e8ce46e5d9573d` with the
[Ports runtime](https://github.com/oxtech-ember/EmberBSD-Ports/blob/f2823cb8940440be478963fcc07a0d2dce1e1b89/profiles/development-toolchain/bootstrap/external-compiler.md).
`LC_COLLATE` remains `C`; the generic libstdc++ backend does not support named
C++ locales. The 43-import math consumer checks symbol binding, not every
numerical semantic. This qualifies an isolated runtime foundation only, not an
installed complete C++ environment or a full image. The pinned image source in
[sources.json](../../sources.json) retains the original evidence.
