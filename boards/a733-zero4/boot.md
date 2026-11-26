# Boot and recovery

Vendor boot0 and U-Boot supply a device tree and boot the microSD root to multi-user.
Follow the shared [native AArch64 image contract](../../bootloaders/u-boot-native-image.md) for loader and artifact applicability.
Eight cores and serial console are recorded. Card signalling uses 1.8 V SDR104 at 150 MHz.
The recorded sequential read rate is 59 MB/s; no tuning was performed and sample delay stayed zero.
A reboot from that state worked. Preserve the exact memory and board firmware inputs.
The related Zero 3W uses a board-specific tree with Ethernet disabled; do not exchange their descriptions blindly.
No physical power button is populated in the source record; the PMIC power-key pads were not exercised.
Power-off uses PSCI. Exact connector and recovery-control wiring remain unspecified.

## Zero 4 kernel selection

The [Zero 4 kernel build](https://github.com/oxtech-ember/EmberBSD/blob/b66333b443fb39bf107529422f9f44d84486788c/ember/development/kernel.md#orange-pi-zero-4)
selects `EMBER64_ORANGEPI_ZERO4` with `HZ=1000`. This setting applies to
that kernel configuration. The shared AArch64 `EMBER64` and Zero 3W
configurations retain their existing timer settings.

For a Zero 4 update, use a verified signed board set and its matching DTB.
The graphics installer keeps the established `netbsd-EMBER64.img`
artifact name for the raw Zero 4 image. It can stage the matching ELF as
`netbsd-EMBER64`. For offline builds, use the configuration-specific ELF
and raw image from the Zero 4 builder. Preserve the old pair and card
recovery entry. Verify the running build and the reported `kern.clockrate`
after startup. The timer change leaves the firmware chain and DTB selection
in place.

For a fresh microSD, follow the [Zero 4 image procedure](https://github.com/oxtech-ember/EmberBSD/blob/12cff61f4dcc04dfe04c3ce7c435801e78d7f848/distrib/utils/embedded/README.a733.md#orange-pi-zero-4-image).
Select `mkimage -h orangepi-zero4` and pass the board kernel output directory
with `-K`. Supply the verified vendor boot0 and boot-package for this board.
The generated `boot.scr` selects the named Zero 4 graphics DTB by default.
It uses the shared board check and existing FAT/FFS layout.
This graphics profile enables HDMI and on-demand NPU preparation.
Keep a separate verified recovery card.

## Graphics mode and recovery

The shared selector's `normal` mode selects the standard Zero 4 DTB. It leaves
the display path disabled and uses observation-only GPU diagnostics. The dedicated
Zero 4 graphics image selects the `graphics` mode at startup. This mode enables
native PowerVR firmware service and the DE3.52 and HDMI providers. With a kernel and DTB that support on-demand NPU preparation, it also
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
and active rendering after a warm reboot on [EmberBSD e29c9e337](https://github.com/oxtech-ember/EmberBSD/commit/e29c9e337c3faa4a3c8d0efda3b998636b6a0dcf).
The board revision is unknown.

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
