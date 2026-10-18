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
| CIX P1/CD8180 SBC, vendor model `Orange Pi 6 Plus` | ACPI console routing, power boundaries and VPU integration research | [Profile](boards/cix-p1-orangepi6plus/README.md) |
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
bootloaders/                Shared loader contracts and artifact checks
interfaces/                 Electrical and software contract worksheets
schemas/                    Machine-readable profile contract
templates/                 Starting records for a new board, config or observation
tools/                     Offline structural validation
```

Keep knowledge at the layer that owns it:

| Layer | Owns | Example |
|---|---|---|
| Board or module | Populated hardware, variants, exposed interfaces and actual boot chain | [CM5](boards/bcm2712-cm5/README.md) |
| Carrier | Connector numbering, controls, wiring and power routing | [CM5-NANO-B](carriers/cm5-nano-b/README.md) |
| SoC | Shared silicon facts and driver entry points | [BCM2712](socs/bcm2712.md) |
| Bootloader | Executable format, boot-entry selection and deployment checks | [EmberBSD efiboot](bootloaders/efiboot.md) |
| Interface | Electrical and software contract used to connect a peripheral | [Interface worksheet](interfaces/README.md) |

Board boot guides link to the applicable loader contract.
A shared SoC or UEFI firmware does not establish the same loader path.

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
Keep reusable findings and their applicability here. Do not track an individual lab device's current state.
Installed packages, recovery progress, deployment hashes and pending lab actions belong in the lab's own records.
The initial records cover selected interfaces. Missing data means unknown, not absent or working.
A successful experiment does not qualify a production design or another board revision.
