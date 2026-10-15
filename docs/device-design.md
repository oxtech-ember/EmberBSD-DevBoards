# From a board to your device

Use a reference board to prove the smallest useful operation first.
Then identify the assumptions that your device changes.

| Design decision | Record before reuse | Recheck on your device |
|---|---|---|
| Module or bare SoC | Exact revision, memory and storage variant, vendor design documents | Boot path, memory training, exposed buses and firmware contract |
| Power | Rails, sequence, current budget, inrush, connector and brownout behavior | Rail measurements during boot, radio traffic and accelerator load |
| Clocks and reset | Clock sources, reset polarity, timing and firmware ownership | Cold start, warm reset and peripheral recovery |
| Storage | Controller, bus width, voltage, partition contract and endurance needs | Read/write checksums, power interruption strategy and recovery |
| GPIO and buses | Physical contact, pad, pinmux, pull resistors, electrical limits and bus address | Actual connected device and conflicting functions |
| Networking | PHY or radio, firmware, antenna path and protocol requirements | Required throughput, reconnect, RF conditions and long runs |
| Graphics or inference | Display link or accelerator, memory/DMA, kernel driver, user library and workload | Complete useful operation, output validation and resource use |
| Cooling and enclosure | Sensor placement, heatsink, fan, airflow and ambient range | Sustained load, thermal limits and restart from a stopped fan |
| Service access | Console pads, boot controls, recovery connector and artifact identity | Recovery without a working root filesystem or network |

For every reused fact, say whether it belongs to the SoC, module, carrier, firmware, EmberBSD or application.
Do not inherit a carrier's connector map into a custom PCB.
A schematic records intended wiring; it does not measure signal quality or verify the software path.

Start with a [new board worksheet](../templates/board/README.md).
Use [the interface contract](../interfaces/README.md) for each external connection.
Store the board-specific settings beside their applicability manifest.
Keep the actual driver or package patch with its implementation owner.
A board profile can link to an application example without depending on that application's private configuration.
