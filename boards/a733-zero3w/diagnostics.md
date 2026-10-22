# Accelerator diagnostic boundaries

This reference consolidates the bring-up observations behind the [current interface boundary](interfaces.md).
The observed board has 4 GiB RAM; its PCB revision was not recorded. Source records retain exact software and artifact provenance.

## Clock and power admission

The normal path observes firmware state. CORE ON policy with OFF status was already visible before final ARISC startup and kernel entry.
This does not identify a writer or a completed OFF transition. The configured default policy is unknown.
Sampled gate masks, MISR levels and PWCR 0x101 do not justify overriding readiness or DEVREQEN.
The dedicated PLL path reports 600 MHz core, 200 MHz bus and BVNC 36.56.104.183 after strict ON/Q readiness.
The combined source/rate change does not isolate one internal dependency. Rates and configured supply voltage were not externally measured.
GPU MMIO without successful preparation can stall the bus; synchronous fault recovery is not a timeout for such a transaction.

## Distinct software and hardware stages

| Stage | Accepted boundary and exclusions |
|---|---|
| Metadata and CPU preparation | Firmware 1.1.6976702 compatibility, native allocation and CPU serialization; these alone execute no firmware or DMA |
| Firmware bootstrap | Matching BVNC and firmware-started record; firmware memory remains retained until reset |
| LOGTYPE/MMUCACHE | Return slots and queue offsets establish command completion; an unchanged sync word alone does not |
| Diagnostic compute | KCCB consumption, CCCB completion, timeline, checked memory write and fresh fault state are separate predicates; asynchronous KICK need not return a synchronous success word |
| DRM/GEM/VM | Bounded queries, CPU mappings and per-file table lifetime; those operations alone do not establish GPU access to every mapping |
| FE and fixed NN | Finite FE/MMU/event4 execution and a separate fixed numerical TASK; no generic inference or repeated same-boot FE operation |

The current offscreen, virtual KWin and fixed-NPU results remain in [interfaces](interfaces.md) and the [SoC reference](../../socs/allwinner-a733.md).
A sequential GPU check after NPU work is not simultaneous workload acceptance. A host observation window is not an execution benchmark.

Source IDs in [sources.json](../../sources.json): `os-cleanup-a733-gpu-identification`, `os-cleanup-a733-preboot-snapshot`,
`os-cleanup-a733-gpu-fwinfo`, `os-cleanup-a733-gpu-fwmem`, `os-cleanup-a733-gpu-fwboot`, `os-cleanup-a733-gpu-fwprobe`,
`os-cleanup-a733-gpu-fwcompute`, `os-cleanup-a733-pvr-render`, `os-cleanup-a733-pvr-vm`, `os-cleanup-a733-pvr-execution`,
`os-cleanup-a733-pvr-graphics`, `os-cleanup-a733-npu-engine` and `os-cleanup-a733-npu-tiny-task`.

The [immutable fixed-NN acceptance record](data/fixed-nn-acceptance.json) retains its original schema and bytes.
Source `os-a733-fixed-nn-acceptance` in [sources.json](../../sources.json) records its OS revision and SHA256.
