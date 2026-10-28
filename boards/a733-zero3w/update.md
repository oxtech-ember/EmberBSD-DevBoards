# Update an installed Zero 3W

This recipe updates an existing EmberBSD microSD installation that starts through vendor U-Boot and `boot.scr`.
It replaces the native kernel, the loaded kernel modules, both A733 board DTBs, the normal boot script and the `base`, `comp` and `etc` sets.
It leaves packages, X11 sets, `/rescue`, `/libdata/firmware`, the diagnostic directory and other recovery files unchanged.
Commands run as root on the board unless a step names the serial console or another host.
This is a procedure, not physical acceptance of a particular build.

The general AArch64 rules are in the [OS base update guide](https://github.com/oxtech-ember/EmberBSD/blob/c5d1be911e44b58402a405333db205ba4ad1daaf/ember/tools/docs/aarch64-base-update.md).
Follow its order: kernel and matching modules first, reboot and verify, then userland.

## Required inputs

Use one recorded build cohort from a single EmberBSD commit, called `REV` below.
Build it with the [SDK OS release builder](https://github.com/oxtech-ember/EmberBSD-SDK/blob/1e8103ae9357fa914ae82a58a1fd3d1f5c252321/docs/os-release.md) and the
[A733 DTB target](https://github.com/oxtech-ember/EmberBSD/blob/c5d1be911e44b58402a405333db205ba4ad1daaf/sys/arch/arm/sunxi/docs/a733-boot-modes.md#native-build-target).
The bundle contains:

| File | Purpose |
|---|---|
| `netbsd.img` | Native `EMBER64` kernel image for `booti` |
| `netbsd` | ELF kernel from the same build, installed as `/netbsd` |
| `sun60i-a733-orangepi-zero3w.dtb`, `sun60i-a733-orangepi-zero4.dtb` | Normal board trees selected by the boot script |
| `boot.scr` | U-Boot script image of [`orangepi-zero4-boot.cmd`](https://github.com/oxtech-ember/EmberBSD/blob/c5d1be911e44b58402a405333db205ba4ad1daaf/ember/boot/orangepi-zero4-boot.cmd) from `REV` |
| `modules/NAME.kmod` | One module for each name in the board's `/etc/modules.conf` |
| `base.tar.xz`, `comp.tar.xz`, `etc.tar.xz` | Userland sets from the same destination tree |
| `orangepi-zero4-boot.cmd` | Script source from `REV`, kept as `boot.cmd` |
| `SHA256` | BSD-style SHA256 lines for every file above |

Do not combine a new kernel with older modules or a DTB from another commit.
A missing set or module stops the update; do not substitute a file from another build.
`boot.scr` is a 64-byte legacy image header, an 8-byte script length table and the unchanged script text.

## Before any change

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

### Space

`/boot` is a small FAT volume.
The update stages the new `netbsd.img` beside the old one before a rename.
`df -k /boot` must show more free space than the size of the new `netbsd.img`, both DTBs and `boot.scr`, plus 1024 KiB.
Do not delete `netbsd.recovery`, the diagnostic directory or another recovery file to create space.
If space is insufficient, stop and plan a separate cleanup.

The root file system holds the staged bundle, the backups and a test tree.
Its free space must exceed twice the uncompressed size of the three sets plus the backup size.
`tar -tvJf SET` lists the uncompressed sizes.

## Stage and verify the bundle

Copy the bundle to `/var/update/REV` on the root file system.

```sh
cd /var/update/REV
cksum -a sha256 -c SHA256
tail -c +73 boot.scr | cmp - orangepi-zero4-boot.cmd
```

The script text in `boot.scr` must match `orangepi-zero4-boot.cmd` byte for byte.
Stop on any mismatch.

Check the new userland before installing it.
Extract the sets into a test tree and run its loader, shell, OpenSSL and SSH in a chroot:

```sh
mkdir /var/update/REV-root
for set in base comp etc; do tar -xpJf "$set.tar.xz" -C /var/update/REV-root; done
mkdir -p /var/update/REV-root/dev
mknod /var/update/REV-root/dev/null c 0 2
chroot /var/update/REV-root /bin/sh -c 'echo ok; /usr/bin/openssl version; /usr/bin/ssh -V'
rm /var/update/REV-root/dev/null
```

`c 0 2` matches the board's existing `/dev/null`; check it with `ls -l /dev/null`.

## Back up

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

Back up every existing file that the new `base` and `comp` sets replace.
Record the files that the sets add, so that a rollback can remove them.

```sh
new=/var/update/REV
for set in base comp; do tar -tJf "$new/$set.tar.xz"; done | sort -u > "$bk/set-paths"
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

## Stage 1: kernel, modules, DTBs and boot script

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
m=/stand/evbarm/11.0
mv "$m/modules" "$m/modules.pre-OLD"
sed -e 's/#.*//' /etc/modules.conf | while read -r name options; do
    [ -n "$name" ] || continue
    mkdir -p "$m/modules/$name"
    cp "$new/modules/$name.kmod" "$m/modules/$name/"
done
sync
```

Compare every installed file with the bundle's `SHA256` list.
Do not change the diagnostic directory or `netbsd.recovery`.

Reboot with `shutdown -r now` and watch the serial console.
The normal entry must set `ember_boot_mode` to `normal` or leave it unset.

After the reboot:

- `sysctl -n kern.buildinfo` reports `EmberBSD:REV`.
- `modstat | grep filesys` lists the modules from `/etc/modules.conf`.
- `dmesg` shows no module load, firmware or file system errors.
- `ifconfig aicwf0` is up and `wpa_cli -i aicwf0 status` reports `wpa_state=COMPLETED`.
- SSH from another host succeeds.

Use [rollback A](#rollback-a-kernel-bundle) if any check fails.

## Stage 2: userland

Install the userland only after stage 1 passes.
Do not extract the `etc` set over `/`.

```sh
new=/var/update/REV
cd /
tar -xpUJf "$new/base.tar.xz"
tar -xpUJf "$new/comp.tar.xz"
mkdir /var/update/REV-etc
tar -xpJf "$new/etc.tar.xz" -C /var/update/REV-etc
etcupdate -s /var/update/REV-etc
postinstall -s /var/update/REV-etc check
```

`-U` unlinks each file before it writes the new one; running programs keep the old file.
In `etcupdate`, keep the installed `rc.conf`, `modules.conf`, `wpa_supplicant.conf`, SSH host keys and local accounts.
Merge only reviewed upstream changes.
Run `postinstall -s /var/update/REV-etc fix ITEM` only for reviewed items, then repeat `check`.

Reboot so that services load the new libraries.
Repeat the stage 1 checks and confirm existing services and packages start.
Keep the backup and the staged bundle until the build is accepted.

## Rollback A: kernel bundle

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
m=/stand/evbarm/11.0
mv "$m/modules" "$m/modules.failed" && mv "$m/modules.pre-OLD" "$m/modules"
sync
```

Delete `netbsd.failed` only if FAT space is needed later.
Compare the restored files with the members of `boot.tar` and `stand.tar` in the backup.
Reboot normally and confirm that `kern.buildinfo` reports `EmberBSD:OLD`.

## Rollback B: userland

Boot to single-user mode and mount `/` read-write.
Use only `/rescue` tools, because the dynamic userland can be inconsistent.

```sh
bk=/var/backups/ember-update-OLD
cd /
/rescue/tar -xpf "$bk/userland.tar"
/rescue/tar -xpf "$bk/etc.tar"
```

Remove the regular files and links listed in `$bk/added`.
Remove listed directories only when they are empty.
Reboot and repeat the post-update checks.
If the kernel also needs to return, follow rollback A afterwards.

Sources: `os-a733-boot-modes`, `os-aarch64-base-update` and `sdk-os-release` in [sources.json](../../sources.json).
