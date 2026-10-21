# Interface and driver paths

| Research path | Required software or hardware | Evidence boundary |
|---|---|---|
| Wireless | AIC8800D80, vendor firmware, `aicwf` and WPA client | Protocol and band limits in the current OS record |
| Ethernet | No Ethernet port on this board | An external network adapter needs its own evidence |
| I2C | Native controller and board-specific PMIC/Type-C devices | Those devices do not qualify another sensor |
| GPU | Power, CCU, reset, firmware, native PowerVR DRM and Mesa | Bounded Compute, offscreen rendering and four KWin/Zink frames checked; physical HDMI and complete Plasma remain unaccepted |
| NPU | Native TASK, exact HWDB profile, DMA, MMU and IRQ | One fixed INT8 convolution passes all 512 numerical bytes and buffer checks; general model preparation, runtime and recovery remain unaccepted |
| Cooling | PMIC power-off, PWM provider and thermal policy | The stock kit fan is two-wire: the header switches its supply rail, so only off/full cooling works; a four-wire fan needs its own acceptance |

Follow [the OS board record](https://github.com/oxtech-ember/EmberBSD/blob/39547d144888a9286ccc58304048efc68cd8e966/ember/boards/orange-pi-zero-3w.md) for dependencies and acceptance.
Follow [PowerVR execution](https://github.com/oxtech-ember/EmberBSD/blob/58a0ae471cf2162f6c4add28764761f868f65a3f/ember/boot/a733-pvr-execution.md) for current native driver mechanisms.
The [accelerator boundary](https://github.com/oxtech-ember/EmberBSD/blob/8735c9333e50d62a33a64a99b39e1af4f0dce3c1/ember/boards/orange-pi-zero-3w.md#accelerator-acceptance-2026-10-20)
records the separate graphics checks. The [fixed NN record](https://github.com/oxtech-ember/EmberBSD/blob/0ab3a97971ff8fcbeefbaa6f2f88ef39fb1cd7f3/ember/boot/a733-npu-tiny-task-acceptance.json)
does not accept arbitrary models or concurrent GPU/NPU workloads.
Read [the identity and raw-feature limits](../../socs/allwinner-a733.md#fixed-npu-profile) before selecting another silicon profile.
