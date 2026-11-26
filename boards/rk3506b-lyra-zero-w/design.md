# Design transfer

Retain a 3.3 V debug UART, an accessible card slot and an independent USB recovery connector.
Check the actual RK3506 variant, DDR device and matching memory initialization binary before applying power.
Confirm card-detect polarity and preserve the power and signal routing for a four-bit card.

For an AIC8800DC design, document the USB host, downstream hub port, radio supply and enable polarity.
Provide a defined antenna-switch state during reset. Route high-speed USB and the RF feed to the layout requirements of the selected module.
Test a cold boot to SD root, then association, DHCP and SSH with the intended antenna.
Product qualification also requires power and RF measurements on the new PCB.
[Zero W interfaces](interfaces.md) · [Rockchip RK3506B](../../socs/rockchip-rk3506b.md)
