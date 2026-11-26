# MicroSD boot and recovery

## EmberBSD port input

The first port selects the Armbian bootloader for the exact Zero W model.
The RK3506B ROM reads the Rockchip ID block. The combined image provides DDR initialization, SPL, trusted firmware and U-Boot.
The package metadata names DDR initialization v1.06 at 750 MHz and TEE v2.10.
Its U-Boot is 2025.10-rc4 with Armbian patches and the `luckfox-lyra-zero-w-rk3506b_defconfig` configuration.
[U-Boot source configuration](https://github.com/Kwiboo/u-boot-rockchip/blob/0b8e25bd9e16e8043b600e8f49b926b95572dc47/configs/luckfox-lyra-zero-w-rk3506b_defconfig)

The package contains one 9,074,176-byte bootloader image. Use the [combined Rockchip SD loader contract](../../bootloaders/rockchip-sd-bootstd.md).
The port reserves the first 16 MiB and places its FAT boot partition at or above LBA 32768.
The OS card builder owns the boot entry, matched ARM kernel, board DTB and root filesystem.
[Package and binary checks](evidence/sd-boot-inputs.json)

## Luckfox SDK layout

The factory SDK uses the `luckfox_lyra_zero-w_buildroot_sdmmc_defconfig` profile.
It selects U-Boot 2017.09, `rk3506b-luckfox-lyra-zero-w-sd.dts` and a compressed ARM kernel in a FIT.
The vendor `boot_fit` path reads a named GPT partition.
The table gives the vendor layout and the structures observed in the community Ubuntu v0.0.2 card image.

| Object | Start LBA | Size | Contents |
|---|---:|---:|---|
| ID block | 64 | Before first partition | Rockchip `RKNS` header and first-stage loader |
| `uboot` | 8192 | 4 MiB | U-Boot, OP-TEE and the loader DTB in a FIT |
| `boot` | 16384 | 12 MiB | ARM kernel, board DTB and Rockchip resource image in a second FIT |
| `rootfs` | 65536 | Remaining space in the SDK layout | Linux ext4 root on partition 3 |

For this SDK snapshot, `RK3506BMINIALL.ini` pairs DDR initialization v1.04 with SPL v1.10.
The USB download plug is v1.02. The packaged Armbian loader and the SDK partitions overlap on disk.
Select one complete layout for a card. Read back the actual layout and use UART0 to identify the loader and selected boot entry.
[SDK SD profile](https://github.com/EliSofke/LuckfoxLyraSDK/blob/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/device/rockchip/.chips/rk3506/luckfox_lyra_zero-w_buildroot_sdmmc_defconfig) · [SD partition definition](https://github.com/EliSofke/LuckfoxLyraSDK/blob/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/device/rockchip/.chips/rk3506/parameter-lyra-sdmmc.txt) · [Loader manifest](https://github.com/EliSofke/LuckfoxLyraSDK/blob/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/rkbin/RKBOOT/RK3506BMINIALL.ini)

## Power, console and recovery

Use 5 V on the USB-C connector marked **PWR & OTG** (H3).
Use the [3.3 V UART0 console](interfaces.md#uart0-console) during cold boot.
Power off before changing the card. Removing the test card restores access to the existing SPI NAND boot path if that image is intact.
The [ROM normally checks SPI NAND before microSD](../../socs/rockchip-rk3506b.md). The first loader can select another medium.
On this schematic, BOOT connects to SARADC_IN1. With both media populated, identify the first loader and its selected U-Boot on UART0.

With the slot empty, the factory SPL tried MMC1 and then loaded U-Boot from MTD1. Linux reached its login prompt. [Reset observation](evidence/factory-reset-uart.json)

For MMC, the vendor SDK SPL first looks up the GPT name `uboot`, then tries raw sector `0x4000` with its Rockchip defaults. The selected Armbian loader places its second-stage FIT at that sector when written at LBA 64. Its FIT hashes match the U-Boot, OP-TEE and Zero W DTB payloads. A boot with the card inserted must confirm the handoff on the tested unit.
[Vendor SPL MMC path](https://github.com/EliSofke/LuckfoxLyraSDK/blob/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/u-boot/common/spl/spl_mmc.c) · [Rockchip sector defaults](https://github.com/EliSofke/LuckfoxLyraSDK/blob/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/u-boot/common/spl/Kconfig)

Luckfox documents USB Loader mode separately from the card reader. With power disconnected, hold BOOT while connecting H3 to the host.
Release BOOT after the host detects a Loader device. With power already present, hold RESET and BOOT, release RESET, then release BOOT after detection.
Check the reported mode before choosing an operation. The vendor USB flash path targets the internal SPI NAND.
If the loader fails, use the vendor's **Lyra Zero W** MaskRom test-point illustration.
Prepare a replacement microSD in a card reader. [Vendor recovery guide](https://wiki.luckfox.com/Luckfox-Lyra/Getting-Started/overview/) · [Card and USB image selection](https://wiki.luckfox.com/Luckfox-Lyra/Getting-Started/Image-flashing/)
