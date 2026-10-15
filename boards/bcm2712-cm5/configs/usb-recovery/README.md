# USB recovery reference

This profile supplies the outer `config.txt` and pins the complete official RAM bundle in [manifest.json](manifest.json).
Binaries are linked, not stored. Follow the [upstream procedure](https://github.com/raspberrypi/usbboot/tree/861a703d8b51f42b76bcdff49da3e0f2766966bf/mass-storage-gadget64).
Use the `firmware/bootfiles.bin` URL in the manifest; the other upstream path is a Git symlink.

Release `20261002-115811` shipped an initramfs without the required USB gadget modules.
Upstream fixed it at `861a703d8b51f42b76bcdff49da3e0f2766966bf`. See [issue 403](https://github.com/raspberrypi/usbboot/issues/403).
The fixed image contains `dwc2`, `libcomposite`, `usb_f_mass_storage` and `usb_f_acm` for its own kernel.
Do not combine it with a different kernel or inherit experimental UART/DTB modifications.

[The observation](../../evidence/usb-recovery.json) records eMMC and ACM enumeration over direct USB.
It does not accept EmberBSD boot, storage repair, graphics or a complete recovery operation.
This is vendor Linux in RAM. It is not an EmberBSD image or a replacement for its components.
Verify storage identity before opening raw devices. Never assume the host's disk number remains stable.
An exported eMMC device is writable; automatic host mounting and repair must be controlled separately.
