# Allwinner A733 research entry

Start with [the Zero 3W profile](../boards/a733-zero3w/README.md).
Boot firmware, power management, clocks, resets, DMA and accelerator firmware are distinct dependencies.

The [native accelerator providers](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/boot/a733-power-domains.md)
and [GPU execution path](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/boot/a733-pvr-execution.md)
are implementation entry points. A provider attaching does not establish successful command execution.
An enumerated Vulkan device does not establish rendering, model inference or conformance.
The NPU needs its own driver, memory/DMA, user library and model-execution evidence.

Do not copy the Ethernet configuration of another A733 board into Zero 3W.
For a custom board, establish PMIC wiring, memory setup, oscillator, storage and radio independently.
Source IDs: `os-zero3w`, `os-a733-boot`, `os-pvr` in [sources.json](../sources.json).
