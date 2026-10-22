# Interfaces and current support

Evidence applies to CIX P1 CD8180, 32 GB, A4 PHECDA-Rev A with stock `BiosV1.5-W20260706-e321056a`.
Distinct diagnostic kernels qualify distinct operations; they do not form one fully accepted platform.

| Function | Current bounded evidence |
|---|---|
| CPU and memory | 12 CPUs and about 32 GB enumerated; SMP stress and memory integrity unqualified |
| DEBUG console | UART2 at 115200 8N1; exact SPCR correction or gated kernel fallback, described in [boot](boot.md) |
| UART1/UART3 | Native plcom1/plcom3 and termios setup at checked 100 MHz functional clocks; external wire traffic unqualified |
| GPI5 inputs | GPIO015/016/017 read high; output changes refused and bounds checked; external transitions, IRQ and PPS unqualified |
| Ethernet | Both RTL8126 ports negotiate 5GBASE-T; 4096 alternating raw frames at four lengths pass payload/FCS checks; IP/TCP, throughput and sustained use pending |
| Wi-Fi | RTL8822CE legacy 802.11a/b/g with software CCMP; scoped WPA2, reconnect, scan recovery and data checks below |
| USB | 16 nonempty logical root buses and two attached VID/PID reads; external USB3, Bluetooth traffic and sustained transfers unqualified |
| Power button | Short press reaches orderly filesystem shutdown and fan stop; short-press restart after shutdown unresolved |
| VPU | Manual firmware bootstrap reaches SWITCHED_IN and PONG; no submitted codec frame or independently decoded output |
| Other paths | Camera, HDMI, GPU, NPU, general GPIO/PPS and thermal endurance unaccepted |

## Network boundaries

