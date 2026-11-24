# Interfaces and current support

| Function | Current bounded evidence |
|---|---|
| Ethernet | Gigabit with Motorcomm YT8531; board RGMII delays measured with random data |
| Wi-Fi | AIC8800D80 WPA2/CCMP, 2.4 and 5 GHz, one-stream 802.11n up to 40 MHz; 30–48 Mbit/s through SSH at 5 GHz |
| Bluetooth | Classic inquiry, service query, Secure Connections pairing and stored-key reconnect; BLE unsupported in the cited implementation |
| CPU and temperature | Eight cores, five calibrated sensors and speed-grade 0x04 voltage/frequency operation |
| PMIC and I2C | AXP8191 outputs read, two core supplies driven; always-on I2C works |
| GPIO | Pinmux and outputs tested; pin interrupts absent |
| RTC and watchdog | RTC retained time across reboot; watchdog tested |
| USB-C | High-speed storage read at 22 MB/s in one plug orientation. A Logitech `046d:c534` receiver used `ums` and `wsmouse`. The operator confirmed cursor movement. SuperSpeed remains untested. |
| USB-A controllers | EHCI/OHCI attach; external devices not tested |
| Random generator | Crypto engine generator seeds the kernel |
| Audio and fan | No accepted audio or fan-control path |
| GPU | The opt-in graphics DTB enabled PowerVR firmware service at 600 MHz. BVNC 36.56.104.183 and the native DRM driver were verified. Mesa 26.3.0 read back 256 expected RGBA8 pixels through its PowerVR Vulkan ICD without a display. |
| Plasma | A separate Virtual-0 test captured the desktop and completed logout. The physical test showed active KWin composition through Zink and OpenGL ES 3.1 on PowerVR B-Series BXM-4-64 MC1. |
| HDMI | Plasma ran on a physical monitor. After reboot on EmberBSD `e29c9e337`, KWin reported 1280 × 1024 at 60.02 Hz. A separate native KMS run completed 2000 flips. Earlier diagnostic tests reproduced RCQ and TV0 retirement timeouts. Cold boot, display hotplug and longer operation remain unqualified. |
| NPU | The opt-in DTB and privileged tile ioctl ran the fixed INT8 profile at 300 MHz. The 24-frame 96 × 96 clip and cold and warm runs of a 720 × 540 frame matched the CPU reference. |

Wi-Fi requires `fmacfw_8800d80_u02.bin`; Bluetooth requires four vendor patch files.
Their implementation owner is EmberBSD `aicwf`; firmware is not redistributed by this catalog.
The cited profile does not advertise 802.11ac or 802.11ax.
Qualify Zero 4 radio and accelerator behavior with evidence for Zero 4; identify Zero 3W results as separate evidence.

FUSB302 polls the Type-C connection and gates VBUS through PL8. SuperSpeed PHY lock alone does not prove USB3 traffic.
The controller bus clock must remain 24 MHz for frame timing.
The source reports no sustained-use acceptance.

See the [offscreen Vulkan evidence](evidence/graphics-offscreen.json) and
[virtual Plasma session evidence](evidence/plasma-virtual.json) for inputs and limits.
The [physical Plasma evidence](evidence/plasma-hdmi.json) covers the monitor and pointer.
In a separate Qt/Vulkan test, the window produced approximately 1 to 1.3
`frameSwapped` signals per second with KWin blur enabled. With blur disabled,
it produced approximately 12 to 13. This result applies to the tested workload.

[Ports source revision 9de0dcd9](https://github.com/oxtech-ember/EmberBSD-Ports/commit/9de0dcd99b83d6e9a330b9c366ec952cdefc484e)
checks DRM event readiness before KWin dispatch. The separately verified
signed package is `plasma6-kwin-6.8.3nb1`, SHA-256
`1705b0dbe1be1202fb6d0f6300bc1b3693cd1e7ba5d7bc53cc32e733c48cb1f7`.
See the [signed release metadata](https://emberbsd-pkg.oxteam.me/current/metadata/578776c62d19f3f1f0f7c64f7ca1309de8a04c42bcdce3b3c00d506dbe9d7ff5/release.p7m).
The [native NPU evidence](evidence/npu-tile-contours.json) records the exact
identity, inputs and checked results. The [NPU observation evidence](evidence/npu-passive.json)
covers the earlier diagnostic attach and baseline ioctl refusal.
The [combined graphics and NPU run](evidence/graphics-npu-plasma.json) covers direct
privileged tile submission during hardware-accelerated virtual Plasma.

Source for the earlier interface evidence: `os-zero4-reference` in [sources.json](../../sources.json).
