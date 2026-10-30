# Transfer to an EmberBSD device

Use the vendor BSP as a reference for revision selection, shared-resource ownership
and peripheral initialization. Preserve its license and attribution when adapting code.
It is an ESP-IDF implementation, not an EmberBSD driver package.

Keep hardware operations behind replaceable adapters.
A Spark-facing adapter can separate application requests from the transport and the board driver.
Read-only status and logs provide an initial integration boundary; application execution,
actuation and firmware updates need their own implemented contracts and tests.
The vendor WebUI does not establish that Spark already runs on this board.

For a native EmberBSD port, start with the [ESP32-S31 source profile](../esp32-s31/README.md)
and identify which boot, memory and radio assumptions apply to Mosaico.
Keep the 16 MB PSRAM budget explicit. Storage capacity is not working RAM.
Board-specific display, touch, power, audio and slot wiring need their own integration.
Check the actual flash layout and a usable console/recovery route before selecting an image.

The BSP also provides ESP-NOW peer and topology components for multi-board interaction.
They are useful source references for distributed-device designs.
No multi-board, radio coexistence or latency result is established here.
See the [vendor BSP](https://github.com/esp-mosaico/esp-mosaico-bsp/tree/7cbfb390638dcb93522fc3cde094b2d43cf907c2)
and [device-mode documentation](https://github.com/esp-mosaico/esp-mosaico-vibe/blob/1872fd88c01d7807556d01fd2a19864e40a307c9/docs/device-modes.md).

Drivers and executable checks belong to EmberBSD or Ports.
An application adapter belongs to Spark or a standalone example.
This profile owns hardware applicability and scoped support, not a second application API.
