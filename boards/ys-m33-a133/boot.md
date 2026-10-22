# Boot and USB cable installation

## Scope

This record applies to the YS-M33 wall tablet with Allwinner A133.
It describes a cable-connected path that does not open the enclosure or use UART.
It is not an over-the-air update path or a general Android installation guide.

One unopened factory tablet completed the path on 2026-10-08.
Cold power cycles, complete Android restoration, recovery from a corrupt loader environment, and fleet acceptance remain untested.
See the [physical evidence](evidence/cable-install.json).

## Boot chain

The tested path retains the vendor boot0, BL31, OP-TEE, U-Boot and display initialization.
It installs EmberBSD into selected eMMC areas and does not replace the secure boot chain.
The normal installed system boots from eMMC.

The board revision and exact panel assembly revision are not established.
Do not apply the observed partition layout, environment or factory Android behavior to another tablet.
Use the [EmberBSD board record](https://github.com/oxtech-ember/EmberBSD/blob/12c35f22fd899b4d697e20986521226efaf6d8cb/ember/boards/ys-m33-a133.md) for later implementation changes.

## Cable connection and inspection

Use the tablet's USB-C device port and separate DC power.
The cable and host port must negotiate USB device mode.
FEL detection alone does not prove that ADB or recovery is available.
The host needs Ruby and Android platform-tools.

Begin with the EmberBSD [read-only installation preflight](https://github.com/oxtech-ember/EmberBSD/blob/12c35f22fd899b4d697e20986521226efaf6d8cb/ember/boards/ys-m33-a133-cable-install.md#read-only-first-connection).
Run its commands from a matching EmberBSD source checkout.
Use `--serial` when more than one Android device is connected.
Use `--su` only when the inspected factory image provides the documented vendor `su` path.

The preflight performs bounded reads only.
It does not unlock, reboot, transfer files or write storage.
Even a complete inspection reports `installation_ready: false`.
Stop when the model, root access, device selection, partition bounds or recovery route differ from the inspected scenario.

## Observed installation stages

The physical record documents one successful factory-image scenario:

1. Identify the board and inspect its partition table.
2. Save per-device boot, environment, recovery and full-storage data.
3. Verify the backups and complete a locked recovery-to-Android round trip.
4. Unlock the vendor boot path and enter signed USB recovery.
5. Write the selected boot, root and resource areas and verify complete device readback hashes.
6. Trial the first EmberBSD boot with a recovery return, then establish normal eMMC boot.

These stages summarize a physical result. They are not a reusable writer procedure.
The current EmberBSD tools include guarded preparation and transfer components, but no accepted fleet installer.
Do not replace them with copied `dd` commands, fastboot assumptions, another tablet's backup, or another tablet's environment.
Read the current [installation boundaries and release acceptance](https://github.com/oxtech-ember/EmberBSD/blob/12c35f22fd899b4d697e20986521226efaf6d8cb/ember/boards/ys-m33-a133-cable-install.md) before preparing another device.

## Recovery and security limits

Signed USB recovery was reached without UART on the tested factory sample.
The same sample returned to its original locked Android state before unlock.
This does not prove full Android restoration, cold-start recovery, or recovery after a damaged loader environment.

The tested unlock changed the secure-boot status to unlocked.
Replacing warning artwork does not restore a locked state.
The vendor's early boot components and their signatures remain outside this installation path.
Keep per-device credentials, entropy seeds, backups and network settings separate.

Sources: `os-ys-m33-board`, `os-ys-m33-cable-install` and `os-ys-m33-cable-receipt` in [sources.json](../../sources.json).
