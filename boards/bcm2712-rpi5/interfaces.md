# Interface and driver paths

| Research path | Implementation owner | Check before reuse |
|---|---|---|
| Ethernet and Wi-Fi | EmberBSD board record, `cemac`/`bwfm`, vendor radio firmware | Link lifecycle, authentication and sustained traffic |
| I2C audio | OS WM8960 codec/HAT path | Exact HAT, pinmux, clock and audio stream |
| USB | OS host-controller drivers and control-recovery checks | Required transfer type, peripheral and power budget |
| GPIO and high-speed connectors | Exact SBC hardware documentation and OS description | Physical pin map and complete peripheral operation |
| Display/GPU | OS graphics and Ports Mesa stack | Independent SBC display and render evidence |

The WM8960 result does not qualify an arbitrary codec or every I2C peripheral.
The USB control-transfer check does not qualify bulk or isochronous transfers.
A module's V3D result does not qualify this SBC's display path.
Pin numbers are intentionally absent until their source and viewing orientation are established.
Source: [the pinned OS board record](https://github.com/oxtech-ember/EmberBSD/blob/39547d144888a9286ccc58304048efc68cd8e966/ember/boards/raspberry-pi-5.md), ID `os-rpi5`.
