# Allwinner A733 SBC, vendor model `Zero 4`

An eight-core microSD and gigabit Ethernet reference with AIC8800D80 wireless. Shared silicon does not transfer Zero 3W accelerator acceptance to this board.

[Boot and recovery](boot.md) · [Interfaces and current support](interfaces.md) · [Design transfer](design.md) · [Machine-readable profile](board.json)

The graphics DTB has [offscreen Vulkan evidence](evidence/graphics-offscreen.json) and
[accelerated Plasma with captured desktop pixels on a virtual output](evidence/plasma-virtual.json).
The [native NPU evidence](evidence/npu-tile-contours.json) covers 24 offline
96 × 96 parts-contour frames and cold and warm runs of a single 720 × 540
frame with the fixed INT8 model. A separate [combined graphics and NPU run](evidence/graphics-npu-plasma.json)
covers on-demand NPU preparation and two clip runs in an accelerated virtual Plasma session.
The `normal` loader mode leaves the NPU disabled.
A [physical Plasma test](evidence/plasma-hdmi.json) verified HDMI output and USB-C pointer input.
The board revision is unknown.

Source for the original platform baseline: `os-zero4-reference` in [sources.json](../../sources.json).
