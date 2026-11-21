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
On one V1.2 sample, the standard CO5300 framebuffer/genfb/LVGL path displayed
a visible interface after the published two-row RASET worker fix; the operator
also confirmed changing touch coordinates. This is a RAM-only scenario on one
sample. Touch orientation and quantitative calibration remain unmeasured. The
SC101IOT configuration exposes a 640 × 480 UYVY stream through video(4). See the
[peripheral interfaces](interfaces.md#camera-and-other-peripherals) for hardware results.
After a normal POWER boot of the R3 system, one V1.2 sample also displayed the
LVGL weather example's fixed `MOSAICO`, `21 C` and `SUNNY` labels on a dark
background ([bounded hardware observation](evidence/weather-lvgl-normal-power.json)).
The labels are sample content, not sensor or online weather readings.
On R4, the operator saw the weather app update to `-8 C` using EmberBSD QML.
The same ELF gave individual RSS samples of 468 KiB and 908 KiB across two runs.
[QML display observation](evidence/weather-qml-run.json). The network appliance profile
completed `/etc/rc` in 189 seconds on one cold POWER boot and accepted SSH by name.
[Startup measurements](evidence/network-appliance-startup-profile.json).
On R5 the compact libc and Dropbear reduced the regular files in the 10 MiB
root partition from 8,200,008 to 4,767,619 bytes. The existing SSH host-key
pin worked after a cold boot. [R5 measurements](evidence/compact-dropbear-root.json).
On a separate instrumented reboot, all 13 startup scripts took 183 seconds in
total. Initial `rcorder` took 35 seconds. The `syslogd` startup script took
31 seconds, including a second scan for scripts that request chroot sockets.
[Per-service timings and measurement limits](evidence/r5-service-times.json).
[CSV with start, finish and intervals between scripts](evidence/r5-service-times.csv).
In a paired cold-start test, the nested syslogd scan took 14.40 seconds.
The interval from the network message to the syslogd start message was
42.03 seconds in the baseline and 24.11 seconds on the boot that skipped the scan.
The full POWERON-to-login interval increased from 211.09 to 247.31 seconds
across this pair. Both boots started the same 13 services.
[Cold-start intervals and logging check](evidence/r5-syslogd-cold-start.json).
On the running R5 system, ordering the same 31 script files took 23.86 seconds
on the NOR root and 2.94 seconds on tmpfs. Both invocations selected the same
13 services in the same order. Using the BSD name cache for lookups, reusing
the directory cursor and reading NOR metadata in 256-byte units reduced the
instrumented cold boot from 280.82 to 73.79 seconds. Root mount to the network
announcement fell from 112.86 to 29.61 seconds, and the WPA announcement to
the login line from 115.55 to 25.56 seconds. The largest measured reduction
inside the 13 scripts was in setup before the service actions ran. The final
normal boot with the temporary markers removed reached the login line in
72.15 seconds, down from 247.31 seconds with the previous kernel.
[Measurement conditions](evidence/r5-startup-io.json) and
[per-service intervals](evidence/r5-startup-io-cold.csv).

Three upstream Qt Quick scenes also matched the Qt reference RGB565 checksums
on RV32. Two exercise stacking order and one exercises Grid spacing.
[Qt reference scene measurements](evidence/qml-qt-reference-scenes.json).
The original Qt `mousearea.qml` also handled a physical press on its red
square and a drag of its blue square through wscons on R4.
[Input events and positions](evidence/qml-mousearea-touch.json).
A second positioner example displayed three red rectangles from the original
Qt Quick `horizontal-spacing.qml` on the panel. The RV32 renderer matched the
Qt reference frame for the same viewport.
[Row sizes and frame checksum](evidence/qml-row-spacing.json).
On R5, the original Qt Quick `behavior.qml` moves a labeled square 50 pixels
over one second after a tap. The operator saw judder with full-scene updates.
With region rendering and two-row CO5300 transfers limited to the changed
columns, the operator saw smooth motion on repeated taps. The updated kernel
ran from RAM during this comparison.
[Touch events and rendering times](evidence/qml-behavior-touch.json).
The upstream `visual-opacity.qml` scene also ran on R5. It uses nested items,
a translucent rectangle and a touch area. The operator hid and restored the
blue square by tapping the physical display.
[Scene, reference frames and device result](evidence/qml-visual-opacity.json).
The embedded Qt Quick Dial Control adaptation also ran from tmpfs on R5. Its
355,504-byte static RV32 binary embeds the face, needle and glass layers. A tap
on a set point changed both the needle and the displayed percentage.
[Device execution and reference comparison](evidence/qml-dial-control.json).
On R5, Network Lab received a network time sample and IPv4 resolver answers
while processing touch on its clock and DNS tabs.
[Physical network and display observations](evidence/qml-network-lab.json).
Power, Wi-Fi and other expansion features retain their own integration limits.
Check the actual flash layout and a usable console/recovery route before selecting an image.

The BSP also provides ESP-NOW peer and topology components for multi-board interaction.
They are useful source references for distributed-device designs.
No multi-board, radio coexistence or latency result is established here.
See the [vendor BSP](https://github.com/esp-mosaico/esp-mosaico-bsp/tree/7cbfb390638dcb93522fc3cde094b2d43cf907c2)
and [device-mode documentation](https://github.com/esp-mosaico/esp-mosaico-vibe/blob/1872fd88c01d7807556d01fd2a19864e40a307c9/docs/device-modes.md).

Drivers and executable checks belong to EmberBSD or Ports.
An application adapter belongs to Spark or a standalone example.
This profile owns hardware applicability and scoped support, not a second application API.
