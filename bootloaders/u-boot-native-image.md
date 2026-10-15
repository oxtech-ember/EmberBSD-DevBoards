# U-Boot: native AArch64 image and boot entry

This contract covers the A733 path that uses vendor U-Boot and `booti`.
It is separate from the [efiboot ELF contract](efiboot.md).
Establish the active loader and its commands before choosing an artifact.
A native kernel image and an ELF kernel are different build outputs.
Renaming either file does not convert it.

## Entry and file layout

The EmberBSD A733 image builder wraps the source boot script as `boot.scr`.
The script loads `netbsd.img` and a board-specific DTB before it calls `booti`.
The selected loader entry, storage partition and prefix determine the files that are read.
A readable kernel file alone does not create an automatic boot entry.
Check the active U-Boot environment; a different build can use a different entry mechanism.

The pinned EmberBSD script expects the DTB under `dtb/allwinner/`, relative to its selected prefix.
A DTB placed only beside the kernel does not satisfy that path.
Keep the script, kernel and DTB layout consistent with the image builder.
Preserve the board-specific tree when adapting the layout to a custom device.
Do not infer a board variant from its hostname.

## Transfer to another design

Load addresses, available RAM and reserved memory must agree.
The script reserves extra DTB space because U-Boot adds properties before kernel entry.
Root-device selection and the console route must match the actual storage and wiring.
Use the [OS script](https://github.com/oxtech-ember/EmberBSD/blob/ad698a6e40ea89d72249f76d06913be29a5ab90c/ember/boot/orangepi-zero4-boot.cmd)
for the exact implementation. Do not maintain a second copy here.

A successful manual launch proves only that invocation and its supplied files.
Volatile environment changes do not establish persistent automatic boot.
Verify a normal startup through the selected entry after installing a matched bundle.
Keep a previous matched bundle and a separate recovery route.
Read [FAT boot-volume checks](fat-boot-volume.md) when this path uses FAT storage.

Source ID: `os-a733-boot` in [sources.json](../sources.json).
