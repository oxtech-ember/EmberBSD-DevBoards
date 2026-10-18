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
