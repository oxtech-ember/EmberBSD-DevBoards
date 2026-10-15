# Generic 4-wire PWM fan: CM5 profile

Use this profile for the recorded CM5-NANO-B ACPI cooling path.
`Generic 4-wire PWM fan` names the fan class, not a qualified vendor model.
Check supply voltage, connector wiring, PWM polarity and reliable starting duty for your selected fan.
The [carrier profile](../../../../carriers/cm5-nano-b/README.md) owns wiring and power details.

## Persistent settings

Merge [sysctl.conf](sysctl.conf) into `/etc/sysctl.conf`; retain unrelated entries.
Keep one active entry for each setting. Check the actual thermal-zone name before installation.
The [manifest](manifest.json) records applicability, the file hash and the recovery route.

| Setting | Value | Effect on the recorded firmware |
|---|---|---|
| `hw.acpitz0.fan_min_level` | `2` | Skip the weak 75/255 step. Start active cooling at 125/255. |
| `hw.acpitz0.fan_max_only` | `0` | Retain stronger automatic thermal steps. |
| `hw.acpitz0.force_fan` | `0` | Let the thermal policy control the fan. |

`2` is an ACPI cooling index. It is not a PWM percentage or an RPM value.
Its mapping depends on firmware. These settings do not alter PWM frequency.
The OS owns [control semantics, activation and regression checks](https://github.com/oxtech-ember/EmberBSD/blob/6245a565b06486186c0159a1315ed89c893148a7/ember/boot/thermal-fan.md).

## Recorded check

On the 2026-10-12 CM5 check, the 75/255 level frequently produced no tachometer pulse.
Three warm starts at 125/255 succeeded without a maximum-speed boost.
Automatic cooling then started at 50.1 °C. All 272 active sampled windows contained tachometer pulses during a 300-second observation.
The peak temperature was 57.8 °C. All three settings persisted after a normal reboot.
See [the bounded evidence record](../../evidence/thermal-fan.json).

A different Generic fan still needs its own starting-duty check.
Cold power-on, higher-temperature transitions, continuous rotation between samples and long runs remain unvalidated.
Tachometer pulses per revolution were not established; no absolute RPM is claimed.
This profile does not establish acceptance of the current recovery installation.
