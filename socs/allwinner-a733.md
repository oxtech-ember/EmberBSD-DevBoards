# Allwinner A733 research entry

Start with [the Zero 3W profile](../boards/a733-zero3w/README.md).
Boot firmware, power management, clocks, resets, DMA and accelerator firmware are distinct dependencies.

The [native accelerator providers](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/boot/a733-power-domains.md)
and [GPU execution path](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/boot/a733-pvr-execution.md)
are implementation entry points. A provider attaching does not establish successful command execution.
[Native Vulkan Compute](https://github.com/oxtech-ember/EmberBSD/blob/58a0ae471cf2162f6c4add28764761f868f65a3f/ember/boot/a733-pvr-execution.md#physical-compute-boundary) has bounded hardware acceptance on Zero 3W.
[Offscreen graphics and four KWin/Zink frames](https://github.com/oxtech-ember/EmberBSD/blob/8735c9333e50d62a33a64a99b39e1af4f0dce3c1/ember/boards/orange-pi-zero-3w.md#accelerator-acceptance-2026-10-20)
have bounded physical acceptance. Physical HDMI and a complete Plasma session remain unaccepted.
Compute and rendering do not establish conformance or model inference.

## Fixed NPU profile

The [native TASK record](https://github.com/oxtech-ember/EmberBSD/blob/0ab3a97971ff8fcbeefbaa6f2f88ef39fb1cd7f3/ember/boot/a733-npu-tiny-task-acceptance.json)
accepts one fixed INT8 convolution on Zero 3W. All 512 numerical output bytes match the CPU oracle.
The record also checks buffer tails, immutable inputs and both MMU tables.
The six DMA buffers remain retained until reboot. This is not a general inference service.

Two complete identity samples match model/revision/product/ECO/customer
`0x9000/0x9202/0x05090009/0x08000000/0x1000003b`.
The exact HWDB entry supplies eight INT8 cores and no BLT engine.
MORE is clear in raw minor0. Raw minor5 was not read; its cached zero is not a hardware measurement.
Do not infer a missing NPU from incomplete raw feature enumeration.
Do not apply this HWDB profile to another A733 identity without separate admission and execution evidence.

The [implementation guide](https://github.com/oxtech-ember/EmberBSD/blob/0ab3a97971ff8fcbeefbaa6f2f88ef39fb1cd7f3/ember/boot/a733-npu-tiny-task.md)
owns the executable checks. Arbitrary models, a public runtime API, error recovery and sustained workloads remain unaccepted.

Do not copy the Ethernet configuration of another A733 board into Zero 3W.
For a custom board, establish PMIC wiring, memory setup, oscillator, storage and radio independently.
Source IDs: `os-zero3w`, `os-a733-boot`, `os-pvr`, `os-pvr-graphics`,
`os-a733-accelerator-boundary` and `os-a733-fixed-nn` in [sources.json](../sources.json).
