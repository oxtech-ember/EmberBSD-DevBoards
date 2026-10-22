# Design transfer

Only speed grade 0x04 has physical evidence. Operating points span 408 MHz to 1.8 GHz on little cores and 2.0 GHz on big cores.
Voltage rises before frequency and falls afterward. Thermal throttling selects 408 MHz at 85 °C and releases at 75 °C.
Without a heat sink under all-core load, the observed board reached 90 °C and spent most time at its minimum rate.
A fixed 792 MHz still reached 84 °C. Design cooling for the intended enclosure rather than removing the low operating point.
Validate PMIC, card-pin supply, RGMII delays, radio firmware and Type-C wiring on a custom board.

Source: `os-zero4-reference` in [sources.json](../../sources.json).
