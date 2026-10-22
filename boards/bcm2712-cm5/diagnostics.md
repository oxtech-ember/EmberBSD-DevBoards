# Bounded display and GPU diagnostic evidence

These finite results describe individual mechanisms on CM5 Rev 1.0, BCM2712 D0, 4 GiB on CM5-NANO-B.
They do not replace the newer [physical Plasma boundary](graphics.md). Carrier revision and firmware vary by source record.
The original source records retain exact build inputs and artifact hashes in [sources.json](../../sources.json).

| Mechanism | Reusable observation and limit | Source IDs |
|---|---|---|
| Firmware resources | The checked DSDT exposes contract version 1, 32 memory ranges and seven interrupts. Discovery alone grants no clock or MMIO access. | `os-cleanup-bcm2712-display-contract` |
| HSM and DVP | Finite 120 MHz request/readback and inherited enabled gates pass. The rate is not an external measurement; inherited gates do not test the gate-write path. | `os-cleanup-bcm2712-display-hsm` |
| HPD and DDC registers | HPD samples distinguish disconnected/connected levels. The DDC snapshot reports status 0, mask 0xf, CTL 0, ENABLE 0 and CTLHI 0xc0; candidate quiescence is not bus ownership. | `os-cleanup-bcm2712-display-dvp` |
| HD observation | Video enable is clear and pixel clocks stopped in the finite sample. DVP_CTL bit0 has no defined meaning in the pinned headers. | `os-cleanup-bcm2712-hd-observe-probe` |
| EDID | One checksummed base block declares 1920×1080 at 60 Hz and one unread extension. Other sinks, extension reads and disconnect-during-transfer are unqualified. | `os-cleanup-bcm2712-display-edid-probe` |
| HPD IRQ | Stale, disconnect and reconnect callbacks pass in one bounded cycle. This does not qualify repeated DRM hotplug or power management. | `os-cleanup-bcm2712-hpd-irq-probe` |
| GPU reset, DMA and interrupts | Identification, reset takeover, translated TFU copy, one bin/render tile and owned TFUC/FLDONE/FRDONE completion have finite evidence. | `os-cleanup-bcm2712-v3d`, `os-cleanup-bcm2712-v3d-takeover`, `os-cleanup-bcm2712-v3d-dma`, `os-cleanup-bcm2712-v3d-irq-plan`, `os-cleanup-bcm2712-v3d-binrender-plan` |
| Fault recovery | One invalid-destination TFU fault followed by a checked good copy passes. A failed conversion can retire and assert terminal TFUC; neither event alone means correct output. | `os-cleanup-bcm2712-v3d-validation` |
| Render, CSD and sync | Per-file lifetime, finite QPU output and CSD/TFU dependency chains have separate evidence. General recovery and endurance remain unqualified. | `os-cleanup-bcm2712-v3d-render`, `os-cleanup-bcm2712-v3d-csd`, `os-cleanup-bcm2712-v3d-sync` |
| CPU BO readback | A colored 1920×1080 desktop BO passes CPU mapping/readback. This does not identify its actual PV head or prove general GPU-cache coherency. | `os-cleanup-bcmv3d-kms-snapshot` |

The implementation owner maintains admission, lifetime, IRQ, memory and executable regression contracts.
Do not choose an old kernel solely to match a diagnostic source record.
