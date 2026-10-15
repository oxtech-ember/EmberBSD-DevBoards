# Contribute device development knowledge

First identify the board, module, carrier, revision and intended device function.
Check existing IDs and the implementation owner's documentation.
Add facts at the owning [knowledge layer](README.md#find-information). A shared SoC does not establish shared wiring.
Keep a loader contract in `bootloaders/`; link each applicable board's actual boot chain to it.

1. Copy the relevant [template](templates/board/README.md).
2. Add source records with URLs, dates, revisions and available hashes.
3. State connector numbering, voltage units, signal direction and source for every pin map.
4. Describe boot stages, controls, power requirements, driver dependencies and design transfer limits.
5. Add a configuration manifest for each reusable configuration.
6. Record checks at their actual level. Keep source, build, VM and physical results separate.
7. Run `ruby tools/validate.rb`. Inspect the rendered Markdown and changed source references.
8. Submit through the repository's configured contribution process. Include the changed facts, evidence and remaining unknowns.

For driver or package changes, follow the current rules of EmberBSD or Ports.
Keep executable checks beside that implementation and link them here.
Describe the reusable mechanism, prerequisites and limits. Do not add current lab status or a deployment diary.
A bounded reference experiment can support a design claim; it must not become an inventory of the tested device.
For upstream contributions, follow the receiving project's rules and disclose AI assistance.

Write short English sentences with exact identifiers and units.
Keep vendor identifiers and source attribution intact.
Link original schematics and datasheets; do not copy or redraw them without the required rights.
Store no credentials, private keys, device serial numbers or network addresses in shared profiles.
Do not commit firmware binaries, full device images or unredacted personal logs.

This repository has no implicit license grant for third-party material.
Source links do not change the original material's license.
