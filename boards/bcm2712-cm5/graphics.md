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
Check the current [OS board guide](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/boards/compute-module-5.md) for later support changes.
