# EmberBSD DevBoards

Reference platforms for people who build their own devices with EmberBSD.
Use a known board to investigate a design, connect a peripheral, and establish a reproducible baseline.
Human developers and their AI assistants use the same records.

Start with [the reader guide](docs/reader-guide.md), then select a board in [catalog.json](catalog.json).
The catalog is an index. Each board profile names its sources and the limits of its evidence.

| Reference platform | Useful starting point | Read first |
|---|---|---|
| BCM2712 module, vendor model `CM5` | Custom carrier, eMMC provisioning, thermal design and graphics research | [Profile](boards/bcm2712-cm5/README.md) |
| BCM2712 SBC, vendor model `RPi5` | Peripheral prototypes and a comparison platform for module designs | [Profile](boards/bcm2712-rpi5/README.md) |
| Allwinner A733 SBC, vendor model `Zero 3W` | Compact wireless devices and accelerator research | [Profile](boards/a733-zero3w/README.md) |

## Find information

```text
catalog.json                Stable IDs, aliases and profile paths
sources.json                Source URLs, revisions, review dates and known hashes
boards/<id>/                Board identity, boot, interfaces and design transfer notes
  board.json                Searchable identity and bounded capability claims
  README.md                 Entry point and required reading
  boot.md                   Boot stages and recovery route
  interfaces.md             Exposed interfaces, driver dependencies and gaps
  design.md                 What changes when you make your own device
  configs/<scenario>/       Configuration plus its applicability manifest
  evidence/<scenario>.json  Bounded observations with reproducible inputs
carriers/<id>/              Carrier wiring, connector numbers, buttons and power routing
socs/                       Shared silicon facts and implementation entry points
interfaces/                 Electrical and software contract worksheets
schemas/                    Machine-readable profile contract
templates/                 Starting records for a new board, config or observation
tools/                     Offline structural validation
```

For a new design, use [From a board to your device](docs/device-design.md).
For a new record, use [CONTRIBUTING](CONTRIBUTING.md) and [the data contract](docs/data-model.md).
Run `ruby tools/validate.rb` after edits. Reading the catalog requires no tool installation.

## Ownership and scope

| Repository | Owns |
|---|---|
| DevBoards | Hardware references, integration knowledge, configuration applicability and research observations |
| [EmberBSD](https://github.com/oxtech-ember/EmberBSD) | Kernel drivers, device trees, firmware adaptation, builders and executable OS checks |
| [Ports](https://github.com/oxtech-ember/EmberBSD-Ports) | Shared software recipes, dependencies and portability patches |
| [Examples](https://github.com/oxtech-ember/EmberBSD-Examples) | Standalone applications and reproducible demonstrations |
| [Development skills](https://github.com/oxtech-ember/Ember-Agent-Skills) | Assistant workflows for developing EmberBSD components |

Link to the implementation owner. Do not maintain a second driver, build procedure or support matrix here.
Pinned sources explain a claim. Current owner documentation shows subsequent changes.
The initial records cover selected interfaces. Missing data means unknown, not absent or working.
A successful experiment does not qualify a production design or another board revision.