RTL8822CE WPA2-PSK/CCMP and DHCP have bounded results on channels 8 and 149.
Both bands passed simultaneous checksummed data in an earlier profile; persistent SD startup also restored network service.
Later legacy AUTO tests on one 2.4 GHz AP recovered after controlled reconnects and disruptive scans, with IPv4 and LAN link-local IPv6 data.
These do not establish SLAAC, DHCPv6, full AP-loss recovery or a latency guarantee.
A later channel-149 trial reached the channel but authentication timed out; 5 GHz data on that AP remains unqualified.
HT/VHT and hardware BlockAck are not accepted. Source support for HT policy does not replace a native provider or physical traffic.
ADC AB and DAC B residual-quality warnings remain; calibrated dBm and endurance are unqualified.
The [radio implementation](https://github.com/oxtech-ember/EmberBSD/blob/main/sys/dev/ic/docs/rtl8822ce-proposal.md) owns transport, firmware and executable contracts.

Both Ethernet ports passed at least two ring revolutions with 60/1514/1515/9014-byte raw frames, excluding FCS.
The bounded probe retained ordinary MTU 1500 afterward. It does not qualify camera traffic or physical failure recovery.

## VPU resources and acceptance

The observed `CIXH3010` describes two 64 KiB windows, GSI 358 and `_CCA=0`.
Clock67 is the VPU APB gate. Four cores and four slots were identified; the bounded preparation/bootstrap profile uses one core.
Noncoherent DMA, firmware ownership and safe teardown remain implementation contracts.
A physical bootstrap completed the first allocation, fixed 512 KiB resize and a second 16 KiB allocation, followed by SWITCHED_IN and PONG.
It retained exposed pages and claims with the IRQ masked. This is firmware protocol progress, not a codec session.
A separate first-frame source profile selects 128×128 NV12; native execution and independent decode remain pending.
The [VPU owner](https://github.com/oxtech-ember/EmberBSD/blob/main/sys/dev/acpi/docs/cix-vpu.md) owns resources, DMA, queues, firmware licensing and checks.

## Power and peripheral limits

Orderly button shutdown reached sync and FFS unmount with operator-observed fan stop in about five seconds in one scenario.
Electrical power-off is unmeasured. A short press did not restart the board, including after UEFI-only shutdown; input power must be removed and restored.
Do not infer pin numbering or electrical levels from native UART/GPIO enumeration.
USB device-name conversion remains incomplete in the reduced static base, despite VID/PID reads.

Sources: `os-cix-p1-reference`, `os-cix-root-reference`, `os-cix-platform`, `os-cix-vpu`
and `os-cix-vpu-attachment` in [sources.json](../../sources.json).

## Power-button contacts: PCB V1.1


Source: `vendor-cix-opi6plus-v11-schematic` in [sources.json](../../sources.json).
The [vendor support page](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-6-Plus.html) links `OPi 6 PLUS V11 DSN 0612.pdf`.
The recorded SHA256 identifies the PDF served by the official preview, not the original download bytes.
This record describes schematic revision 1.1. It does not identify another physical board revision.

Sheet 48 of 66, `RESET/BUTTON/LEDS`, defines the POWER switch `SW0`, part `TS-026-3`:

| Switch contact | Circuit | External dry-contact relay |
|---|---|---|
| SW0 pin 1 | R927, 10 ohm, then `PWRBTN_L_HW` | Normally open contact, NO |
| SW0 pin 2 or 3 | GND; both connect to ground in this schematic | Common contact, COM |

R925 pulls `PWRBTN_L_HW` to `+3.3V_LDO` through 1 kohm. C612 is 0.1 microfarad to ground.
Sheet 46 routes this active-low signal to the IT5570 EC input `PWRSW/GPB3`.
The 40-pin connector on sheet 44 has no named `PWRBTN_L_HW` contact.
The source shows the button route on sheets 46 and 48, without a dedicated external POWER header.
These are switch package pin numbers. They are not 40-pin or debug-header pin numbers.

Use an isolated, normally open dry contact across SW0 pin 1 and pin 2 or 3.
Do not feed relay-module VCC, UART TX, DTR or RTS into the switch circuit.
With power and backfeeding cables disconnected, verify the PCB revision and locate SW0 by continuity to R927 and GND.
Do not infer the pad orientation from this schematic or from a different switch footprint.
Verify that the physical button shorts the selected pair only while pressed.
Attach insulated wires across the button only after these checks.
Start with a bounded short pulse, such as 0.2 seconds, then verify release and the resulting board state.
That pulse duration is a test starting point, not a vendor timing specification.

A dry contact emulates the physical button. It does not guarantee recovery from a failed S5 wake path.
Provide independently controlled input power when a complete cold reset is required.
No relay installation, electrical measurement or remote power cycle was performed for this source review.

## Instrument and firmware scope

The firmware source maps mode0 GPIO015/016/017 to S5 GPIO1 local0/1/2 and header contacts 11/13/12.
This is a source mapping, not a measured electrical pin map or proof of current mux state.
The fixed input profile sets only the three direction bits and reserves those lines against output or child attachment.
Initial high readings do not qualify external transitions, debounce, PPS, wake or suspend/resume.

UART1 and UART3 use separately queried functional clocks 264 and 266, each reporting 100 MHz in the observed profile.
Same-open termios checks cover UART1 at 230400 8N1 and UART3 at 9600/115200 8N1.
They do not measure wire baud, validate external pinmux or exchange instrument data.
The combined UART/GPI5 profile passed automatic warm startup with the console and network available; its cold startup remains unqualified.

Native SCMI reports BASE and CLOCK 2.0, 273 clocks and eight asynchronous slots in bounded exchanges.
Clock67 rate telemetry is zero; this is not a measured gate waveform. The short CLOCK2.0 entity reply remains rejected.
A separate manual native profile enables and disables clock67 around VPU identity 0x56648002, four cores/four slots and SVN 0xe0c1afe1.
It does not control functional clock271, measure rails or establish unlimited runtime power management.
The accepted closed VPU bootstrap requires a full power cycle before another epoch; warm retry and post-exposure reclamation are unqualified.

Sources: `os-cix-uart-scope`, `os-cix-gpio-scope`, `os-cix-platform-scope` and `os-cix-vpu-scope` in [sources.json](../../sources.json).
