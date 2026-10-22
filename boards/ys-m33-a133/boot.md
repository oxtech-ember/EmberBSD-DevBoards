# Boot, installation and recovery

The observed platform has Allwinner A133, 1 GiB DDR4 and nominal 32 GB eMMC.
Board and exact panel revisions are unknown. This profile covers a reference sample and one unopened factory sample.
It does not establish another YS-M33 revision or another A133 device.

## Retained vendor chain

The accepted installation retains vendor boot0, BL31, OP-TEE, U-Boot and display initialization.
The installed system boots autonomously from eMMC. UART on J1 supports 115200 baud interception on the reference sample;
connector contacts and electrical limits are not established here.
The vendor loader supplies the full board tree. A retained small DTB payload in an experimental Android v2 container has unestablished original provenance.
Do not present that payload as a reproducible firmware release.
RAM container trials required copying from 0x41000000 to 0x45000000 before bootm to avoid relocation overlap.
These addresses describe the inspected loader path, not arbitrary free RAM on another firmware.

## Closed-enclosure USB path

Use the USB-C device port and separate DC power. Cable negotiation must select USB device mode.
FEL detection alone does not establish ADB, fastboot or signed recovery access.
The observed Android 10 factory image is `a133-10.0-20231211.133302`.
It exposes root through `/system/xbin/su 0` while flash is locked and Android verified boot is green.
Recovery required root adbd after enumeration. Root access is a measured factory-image property, not a general Android assumption.

The [bounded installation record](evidence/cable-install.json) covers identification, per-device backups,
a locked signed-recovery/Android round trip, vendor unlock, selected image writes with full readback,
a first-boot recovery return and a subsequent normal eMMC restart without opening the enclosure or using UART.
It is an operator-controlled physical scenario, not a released fleet installer.
The OS owns preflight, backup formats, environment APIs, journaled stages and their executable checks.
Use [the OS tool documentation](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/tools/docs/a133/ys-m33-a133-cable-install.md) for current commands and API boundaries.

## Storage and per-device state

The inspected main eMMC area is 31,037,849,600 bytes with 17 GPT partitions.
The full env partition is 16 MiB; its editable prefix is 128 KiB. Boot and recovery are 32 MiB each.
The physical installation used a 4 GiB FFSv2 root within UDISK and retained the GPT and other Android/recovery partitions.
A filesystem image is not a whole-device replacement. Freshly inspect actual bounds before using any write API.
Keep a complete per-device capture, separate critical partitions and hardware boot0/boot1 copies.
A live Android image does not establish filesystem consistency. Quiescent recovery copies of UDISK and metadata have a separate consistency boundary.
Backups have not passed a full physical Android restore.

Factory environments differ. One observed profile has `bootcmd=run boot_normal` and delay 3;
another has `bootcmd=run setargs_mmc boot_normal`, delay 0 and an unused hook in boot_normal.
Never substitute another device's environment. Establish signed recovery and return to locked Android before unlock.
A failed or partial env write cannot be repaired by assuming that a generated CRC establishes durability.
The vendor secure-storage unlock persists independently of env restoration.
Unlocked/orange Android verified-boot state does not remove the early chain's authentication requirements.
Replacing warning artwork does not change that state.

## Watchdog and recovery availability

MCU7502 firmware 17.03.07 at I2C address 0x16 needs the supported keepalive every 20 seconds.
Its [hosted OS implementation](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/tools/mcu7502-keepalive.c) and service own setup.
A watchdog-disable acknowledgment did not prevent resets. Recovery needs compatible keepalive before long operations.
The observed unconfirmed first boot returned to signed USB recovery after a 120-second guard.
Cold power loss, corrupted-env recovery, complete restoration and fleet acceptance remain unqualified.

## Experimental own second stage

U-Boot v2026.10 reached an interactive RAM prompt and handed an existing kernel to FFS root and rc startup.
Vendor DRAM/display setup and secure firmware remained in place. No SPL or DRAM initialization was exercised.
The reference DDR4 runs at 744 MHz; a different board's LPDDR4 configuration is not an applicable initialization recipe.
Position-independent entry was required because the vendor loader placed the Image at 0x40080000.
A prearmed 16-second SoC watchdog returned the bounded kernel trial to ordinary boot with boot/env bytes unchanged.

The profile advertised only the lower 512 MiB. Vendor secure firmware still occupies part of it;
the whole advertised bank is not safe for allocation or memory tests. Complete reserved-memory and inherited framebuffer ownership remain unproven.
The probe supplies no eMMC loading, direct USB recovery, display initialization or independent MCU service.
Sustained handoff and a direct recovery return must be established before persistent second-stage installation.
Unsigned Android payload execution does not establish permission to replace boot0, BL31 or TOC1.

Sources: `os-ys-m33-reference`, `os-a133-install-reference`, `os-ys-m33-cable-receipt`, `os-a133-audio-driver`
and `os-a133-uboot-ram` in [sources.json](../../sources.json). The source pins identify bounded observations, not a current installed device.
