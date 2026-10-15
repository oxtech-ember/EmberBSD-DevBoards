# External interface worksheet

Complete this contract for every connection needed by the target device.
Keep actual pin maps with the board or carrier that owns the connector.

| Field | Required detail |
|---|---|
| Identity | Board/carrier ID, revision, connector reference and viewing orientation |
| Pin | Physical contact, SoC pad, GPIO number and software line name, each explicitly labeled |
| Electrical | Nominal level, absolute limits, direction, pulls, drive capability and source |
| Multiplexing | Required function and conflicts with console, storage, audio or other buses |
| Protocol | Bus instance, address/chip select, mode, rate, clock and reset requirements |
| Power | Device rail, sequencing, current budget and whether power remains after OS shutdown |
| Software | Firmware, DT/ACPI description, kernel driver, user interface and application dependency |
| Verification | Exact connected part, workload, result, duration and evidence |

Use explicit units: V, mA, Hz, ns and degrees Celsius.
Do not use a nominal voltage as an absolute maximum rating.
Unknown voltage tolerance is not permission to connect a higher voltage.
Bus discovery is not a successful sensor read, audio stream or actuator command.
A camera, display or high-speed bus also needs the vendor routing and signal-integrity requirements.
