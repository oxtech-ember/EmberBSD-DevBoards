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
| USB-C | High-speed storage read at 22 MB/s; one plug orientation; SuperSpeed untested |
| USB-A controllers | EHCI/OHCI attach; external devices not tested |
| Random generator | Crypto engine generator seeds the kernel |
| Audio and fan | No accepted audio or fan-control path |
| GPU | The opt-in graphics DTB enabled PowerVR firmware service at 600 MHz. BVNC 36.56.104.183 and the native DRM driver were verified. Mesa 26.3.0 read back 256 expected RGBA8 pixels through its PowerVR Vulkan ICD without a display. |
| Plasma | An ordinary user outside the wheel group ran KWin 6.8.2 on a 1280×1024 virtual output. KWin reported active OpenGL ES composition. PlasmaShell Qt Quick reported zink Vulkan 1.2 PowerVR B-Series BXM-4-64 MC1. Six applet models, Xwayland and Activities responded. Normal logout completed after the readiness minimum of 30 seconds. KWin ScreenShot2 captured the wallpaper, lower panel, clock and a notification from Virtual-0. Physical HDMI remains unverified. |
| HDMI | DE3.52 and HDMI providers attached. Without a sink, KMS retried with `EAGAIN` and `fault=0`. Visible output, EDID, hotplug and an HDMI desktop session remain unverified. |
| NPU | Physical operation remains unverified on Zero 4. |

Wi-Fi requires `fmacfw_8800d80_u02.bin`; Bluetooth requires four vendor patch files.
Their implementation owner is EmberBSD `aicwf`; firmware is not redistributed by this catalog.
The cited profile does not advertise 802.11ac or 802.11ax.
Qualify Zero 4 radio and accelerator behavior with evidence for Zero 4; identify Zero 3W results as separate evidence.

FUSB302 polls the Type-C connection and gates VBUS through PL8. SuperSpeed PHY lock alone does not prove USB3 traffic.
The controller bus clock must remain 24 MHz for frame timing.
The source reports no sustained-use acceptance.

See the [offscreen Vulkan evidence](evidence/graphics-offscreen.json) and
[virtual Plasma session evidence](evidence/plasma-virtual.json) for inputs and limits.

Source for the earlier interface evidence: `os-zero4-reference` in [sources.json](../../sources.json).
