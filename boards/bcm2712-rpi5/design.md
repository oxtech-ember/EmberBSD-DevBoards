# Transfer to your device

First prove the peripheral and its application workload on the SBC.
Then identify which functions come from BCM2712, RP1, the radio or the board wiring.
Re-establish power, clock, reset, pinmux and connector assumptions when moving to a custom PCB or module carrier.
Do not transfer the SBC's storage layout or connector numbers by analogy.
Keep a recovery and console route that works without the application or network.

[The common design worksheet](../../docs/device-design.md) applies to each changed interface.
Sources: `os-rpi5` and `cm5-datasheet` in [sources.json](../../sources.json).
