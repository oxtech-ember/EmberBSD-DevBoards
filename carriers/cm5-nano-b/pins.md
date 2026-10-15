# Debug connection on PI1

`PI1` numbers are physical header contacts, not GPIO numbers or module connector contacts.
Use the schematic's pin-1 marker and the PCB pin-1 marking to orient the connector.
Do not choose pin 1 from a left/right description without fixing the viewing direction.
If the marking cannot be established, stop and resolve the board orientation first.

| Physical contact | Signal | Adapter connection | Direction at board |
|---|---|---|---|
| 6 | GND | GND | Ground |
| 8 | GPIO14 / UART0 TX | RX | Output when muxed to UART |
| 10 | GPIO15 / UART0 RX | TX | Input when muxed to UART |

Use a 3.3 V logic UART adapter. Do not connect its VCC lead or RS-232 voltage levels.
The nominal logic level is not a statement of absolute maximum voltage tolerance.
Power down the board before changing wires. Keep a common ground.
UART routing and console selection depend on firmware and pinmux; the wiring alone does not select a console.
GPIO14/15 cannot simultaneously serve an unrelated GPIO function and this UART configuration.
The module's dedicated debug connector is a different electrical route and has different contact numbering.

Sources: [carrier schematic](https://files.waveshare.com/wiki/CM5-NANO-B/CM5-NANO-B-Sch.pdf)
and [module datasheet](https://datasheets.raspberrypi.com/cm5/cm5-datasheet.pdf).
The evidence below does not establish a general serial-console configuration for every firmware revision.
See [USB recovery evidence](../../boards/bcm2712-cm5/evidence/usb-recovery.json) for its narrow scope.
