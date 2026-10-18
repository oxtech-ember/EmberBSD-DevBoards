# CIX P1/CD8180 SBC: Orange Pi 6 Plus

Use this reference to investigate ACPI console routing and the CIX video-codec integration boundary.
[Machine-readable profile](board.json) · [Boot](boot.md) · [Interfaces](interfaces.md) · [Your device](design.md)

The cited OS record describes an A4 PHECDA-Rev A specimen with stock CIX UEFI firmware.
The profile's revision remains unknown; those observations do not qualify every revision or memory variant.
This is a focused hardware reference, not an installation recipe or a complete OS support matrix.

Start with `os-cix-p1` in [sources.json](../../sources.json).
All CIX source records here pin EmberBSD `75f0decfa1a02288f1bca8520b96811f9d5567a6`.
Read the [current implementation owner](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/boards/orange-pi-6-plus.md) for later changes.
No configuration or firmware binary is distributed by this profile.
Connector contact numbers, signal voltage and electrical tolerances remain unknown here.
