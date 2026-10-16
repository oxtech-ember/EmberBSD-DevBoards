# Interface and driver paths

| Research path | Required software or hardware | Evidence boundary |
|---|---|---|
| Wireless | AIC8800D80, vendor firmware, `aicwf` and WPA client | Protocol and band limits in the current OS record |
| Ethernet | No Ethernet port on this board | An external network adapter needs its own evidence |
| I2C | Native controller and board-specific PMIC/Type-C devices | Those devices do not qualify another sensor |
| GPU | Power, CCU, reset, firmware, native PowerVR DRM and Mesa | Native Vulkan Compute checked; graphics interfaces have host contracts; rendering, Zink and display remain unaccepted |
| NPU | Kernel, DMA, firmware, user library and model toolchain | No complete inference receipt in this profile |
| Cooling | PMIC power-off, PWM provider and thermal policy | Physical speed control remains separate from fan power-off |

Follow [the OS board record](https://github.com/oxtech-ember/EmberBSD/blob/39547d144888a9286ccc58304048efc68cd8e966/ember/boards/orange-pi-zero-3w.md) for dependencies and acceptance.
Follow [PowerVR execution](https://github.com/oxtech-ember/EmberBSD/blob/58a0ae471cf2162f6c4add28764761f868f65a3f/ember/boot/a733-pvr-execution.md) for current native driver mechanisms.
The [graphics contract](https://github.com/oxtech-ember/EmberBSD/blob/58a0ae471cf2162f6c4add28764761f868f65a3f/ember/boot/a733-pvr-graphics.md) separates implemented HWRT and paired submissions from physical acceptance.
Compute does not establish graphics, model inference or a display path.
