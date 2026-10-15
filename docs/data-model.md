# Data contract, version 1

Use UTF-8 Markdown for explanations and JSON for records.
Names use lowercase kebab-case. IDs remain stable when a board's nickname changes.
`format_version` changes when a consumer must interpret fields differently.
Add a separate ID when wiring or boot behavior cannot be described safely as a revision of the same hardware.

## Identity and sources

`catalog.json` is the index. `board.json` owns identity and short capability claims.
A carrier has its own `carrier.json`; a module does not own its carrier's connector numbering.
A `null` revision means not established. It never means all revisions.
`reviewed_at` is the date the record was checked, not the date all interfaces were tested.
`source_refs` resolve to IDs in `sources.json`.
Each source names a URL, revision when known, review date and SHA256 when available.
Do not invent a hash or substitute a branch name for an exact tested revision.

`documents` and catalog `profile`/`document` values are paths from the repository root.
[The profile schema](../schemas/profile.schema.json) defines required fields and status values.
The offline checker validates references, unique IDs, paths, status vocabulary and pin-map structure.
It cannot verify electrical facts, remote source contents or hardware behavior.

## Capability claims

| Field | Values and meaning |
|---|---|
| `hardware` | `present`, `absent`, `unknown`: whether the relevant physical function is available |
| `emberbsd` | `unknown`: no scoped conclusion; `unsupported`: a known missing path; `partial`: only part of the required path; `verified-scenario`: the stated useful operation was checked |
| `scope` | Required text describing the actual operation and limits |
| `source_refs` | Sources supporting that specific claim |

A verified scenario is not a declaration that the whole board is supported.
If hardware existence and software execution have different sources, cite both.
Keep failures distinct from features not tested.
New evidence must not silently erase an earlier result with different firmware or wiring.
Update the current summary and retain the scoped evidence record.

## Configuration and evidence

A configuration manifest records purpose, target ID, revision limits, installation location,
owner, source pin, file hashes, prerequisites, activation effect and recovery route.
Catalog configurations use `reference` or `tested-scenario` to state applicability.
An unfinished worksheet uses `template` outside the catalog.
An external bundle can be referenced by URL and SHA256 without copying its binaries.
A template must not be mistaken for an installable image or deployed configuration.

An evidence record states hardware identity, software/firmware inputs, scenario, expected result,
observed result, result status, validation layer, duration, measurements and exclusions.
Use `pass`, `fail`, `inconclusive` or `not-run` for the result.
Use `source`, `build`, `vm`, `physical` or `operator-report` for the layer.
Unknown input values remain `null` and are explained in `limits`.
Use [the evidence template](../templates/evidence.json) and [the config template](../templates/config.json).

The schemas validate catalog records, not unfinished files in `templates/`.
Replace placeholders and change `template` to `reference` or `tested-scenario` before adding a configuration to a board.
The Ruby checker implements the schema keywords used here; it is not a general JSON Schema engine.
Run `ruby tools/check-validator.rb` when changing a schema or the checker.
Remote links, Markdown anchors and hardware facts require source review.
