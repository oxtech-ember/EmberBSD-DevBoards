# FAT boot volumes: filesystem checks and startup

This is a storage dependency shared by boot paths that use FAT.
It is not specific to A733, U-Boot or a particular board.
Reading a kernel from FAT does not prove that the operating system's startup check will accept the filesystem.

## Primary and backup boot sectors

The pinned EmberBSD FAT32 checker compares part of the primary boot sector with its backup.
That range includes the volume-label field.
A label-only difference can therefore trigger `backup ... mismatch with primary bootblock`.
The mismatch path calls `pfatal` but does not itself repair the differing bytes.

In preen mode, `pfatal` exits with a failed-check status.
Outside preen mode, it prints the diagnostic and can return to the checker.
Consequently, a zero status from a manual check does not prove that startup preen will succeed.
The `-y` option does not add a repair operation to this mismatch path.
These details apply to the pinned sources; recheck the implementation after an update.

## Investigation boundaries

Identify the exact device, partition, capacity and filesystem before any repair.
Keep a verified copy of the complete affected partition and its original boot sectors.
Do not repair a mounted writable filesystem.
Read sector size and backup location from validated filesystem metadata.
Do not assume that every volume uses 512-byte sectors or backup sector 6.

Compare the complete sectors and distinguish label differences from geometry or other structural differences.
A mismatch alone does not identify which copy is authoritative.
Do not copy a boot sector from another card or a generic board image.
After a justified repair, read back the changed data and run the startup-equivalent check on the unmounted volume.
Retain the backup until the normal boot path and required files are verified.

The implementation owner is EmberBSD:

- [FAT32 boot-sector comparison](https://github.com/oxtech-ember/EmberBSD/blob/ad698a6e40ea89d72249f76d06913be29a5ab90c/sbin/fsck_msdos/boot.c).
- [Preen error handling](https://github.com/oxtech-ember/EmberBSD/blob/ad698a6e40ea89d72249f76d06913be29a5ab90c/sbin/fsck/fsutil.c).

Source IDs: `os-fat-boot-check`, `os-fsck-preen` in [sources.json](../sources.json).
