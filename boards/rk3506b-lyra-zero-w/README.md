# Rockchip RK3506B SBC, vendor model Luckfox Lyra Zero W

The Zero W has three 32-bit Cortex-A7 cores, 512 MB DDR3L, 256 MB SPI NAND, a microSD slot and a USB radio.
Luckfox specifies 2.4 GHz Wi-Fi 6 and Bluetooth 5.2/BLE. The PCB revision for this profile is unknown.
Use the Zero W image and wiring. The Lyra Ultra W uses eMMC. [Luckfox specifications](https://www.luckfox.com/Luckfox-Lyra-Zero-W)

Start with [boot and recovery](boot.md) to select the card layout. Use the [console and radio pin map](interfaces.md)
to distinguish a boot failure from a USB or antenna problem. See [design transfer](design.md) and the [SoC reference](../../socs/rockchip-rk3506b.md).

The [source evidence](evidence/sd-boot-inputs.json) covers the bootloader package and a Linux card image.
A [factory reset trace](evidence/factory-reset-uart.json) identifies the installed SPL, SPI NAND boot and USB radio.
The [cold boot test](evidence/sd-console.json) reached the EmberBSD shell on the FFS root. The [capability record](board.json) gives the limits for the onboard radio.
