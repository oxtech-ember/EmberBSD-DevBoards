# Interface and driver paths

| Research path | Required software or hardware | Evidence boundary |
|---|---|---|
| Wireless | AIC8800D80, vendor firmware, `aicwf` and WPA client | Protocol and band limits below |
| Ethernet | No Ethernet port on this board | An external network adapter needs its own evidence |
| I2C | Native controller and board-specific PMIC/Type-C devices | Those devices do not qualify another sensor |
| GPU | Power, CCU, reset, firmware, native PowerVR DRM and Mesa | Bounded Compute, offscreen rendering and four KWin/Zink frames checked; physical HDMI and complete Plasma remain unaccepted |
| NPU | Native TASK, exact HWDB profile, DMA, MMU and IRQ | One fixed INT8 convolution passes all 512 numerical bytes and buffer checks; general model preparation, runtime and recovery remain unaccepted |
| Cooling | PMIC power-off, PWM provider and thermal policy | The stock kit fan is two-wire: the header switches its supply rail, so only off/full cooling works; a four-wire fan needs its own acceptance |

The [pinned OS source](https://github.com/oxtech-ember/EmberBSD/blob/39547d144888a9286ccc58304048efc68cd8e966/ember/boards/orange-pi-zero-3w.md) preserves earlier evidence; this profile owns current hardware applicability.
Follow [PowerVR execution](https://github.com/oxtech-ember/EmberBSD/blob/58a0ae471cf2162f6c4add28764761f868f65a3f/ember/boot/a733-pvr-execution.md) for current native driver mechanisms.
The [accelerator boundary](https://github.com/oxtech-ember/EmberBSD/blob/8735c9333e50d62a33a64a99b39e1af4f0dce3c1/ember/boards/orange-pi-zero-3w.md#accelerator-acceptance-2026-10-20)
records the separate graphics checks. The [fixed NN record](https://github.com/oxtech-ember/EmberBSD/blob/0ab3a97971ff8fcbeefbaa6f2f88ef39fb1cd7f3/ember/boot/a733-npu-tiny-task-acceptance.json)
does not accept arbitrary models or concurrent GPU/NPU workloads.
Read [the identity and raw-feature limits](../../socs/allwinner-a733.md#fixed-npu-profile) before selecting another silicon profile.

## Base platform and wireless limits

Vendor boot0/U-Boot and the board-specific tree boot microSD in SDR104 at 150 MHz; the recorded read rate is 47 MB/s.
Eight cores, five temperature sensors, watchdog reset, RTC retention across reboot and cluster frequency switching have bounded physical results.
The PMIC and Type-C I2C devices work. AXP8191 outputs were read, not electrically measured.
Pinmux works; pin interrupts and USB peripheral operation remain unvalidated. Classic Bluetooth inquiry works; pairing and BLE are unaccepted.
Audio has no accepted path. These results do not establish long-duration stability.

AIC8800D80 requires vendor firmware and Bluetooth patch files. WPA2/CCMP works on 2.4 and 5 GHz with checksummed transfers.
SAE group 19/H2E with required PMF and BIP-CMAC-128 passed 5 GHz transfers, reboot recovery and connected-scan recovery.
Connected scans interrupt traffic; recovery is not seamless roaming. Sustained 2.4 GHz SAE traffic is unqualified.
VHT80 with one stream has separate WPA2/CCMP traffic evidence; VHT80 with SAE/PMF remains unaccepted.
The key interface cannot supply a nonzero initial IGTK packet number. Such key installation is refused even after successful SAE authentication.
Neighbor-list and BTM acceptance, 802.11r, 802.11ax and host AP mode are not established.
With Wi-Fi as the only network path, retain serial access or a tested watchdog recovery route before changing drivers or authentication.

Use orderly firmware power-off when power removal is intended. Plain halt leaves power applied.
The stock kit fan stopped in the recorded power-off scenario; that does not qualify PWM speed control.
The newer fixed-NPU and graphics boundaries above remain separate from these base/network observations.
Source: `os-zero3w-reference` in [sources.json](../../sources.json).

## Graphics workload scope

The offscreen result uses an optimal image and transfer readback with all 256 RGBA pixels, row padding and guards checked.
The hardware KWin/Zink result covers four uniform 640×480 frames on a virtual output.
It does not accept one-LSB texture-boundary differences in a separate quadrant image, general compositor behavior or physical HDMI.
The checked firmware is 1.1.6976702 on BXM 36.56.104.183. Experimental Mesa opt-in remains required.
Physical free-list growth, reset recovery, sustained operation and Vulkan conformance are unaccepted.
The cold display-provider checks do not establish successful monitor scanout.
Source: `os-a733-pvr-graphics-scope` in [sources.json](../../sources.json).

See [accelerator diagnostic boundaries](diagnostics.md) for the power, firmware and memory distinctions behind these results.
