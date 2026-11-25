# Update an installed Zero 3W

Use the [installed system update procedure](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/tools/docs/installed-system-update.md) for package and OS updates.
For OS updates on microSD with vendor U-Boot, select the procedure for the card's layout.

## Two-slot microSD

For a fresh card, select `-h a733-update` in the [A733 image builder](https://github.com/oxtech-ember/EmberBSD/blob/3d0b206a05076152a7f8a50515b7c892a2a730db/distrib/utils/embedded/README.a733.md#zero-3w-two-slot-image).
This profile uses the normal Zero 3W device tree and the stock `EMBER64` kernel with the minimal no-LDAP userland and `comp`.
The card has an EFI boot partition and two FFS roots, `netbsd-root` (A) and `ember-root-b` (B).
Reserve both roots for the OS. The updater rebuilds the inactive root for each trial.

On an existing card that already has these dedicated wedges, boot slot A and keep the normal `boot.scr`.
Follow the [one-time setup for an existing card](https://github.com/oxtech-ember/EmberBSD/blob/3d0b206a05076152a7f8a50515b7c892a2a730db/distrib/utils/embedded/README.a733.md#enable-an-already-provisioned-card).
Keep a separate recovery card and a verified [UART0 connection](boot.md#uart0-console-v12).

For routine updates, follow the [automatic OS service procedure](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/tools/docs/automatic-system-update.md).
The service selects the signed release for the installed profile. U-Boot and the A733 watchdog control the trial boot.
Physical qualification of trial confirmation and watchdog rollback on Zero 3W is pending.
See the [update architecture](https://github.com/oxtech-ember/EmberBSD-Docs/blob/main/modules/updates.md#os-delivery-and-activation) for service settings and data shared between slots.

## Manual update on single-root microSD

The remaining steps apply to a single FFS root with a normal boot entry and an independent diagnostic entry.
Commands run on the board unless they name the serial console.

Select the installation order from the kernel/userland ABI contract before writing files.
For the [versioned station association lifecycle](https://github.com/oxtech-ember/EmberBSD/blob/a46527bded5d83a3c9eb294d764a0d89837b129c/sys/net80211/association-lifecycle.md), install the matching kernel, modules and WPA userland before the first reboot.
The new kernel rejects old MLME requests; the new WPA backend also requires the matching kernel.
Do not restart networking between these installation stages.
For a cohort that retains the installed network ABI, kernel-first boot verification remains applicable.

### Download the normal boot set

The signed EmberBSD channel provides a normal boot set for the Zero 3W at OS revision `e120f07b8276e317e7bcb549de2816d0b49f5d84`.
It contains the raw and ELF kernels, four matching modules, both normal board trees and the shared U-Boot script.
Select the set for the installed board and boot mode. The Zero 4 graphics set contains a different device tree.

Use artifact ID `os-boot-aarch64-ember64-orangepi-zero3w-e120f07b8276e317` in the [shared download procedure](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/tools/docs/installed-system-update.md#select-and-fetch-the-release).
In the verified archive, check the board boot files with its `SHA256` list. Keep the installed diagnostic entry.
Before changing boot files, obtain the [matching minimal AArch64 userland sets](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/tools/docs/aarch64-base-update.md#published-minimal-userland-sets).
A minimal headless installation uses `base` and `etc`.

### Required inputs

Use one recorded build cohort from a single EmberBSD commit, called `REV` below.
Record its kernel release as `KREL` (for example, `11.1`) and the installed `uname -r` as `OLD_KREL`.
Take `KREL` from the new kernel's build metadata, not the currently running kernel.
To produce missing files, use the [SDK OS release builder](https://github.com/oxtech-ember/EmberBSD-SDK/blob/1e8103ae9357fa914ae82a58a1fd3d1f5c252321/docs/os-release.md) and the
[A733 DTB target](https://github.com/oxtech-ember/EmberBSD/blob/c5d1be911e44b58402a405333db205ba4ad1daaf/sys/arch/arm/sunxi/docs/a733-boot-modes.md#native-build-target).
The bundle contains:

| File | Purpose |
|---|---|
| `netbsd.img` | Native `EMBER64` kernel image for `booti` |
| `netbsd` | ELF kernel from the same build, installed as `/netbsd` |
| `sun60i-a733-orangepi-zero3w.dtb`, `sun60i-a733-orangepi-zero4.dtb` | Normal board trees selected by the boot script |
| `boot.scr` | U-Boot script image of [`orangepi-zero4-boot.cmd`](https://github.com/oxtech-ember/EmberBSD/blob/c5d1be911e44b58402a405333db205ba4ad1daaf/ember/boot/orangepi-zero4-boot.cmd) from `REV` |
| `modules/NAME.kmod` | One module for each name in the board's `/etc/modules.conf` |
| `base.tar.xz`, `etc.tar.xz`, optional `comp.tar.xz` | Matching userland sets. Include `comp` when the installed profile uses it. |
| `xbase.tar.xz`, `xcomp.tar.xz`, `xetc.tar.xz`, `xfont.tar.xz`, `xserver.tar.xz` | Optional X11 sets from the same destination tree |
| `orangepi-zero4-boot.cmd` | Script source from `REV`, kept as `boot.cmd` |
| `SHA256` inside `boot.tar.xz` | Hashes of the boot archive members. Each OS set has its own signed artifact record. |

Do not combine a new kernel with older modules or a DTB from another commit.
When producing a new release, build the base WPA tools against its net80211 headers.
A missing set or module stops the update; do not substitute a file from another build.
Install the X11 sets either all together or not at all.
`X11` below means that the bundle contains them and they are installed.
The producer checks the bundle before publishing it. On the device, verify each downloaded archive against its signed release record.
No file may contain a build-host path.
A Clang build must contain no GCC runtime file and no `GCC:` identification string.
GCC-profile text in `/usr/share/mk` is build-system data, not a GCC dependency.
`boot.scr` is a 64-byte legacy image header, an 8-byte script length table and the unchanged script text.

### Before any change

1. Connect the [UART0 console](boot.md#uart0-console-v12) and confirm the U-Boot prompt after interrupting autoboot.
   Wi-Fi is not a recovery path.
2. Record the loader environment at the prompt: `printenv devtype devnum distro_bootpart prefix scriptaddr boot_targets`.
   If `scriptaddr` is unset, use a free RAM address that the board's U-Boot documents; do not guess one.
3. Verify the independent [diagnostic entry](boot.md#diagnostic-boot-selection) through the actual loader.
   Use the recorded storage values and the diagnostic directory as prefix:

   ```text
   setenv prefix diagnostic/
   setenv ember_boot_mode diagnostic
   load ${devtype} ${devnum}:${distro_bootpart} ${scriptaddr} ${prefix}boot.scr
   source ${scriptaddr}
   ```

   The kernel must start with the diagnostic tree.
   `ofctl -p /soc/gpu@1800000 netbsd,observe-only` and `ofctl -p /soc/display-engine@5000000 netbsd,observe-only` must list the property.
4. Run the same entry once with a nonexistent prefix.
   U-Boot must stop with a load error and return to its prompt; it must not boot the normal files.
5. Boot normally and record the current state:

   ```sh
   sysctl -n kern.buildinfo
   uname -v
   modstat | grep filesys
   cat /etc/modules.conf
   df -k / /boot
   ifconfig aicwf0
   wpa_cli -i aicwf0 status
   ```

Stop if any check fails. Repair the recovery route before updating the normal bundle.

#### Space

`/boot` is a small FAT volume.
The update stages the new `netbsd.img` beside the old one before a rename.
`df -k /boot` must show more free space than the size of the new `netbsd.img`, both DTBs and `boot.scr`, plus 1024 KiB.
Do not delete `netbsd.recovery`, the diagnostic directory or another recovery file to create space.
If space is insufficient, stop and plan a separate cleanup.

The root file system holds the staged bundle, the backups and a test tree.
Its free space must exceed twice the uncompressed size of the installed sets plus the backup size.
The X11 sets add several hundred MB.
`tar -tvJf SET` lists the uncompressed sizes.

### Stage and verify the bundle

Copy the downloaded archives into a new root-owned directory with mode 0700 on FFS.
Use `/var/update/REV` below for this directory. Recheck each copy against its own authenticated release record.
The outer digest of `boot.tar.xz` and the published digests of `base.tar.xz` and `etc.tar.xz` identify separate archives.
Extract the verified boot archive in that directory and check its internal list:

```sh
cd /var/update/REV || exit 1
tar -xpf boot.tar.xz || exit 1
cksum -a sha256 -c SHA256 || exit 1
tail -c +73 boot.scr | cmp - orangepi-zero4-boot.cmd
```

The script text in `boot.scr` must match `orangepi-zero4-boot.cmd` byte for byte.
Stop on any mismatch.

Check the new userland before installing it.
Extract the sets into a test tree and run its loader, shell, OpenSSL and SSH in a chroot:

```sh
mkdir /var/update/REV-root
sets="base etc"
[ -f comp.tar.xz ] && sets="$sets comp"
[ -f xbase.tar.xz ] && sets="$sets xbase xetc"   # X11 only
for set in $sets; do tar -xpJf "$set.tar.xz" -C /var/update/REV-root; done
mkdir -p /var/update/REV-root/dev
mknod /var/update/REV-root/dev/null c 0 2
chroot /var/update/REV-root /bin/sh -c 'echo ok; /usr/bin/openssl version; /usr/bin/ssh -V'
[ -f xbase.tar.xz ] && chroot /var/update/REV-root /usr/X11R7/bin/xdpyinfo -version
rm /var/update/REV-root/dev/null
```

`c 0 2` matches the board's existing `/dev/null`; check it with `ls -l /dev/null`.

### Back up

Keep backups readable by root only. `/etc` contains SSH host keys and Wi-Fi credentials.
`OLD` is the revision from `kern.buildinfo`.

```sh
umask 077
bk=/var/backups/ember-update-OLD
mkdir -p "$bk"
tar -cf "$bk/boot.tar" -C /boot .
tar -cf "$bk/stand.tar" -C / stand
tar -cf "$bk/etc.tar" -C / etc
cp -p /netbsd "$bk/netbsd.elf"
```

Run the inventory and staging steps from the [native set procedure](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/tools/docs/installed-system-update.md#native-set-installation).
Use its exact selected member list for the backup and for rollback. In the same shell:

```sh
cp "$state/set-paths" "$bk/set-paths" || exit 1
: > "$bk/replaced"; : > "$bk/added"
while read -r path; do
    if [ -e "/$path" ] || [ -h "/$path" ]; then
        [ -d "/$path" ] && [ ! -h "/$path" ] || echo "$path" >> "$bk/replaced"
    else
        echo "$path" >> "$bk/added"
    fi
done < "$bk/set-paths"
tar -cf "$bk/userland.tar" -C / -T "$bk/replaced"
cd "$bk" && cksum -a sha256 boot.tar stand.tar etc.tar netbsd.elf userland.tar set-paths replaced added > SHA256
```

Use uncompressed archives. `/rescue/tar` then restores them without `xz`.
Copy the backup directory to another host over SSH.
Verify the copied files with the same SHA256 list before continuing.
Keep the previous recovery copies in `/stand` and `/boot` until the new build is accepted.

### Stage 1: kernel, modules, DTBs and boot script

Write the kernel image under a temporary name and rename it after `cmp` succeeds.
Renames on the same FAT volume need no extra space.

```sh
new=/var/update/REV
cd /boot
cp "$new/netbsd.img" netbsd.new && cmp "$new/netbsd.img" netbsd.new &&
mv netbsd.img netbsd.old && mv netbsd.new netbsd.img
for dtb in sun60i-a733-orangepi-zero3w.dtb sun60i-a733-orangepi-zero4.dtb; do
    cp "$new/$dtb" "dtb/allwinner/$dtb.new"
    mv "dtb/allwinner/$dtb" "dtb/allwinner/$dtb.old"
    mv "dtb/allwinner/$dtb.new" "dtb/allwinner/$dtb"
done
mv boot.scr boot.scr.old && cp "$new/boot.scr" boot.scr
mv boot.cmd boot.cmd.old && cp "$new/orangepi-zero4-boot.cmd" boot.cmd
cp /netbsd /onetbsd && cp "$new/netbsd" /netbsd.new && mv /netbsd.new /netbsd
m=/stand/evbarm/$KREL
if [ -d "$m/modules" ]; then mv "$m/modules" "$m/modules.pre-OLD"; fi
sed -e 's/#.*//' /etc/modules.conf | while read -r name options; do
    [ -n "$name" ] || continue
    mkdir -p "$m/modules/$name"
    cp "$new/modules/$name.kmod" "$m/modules/$name/"
done
sync
```

Compare every installed file with the bundle's `SHA256` list.
Do not change the diagnostic directory or `netbsd.recovery`.

For the versioned MLME transition, continue directly to stage 2 without rebooting or restarting networking.
Otherwise, reboot with `shutdown -r now` and watch the serial console.
The normal entry must set `ember_boot_mode` to `normal` or leave it unset.

After the reboot:

- `sysctl -n kern.buildinfo` reports `EmberBSD:REV`.
- `modstat | grep filesys` lists the modules from `/etc/modules.conf`.
- `dmesg` shows no module load, firmware or file system errors.
- `ifconfig aicwf0` is up and `wpa_cli -i aicwf0 status` reports `wpa_state=COMPLETED`.
- SSH from another host succeeds.

Use [rollback A](#rollback-a-kernel-bundle) if any check fails.
If userland was also replaced for an ABI transition, restore its matching previous cohort with [rollback B](#rollback-b-userland) before booting normally.

### Stage 2: userland

Follow the [native set installation procedure](https://github.com/oxtech-ember/EmberBSD/blob/main/ember/tools/docs/installed-system-update.md#native-set-installation) for base files and configuration.
After a kernel-first reboot, reopen the original staging directories and load the saved selection as the common procedure describes.
For a station ABI change, finish userland installation before the first reboot into the new kernel.
On a headless profile, preserve both firmware locations and the installed Wi-Fi settings. Use the recorded `/etc/modules.conf` for this board.

For a profile with additional sets, use the same backup and configuration merge. Install the selected `comp` and X11 payloads.
Stage `xetc` with `etc` before merging. Keep local access and the diagnostic boot files.
After reboot, repeat the stage 1 checks. With X11, check `X -version` and `xdpyinfo -version`; start X with the display attached.
Use [rollback B](#rollback-b-userland) for a failed userland replacement and restore the matching kernel when the station ABI changes.

### Rollback A: kernel bundle

If the normal boot fails, interrupt U-Boot on the serial console.
Boot the previous files in single-user mode, so that `rc` loads no new module into the old kernel.
Use the storage values recorded before the update:

```text
setenv bootargs "root=NAME=netbsd-root -s"
load ${devtype} ${devnum}:${distro_bootpart} 0x4fa00000 ${prefix}dtb/allwinner/sun60i-a733-orangepi-zero3w.dtb.old
fdt addr 0x4fa00000
fdt resize 8192
load ${devtype} ${devnum}:${distro_bootpart} 0x44000000 ${prefix}netbsd.old
booti 0x44000000 - 0x4fa00000
```

Stop if a `load` or `fdt` command fails; do not run `booti` after a failure.
If this path fails, use the verified diagnostic entry; it reads only files under its own prefix.
If no entry starts, use the separate recovery card.

In the single-user shell, restore the previous files:

```sh
fsck -p
mount -uw /
mount /boot
cd /boot
mv netbsd.img netbsd.failed && mv netbsd.old netbsd.img
for dtb in sun60i-a733-orangepi-zero3w.dtb sun60i-a733-orangepi-zero4.dtb; do
    mv "dtb/allwinner/$dtb.old" "dtb/allwinner/$dtb"
done
mv boot.scr.old boot.scr && mv boot.cmd.old boot.cmd
mv /onetbsd /netbsd
m=/stand/evbarm/$KREL
mv "$m/modules" "$m/modules.failed"
if [ "$KREL" = "$OLD_KREL" ]; then mv "$m/modules.pre-OLD" "$m/modules"; fi
sync
```

Delete `netbsd.failed` only if FAT space is needed later.
Compare the restored files with the members of `boot.tar` and `stand.tar` in the backup.
When `KREL` differs from `OLD_KREL`, the old release's module directory was left in place.
For an ABI transition, if the new userland is still installed, restore the previous userland with rollback B before rebooting normally.
Then confirm that `kern.buildinfo` reports `EmberBSD:OLD`.

### Rollback B: userland

Boot to single-user mode and mount `/` read-write.
Use only `/rescue` tools, because the dynamic userland can be inconsistent.

```sh
bk=/var/backups/ember-update-OLD
cd /
/rescue/tar -xpf "$bk/userland.tar"
/rescue/tar -xpf "$bk/etc.tar"
```

Remove the regular files and links listed in `$bk/added`.
This also removes X11 files that the update added.
Remove listed directories only when they are empty.
If the kernel also needs to return, complete rollback A before rebooting.
For an ABI transition, do not boot restored userland until its matching previous kernel and modules are restored as well.
Then reboot and repeat the post-update checks.

Sources: `os-a733-boot-modes`, `os-aarch64-base-update`, `os-net80211-association-lifecycle` and `sdk-os-release` in [sources.json](../../sources.json).
