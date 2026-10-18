# Apple A7 (S5L8960X) platform research entry

Boot chain, hardware map and bring-up boundaries for EmberBSD arm64.
The SoC family covers devices identified as iPhone6,1 (N51) and iPhone6,2 (N53).

## Boot chain

The boot chain is fixed in mask ROM and cannot be modified:

```
SecureROM → iBSS → iBEC → kernel
```

EmberBSD targets the **RAM boot** model (no internal storage writes):

```
SecureROM → [extended DFU access] → pongoOS → EmberBSD kernel (x0 = FDT)
```

### SecureROM entry

The boot ROM provides a USB DFU mode.
On this SoC generation the DFU communication channel supports
an extended access mode that allows unsigned code execution in RAM.
This is the entry point for all alternative operating system work.
No storage writes occur during this stage.

### pongoOS as the pre-boot environment

[pongoOS](https://github.com/konradybcio/pongoOS) is an open-source
pre-boot environment that:

1. Receives control in SecureROM DFU mode
2. Initializes the platform (MMU, clock, display)
3. Converts the Apple Device Tree (ADT) to a standard Flattened Device Tree
4. Loads an arm64 kernel image (raw or LZMA-compressed) into DRAM
5. Passes control using the standard arm64 boot protocol

License: MIT-like (permission notice, no warranty). Running it is fine;
review the full text before incorporating source code into BSD-licensed trees.

### Kernel entry protocol

pongoOS uses the same convention as U-Boot on arm64:

- **x0** = physical address of the Flattened Device Tree blob
- **x1..x3** = zero
- MMU off, caches off, entry at EL1
- Kernel placed at `0x803000000` (DRAM base + offset)
- FDT placed immediately after the kernel image (8-byte aligned)

The kernel image can be either:
- Raw arm64 `Image` format (first 8 bytes = branch, bytes 16-23 = size)
- LZMA-compressed Image (pongoOS decompresses before boot)

### Page size

The A7 supports both 4K and 16K pages.
Use **4K** for A7–A8X (confirmed by postmarketOS and SoMainline).
16K pages are for A9 and newer.

## Hardware map

Addresses from mainline Linux `s5l8960x.dtsi` (dual-licensed GPL-2.0+ OR MIT).

| Block | Compatible | Base | IRQ | Notes |
|---|---|---|---|---|
| UART0 | `apple,s5l-uart` | 0x20a0a0000 | AIC 140 | reg-io-width 4; only console |
| Interrupt controller | `apple,s5l8960x-aic` | 0x20e100000 | — | Non-GIC; 3 cells; see below |
| ARM generic timer | `arm,armv8-timer` | (sysreg) | FIQ | No EL2 on A7 |
| Watchdog | `apple,s5l8960x-wdt` | 0x20e027000 | AIC 4 | |
| Pin control | — | 0x20e300000 | — | 200 GPIO lines |
| Power management | — | 0x20e000000 | — | Clock gating, power domains |
| USB (DWC2) | — | (see FDT) | — | Device-mode for console/network |
| I2C0–I2C3 | `apple,s5l8960x-i2c` | 0x20a110000–0x20a113000 | AIC 154–157 | |
| Reference clock | `clkref` | — | — | 24 MHz |

### Interrupt controller (AIC)

The A7 uses Apple's custom interrupt controller, **not** an ARM GIC.
This is the main architectural difference from all other EmberBSD arm64 platforms.

- Register space: 0x20e100000, 1 MB
- Interrupt cells: 3 (type, number, flags)
- Not compatible with existing `arm,gic-v2` or `arm,gic-v3` drivers
- A new `aic(4)` driver is required for the kernel port

### UART console

The `apple,s5l-uart` uses the **Samsung S3C2410 register model**, not 16550:

- Register set: ULCON, UCON, UFCON, UTRSTAT, UTXH, URXH (not THR/RBR/IER/LCR)
- 32-bit register access (`reg-io-width = 4`)
- Line control via ULCON (word length, stop bits, parity) — not LCR
- Status via UTRSTAT (TX empty, RX ready) — not LSR
- Data via single UTXH/URXH registers — no per-register offset stride
- FIFO control via UFCON — not FCR
- Linux binds this to the `serial_s3c.c` driver (`s3c2410` type)

Do not use a 16550 driver; the register layout is entirely different.
The boot environment leaves clocks enabled; minimal init is sufficient.
Physically routed to the Lightning connector on some device variants
(requires a specific adapter; see community documentation).

### USB device-mode

The USB controller (DWC2 family) supports device/gadget mode.
This is the primary console and network path for alternative OS boot:

- USB Ethernet (CDC-ECM) provides network + SSH access
- USB serial provides console output
- postmarketOS has confirmed this works on the same SoC

### Memory

- 1 GB LPDDR3
- DRAM base: 0x800000000
- No EL2 (hypervisor) support on this SoC generation
- Framebuffer handed off by the boot environment

## Device tree sources

Mainline Linux `arch/arm64/boot/dts/apple/` contains:

- `s5l8960x.dtsi` — SoC include (all IP blocks)
- `s5l8960x-5s.dtsi` — device-specific include (N51/N53)
- `s5l8960x-n51.dts` — variant N51
- `s5l8960x-n53.dts` — variant N53

**License**: GPL-2.0+ OR MIT dual-license.
The MIT branch is BSD-compatible; adaptation with attribution is permitted.

For pongoOS boot, the DTB is packed using `dtbpack.sh` into a multi-DTB
container that pongoOS selects from at boot time.

## EmberBSD port requirements

The kernel work follows the same pattern as the NetBSD Apple M1 port
(added August 2021, boots via m1n1/U-Boot):

1. **Platform scaffold**: `sys/arch/evbarm/apple/`
   - machdep, bootinfo, consinit
   - Receive x0=FDT, initialize aarch64

2. **Console driver**: `apple,s5l-uart`
   - Register-mapped UART at 0x20a0a0000
   - Minimal init (no clock enable needed; boot environment leaves it on)
   - Required for any debugging

3. **Interrupt controller**: `aic(4)`
   - New driver for Apple's non-GIC interrupt controller
   - Read mask/status registers, route to generic arm64 intr code
   - Required before any device driver can work

4. **Timer**: arm64 generic timer (already in NetBSD arm64)
   - Should work with minimal FDT plumbing
   - EL1 physical timer only (no EL2)

5. **USB device-mode**: DWC2 gadget
   - Reuse/port the existing DWC2 driver's device-mode path
   - USB CDC-ECM for network, USB serial for console

## Community status

postmarketOS runs a generic port on this SoC family:
- USB networking: works
- Display: works (simple framebuffer)
- Storage (NAND): not supported
- Charging: not supported under alternative OS
- Audio, Wi-Fi, Bluetooth, GPS: not supported

The community boot method is identical to our target:
extended DFU access → pongoOS → kernel + FDT + initramfs.

## Source IDs

Reference these in `sources.json`:
- `linux-apple-dts` — mainline Linux DTS for s5l8960x
- `pongo-os` — pre-boot environment source
- `som-howto` — community boot procedure
- `pmos-apple` — postmarketOS device page
