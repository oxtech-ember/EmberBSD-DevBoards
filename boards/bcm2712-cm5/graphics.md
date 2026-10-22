# Accelerated Plasma

Use current EmberBSD and the shared current Ports packages.
Update the loader, kernel and matching modules through the OS workflow.
Do not select an old kernel to match this page.

CM5 has a checked hardware-accelerated Wayland Plasma path through V3D, Mesa and native HDMI.
The desktop, panel and automatic session startup have physical checks.
Follow the [shared Plasma service guide](https://github.com/oxtech-ember/EmberBSD-Ports/blob/main/probes/plasma-mobile/toolkit/service/README.md) for installation and account selection.
The desktop is optional. It is not a base OS requirement.

Connect a powered monitor before boot for the checked path.
Provide active cooling and check the [fan profile](configs/thermal-fan/README.md).
Test hotplug, input, power management and continuous load for your device separately.
The [interface reference](interfaces.md) records current board applicability; the implementation owner records software changes.

## Bounded native graphics foundation

Separate native checks qualify finite CL/TFU rendering, binary fences, multiple clients and exact allocation-budget return.
Physical job-list coverage reaches 91 buffer handles. A 32 MiB allocation result does not qualify rendering or scanout of that size.
Raster and 64×64 R32F UIF_NO_XOR transfers pass independent byte checks; XOR, mipmaps and other tiled formats remain unqualified.
Fixed-mode KMS completed 240 double-buffer flips in eight seconds at 1080p60 with normal blank teardown.
Same-device PRIME covers 80 cross-process lifecycles and four GBM/EGLImage/GLES pixel cycles; foreign-device sharing remains unqualified.
These bounded foundation results do not supersede the newer physical Plasma result above.
Vulkan, general job recovery and long-duration allocation pressure remain outside the native acceptance.
Source: `os-bcm2712-v3d-gl-scope` in [sources.json](../../sources.json).

See [bounded diagnostic evidence](diagnostics.md) for finite resource, display and GPU observations with their original source records.
