# Boot and recovery

Vendor boot0 and U-Boot supply a device tree and boot the microSD root to multi-user.
Follow the shared [native AArch64 image contract](../../bootloaders/u-boot-native-image.md) for loader and artifact applicability.
Eight cores and serial console are recorded. Card signalling uses 1.8 V SDR104 at 150 MHz.
The recorded sequential read rate is 59 MB/s; no tuning was performed and sample delay stayed zero.
A reboot from that state worked. Preserve the exact memory and board firmware inputs.
The related Zero 3W uses a board-specific tree with Ethernet disabled; do not exchange their descriptions blindly.
No physical power button is populated in the source record; the PMIC power-key pads were not exercised.
Power-off uses PSCI. Exact connector and recovery-control wiring remain unspecified.

## Graphics mode and recovery

Normal boot selects the standard Zero 4 DTB. It leaves the display path disabled
and uses observation-only GPU diagnostics. The graphics DTB is an explicit opt-in
for this board. It enables native PowerVR firmware service and the DE3.52 and HDMI
providers. With a kernel and DTB that support on-demand NPU preparation, it also
attaches the NPU at stage 0. The first admitted privileged tile ioctl prepares
the NPU. Later calls use the same interface and retain the warm context.
Use a kernel, DTB and PowerVR firmware that match the
[OS boot mode contract](https://github.com/oxtech-ember/EmberBSD/blob/9e63456660e5bafc5c75e5555446b5b32b0a1816/sys/arch/arm/sunxi/docs/a733-boot-modes.md).

Keep the original DTB and boot script available before selecting graphics mode.
Set `ember_boot_mode=graphics` in the optional loader entry. Set `normal` in
the recovery entry.
Keep an independent normal boot route on microSD or a serial console with a
verified way to select the normal DTB. To recover, select normal mode and reboot.
On an image without a mode selector, restore its original boot script and DTB
on the FAT boot partition from another system, then boot the card normally.
Keep the Zero 4 DTB with the Zero 4 board. The Zero 3W diagnostic mode has a
different device tree and does not apply to Zero 4.

A physical reboot verified `setenv ember_boot_mode graphics` with the standard
Zero 4 DTB restored under its normal name and a separate `-graphics.dtb`.
PowerVR firmware service ran at 600 MHz. The render probe passed 115 checks
as an ordinary user. The native KMS frontend attached and waited for HDMI
hot-plug detect with `fault=0`. The normal DTB and `boot-normal.scr` were
preserved for recovery. Emergency fallback was not exercised.
The [offscreen Vulkan evidence](evidence/graphics-offscreen.json) covers KMS with no HDMI sink.
The [virtual Plasma evidence](evidence/plasma-virtual.json) includes captured compositor pixels.
A [separate physical test](evidence/plasma-hdmi.json) recorded the HDMI mode
and active rendering after reboot with a diagnostic kernel. The board revision is unknown.

The [combined graphics and NPU run](evidence/graphics-npu-plasma.json) used a reference
microSD configured to select `graphics` at each boot. Other Zero 4
installations select the loader mode in their own boot entry.

## NPU observation mode

The `normal` loader mode leaves the NPU disabled. Select
`ember_boot_mode=npu-observe` with the matching Zero 4 NPU observation DTB
and kernel to use the explicit diagnostic stages. Follow the
[OS boot mode contract](https://github.com/oxtech-ember/EmberBSD/blob/ff55aa034d41208744ee3e21d5620e1df8156813/sys/arch/arm/sunxi/docs/a733-boot-modes.md).
Keep a separate normal entry for recovery.

The opt-in DTB attaches the diagnostic driver at stage 0. Explicit stages
prepare identification and then admit the fixed INT8 profile. The physical
[execution record](evidence/npu-tile-contours.json) covers an enabled 800 mV
DCDC2 rail, 300 MHz NPU and 200 MHz AHB clocks, and the privileged repeated
tile path. The [baseline observation record](evidence/npu-passive.json)
covers an older kernel that returned `ENOTTY` for the tile ioctl.

Source for the boot baseline: `os-zero4-reference` in [sources.json](../../sources.json).
