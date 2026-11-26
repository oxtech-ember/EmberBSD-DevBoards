# Rockchip RK3506B

Three Cortex-A7 application cores implement 32-bit ARMv7-A. A separate Cortex-M0 serves control workloads.
RK3506B uses external DDR memory. Its ROM supports SPI flash and SDMMC boot, and USB OTG device download.
Board wiring and firmware determine which routes are usable. [Rockchip data sheet, revision 1.0](https://github.com/LuckfoxTECH/Luckfox-Lyra-docs/blob/4d6c261ba996937b420e19494a6ff8e5cd0ccbbb/Docs/datasheets/Rockchip-RK3506B-Datasheet.pdf)

The typical ROM search order is SPI NOR, SPI NAND, eMMC, then SDMMC. A valid ID block starts the first loader.
The voltage on SARADC_IN0 can change that order. [Rockchip RK3506 TRM v1.2, part 1, section 1.2](https://rockchip.fr/Rockchip%20RK3506%20TRM%20V1.2%20Part1.pdf)

| Vendor device-tree node | Hardware contract |
|---|---|
| UART0 at `0xff0a0000` | DesignWare APB UART, register shift 2, 32-bit access, GIC SPI 34 |
| SDMMC at `0xff480000` | DesignWare mobile storage controller, GIC SPI 86, bus clock and card input clock |
| USB2 PHY at `0xff2b0000` | RK3506 PHY with GRF register access and two port descriptions |
| USB OTG0 at `0xff740000` and OTG1 at `0xff780000` | DesignWare USB2 controllers, GIC SPI 74 and 79 respectively |

The vendor tree identifies three Cortex-A7 CPUs and uses PSCI over SMC.
Preserve the trusted firmware's reserved memory and the loader's actual DRAM map.
For card wiring, the UART header and the radio, see the [Lyra Zero W profile](../boards/rk3506b-lyra-zero-w/README.md).
[Shared RK3502/RK3506 device tree](https://github.com/EliSofke/LuckfoxLyraSDK/blob/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/kernel-6.1/arch/arm/boot/dts/rk3502.dtsi) · [RK3506 additions](https://github.com/EliSofke/LuckfoxLyraSDK/blob/6dcbca0d8a517d79bd8fb4205ca4966b136604bc/kernel-6.1/arch/arm/boot/dts/rk3506.dtsi)
