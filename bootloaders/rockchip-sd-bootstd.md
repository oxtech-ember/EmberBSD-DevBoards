# Rockchip combined SD loader and U-Boot Standard Boot

This contract covers the Armbian RK3506B package used by the [Lyra Zero W port](../boards/rk3506b-lyra-zero-w/boot.md).
The package supplies a combined `u-boot-rockchip.bin` matched to the DDR type and board.
Its installer starts the image at byte 32768 (LBA 64 in 512-byte sectors). The bootloader extends beyond the ID block.
Reserve the full byte range before placing the first filesystem partition.

The packaged U-Boot configuration enables MMC, FAT, boot scripts, extlinux, `bootm` and `bootz`.
At reset, it runs `bootflow scan -lb`. The selected filesystem must contain a boot entry that this build can discover.
Keep the entry, kernel image format, load addresses and external DTB consistent.
Verify the loader file against the package, read back its exact range and inspect the boot entry on the card.
Cold-boot UART output identifies the selected boot device and proves whether execution reached the kernel.

The Luckfox SDK's `boot_fit` build uses a different partition and entry contract.
[Armbian board declaration](https://github.com/armbian/build/blob/ddd8583081188c8ec34ad919306b6e26aed329d2/config/boards/luckfox-lyra-zero-w.csc) · [Armbian RK3506 bootloader selection and install offset](https://github.com/armbian/build/blob/ddd8583081188c8ec34ad919306b6e26aed329d2/config/sources/families/rockchip.conf) · [Inspected package](../boards/rk3506b-lyra-zero-w/evidence/sd-boot-inputs.json)
