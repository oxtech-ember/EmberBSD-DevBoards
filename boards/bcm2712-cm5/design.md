# Transfer to your device

Treat the module and carrier as separate components.
Select the exact RAM, radio and storage variant before designing the carrier.
Use the module datasheet for power, reset, clocks, high-speed routing and mechanical constraints.

Preserve accessible boot recovery controls and a console on the custom device.
Check USB data routing, power-source interaction, ESD protection and ground continuity.
Test cold boot, warm reset and recovery with the chosen power supply and enclosure.
Recheck Ethernet, display, camera and external buses after changing their carrier routing.
A GPU render result does not verify HDMI wiring or monitor compatibility.

[The common design worksheet](../../docs/device-design.md) lists the transfer checks.
Sources: `cm5-datasheet` and `os-cm5` in [sources.json](../../sources.json).
