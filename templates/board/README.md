# New board worksheet

Copy a matching existing board directory and give it a new stable ID.
Add it to `catalog.json`. Replace inherited claims with sourced facts or explicit unknowns.

- Identity: SoC, module/SBC, vendor identifier, revisions, RAM/storage/radio variants and carrier IDs.
- Intended research: device function and smallest useful operation to prove.
- Boot: ROM, first-stage firmware, loader, OS description, kernel, storage and console.
- Controls: connector orientation, physical button behavior, reset, boot-mode selection and power-off.
- Interfaces: signals, voltage limits, pinmux conflicts, clocks, reset, DMA and driver/user API owners.
- Design transfer: what changes on a custom carrier or PCB, including power, thermal and recovery access.
- Configuration: files, source pins, hashes, applicability, activation effect and rollback route.
- Evidence: exact specimen class, inputs, workload, observation, measurements, duration and exclusions.

Keep `board.json` brief. Detailed current hardware support belongs in this profile.
Keep software mechanisms, API contracts, build commands and executable checks beside their implementation.
Link immutable source evidence with a revision and hash. Consolidate conclusions without a test diary.
Do not use this worksheet as a completed acceptance record.
