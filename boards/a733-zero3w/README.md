# Allwinner A733 SBC: Zero 3W

Use this compact SBC to investigate wireless devices and the A733 accelerator software path.
[Machine-readable profile](board.json) · [Boot](boot.md) · [Interfaces](interfaces.md) · [Your device](design.md)

This is a research reference, not a production qualification or an exhaustive support matrix.
The profile's revision field is unknown unless a specific hardware revision is established.
Individual evidence records can name a narrower tested specimen.

Start with the pinned source `os-zero3w` in [sources.json](../../sources.json).
Then check the current OS board documentation for later changes.
Firmware, driver attachment, data movement and a complete application are separate evidence levels.
Connector maps and control sequences that lack a primary source remain unknown.

[The accelerator boundary](interfaces.md) includes bounded GPU rendering and one fixed INT8 NPU task.
[The SoC note](../../socs/allwinner-a733.md#fixed-npu-profile) explains exact HWDB identity and incomplete raw feature enumeration.
These observations do not qualify arbitrary models, physical HDMI or a complete desktop session.
