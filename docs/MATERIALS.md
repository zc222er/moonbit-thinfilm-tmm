# Material data and provenance

The `materials/` package contains analytical dispersion models and compact
numerical parameter tables used by the examples and device presets. The
tables are stored as MoonBit source data; no external dataset archive or
private fixture is required to build the project.

The implementation is MoonBit source code maintained in this repository and
is covered by the root Apache License 2.0. Some source comments identify the
scientific context of a model or table, including Palik, Johnson and Christy,
Rakic, Green, and SOPRA references. Those references provide attribution
context only: the original publications and source databases are not bundled
with this repository.

The numerical values are model inputs for simulation and should be calibrated
against the appropriate experimental reference before use in a quantitative
production workflow. Users redistributing derived material tables are
responsible for checking the terms of the corresponding source data and for
replacing a table with rights-cleared data when required.

The `pkg.generated.mbti` files are generated public-interface descriptions
maintained by `moon info`; they are not copied third-party implementation
files. No external source-code port or downloaded test fixture is included in
the repository.
