# MoonBit Thin-Film TMM

`moonbit-thinfilm-tmm` is a pure MoonBit library for multilayer thin-film optics. It provides reusable transfer-matrix solvers, optical material models, device presets, field analysis, and bounded parameter inversion for spectroscopy and photonic-device experiments.

The project is designed for applications that need a small, typed numerical core that can be checked and tested across native and WebAssembly-oriented MoonBit targets.

## Core capabilities

- Isotropic 2×2 transfer-matrix calculations for reflectance, transmittance, absorptance, polarization, angle, and spectral sweeps.
- 4×4 Berreman/Jones calculations for anisotropic and birefringent layers.
- Complex arithmetic, dense linear algebra, interpolation, numerical integration, random sampling, and dispersion models.
- Optical-material records and tabulated/analytic refractive-index models.
- Device-oriented presets for DBRs, antireflection coatings, solar-cell stacks, filters, cavities, photonic structures, and related optical components.
- Field-depth, colorimetry, polarization, ellipsometry, coherence, and spectroscopic-analysis helpers.
- Constrained numerical inversion and deterministic global optimizers for thin-film parameters.
- A CLI demo and a reproducible benchmark workload.

## Quick start

### Requirements

- MoonBit toolchain v0.10.9 or newer.
- A native compiler toolchain for native builds. The library itself has no third-party MoonBit package dependencies.

Install MoonBit using the [official installer](https://www.moonbitlang.com/download/), then clone and validate the repository:

```bash
git clone https://github.com/zc222er/moonbit-thinfilm-tmm.git
cd moonbit-thinfilm-tmm
moon version --all
moon check --deny-warn --target all
moon test --deny-warn --target all
```

Run the executable demo:

```bash
moon run cmd/main
```

## CLI

The executable currently exposes two stable entry paths:

```bash
# Run the optical simulation demonstration
moon run cmd/main

# Run the fixed benchmark workload only
moon run cmd/main -- benchmark
```

The library packages can also be imported directly from MoonBit using the module namespace `zc222er/thinfilm_tmm`. The public package boundaries are documented by the generated `pkg.generated.mbti` files.

## Architecture

```text
core/        Complex numbers, layers, spectra, results, and matrix primitives
math/        Dense numerical linear algebra, interpolation, integration, and RNG
dispersion/  Analytic and tabulated optical-dispersion models
materials/   Reusable optical-material records and constants
tmm2d/       Isotropic 2×2 transfer-matrix solver
tmm4x4/      Anisotropic 4×4 Berreman/Jones solver
field/       Depth-resolved electromagnetic field calculations
devices/     Optical-device construction and application presets
analysis/    Color, polarization, ellipsometry, coherence, and spectroscopy tools
inversion/   Constrained fitting and global optimization algorithms
cli/         Text rendering and benchmark orchestration
cmd/main/    Native executable entry point
wasm/        WebAssembly-facing exports
```

Each directory with a `moon.pkg` file is a separate package. The implementation is intentionally split by numerical responsibility so that solver and application code can be reused independently.

Material-table scope and attribution boundaries are documented in [Data provenance](docs/MATERIALS.md).

## Benchmark

The benchmark is a fixed functional workload, not a synthetic loop counter. It executes:

1. a 2×2 DBR spectrum with 48 thin-film layers over 401 wavelengths;
2. a 4×4 uniaxial-layer calculation at 550 nm and 32°;
3. a 121-point solar-device spectrum and current-density integration.

Run the machine-readable workload directly:

```bash
moon run cmd/main -- benchmark
```

On the local Windows PowerShell environment used for this validation (`moon 0.1.20260819`, `moonc v0.10.9+6e6c44045`), five warm-cache wall-clock samples from `scripts/benchmark.ps1 -Iterations 5` were:

| workload | points/layers | min (ms) | median (ms) | max (ms) |
| --- | ---: | ---: | ---: | ---: |
| complete benchmark command | 121/401-point workload, including all three cases | 225.675 | 235.992 | 282.394 |

These timings include the native `moon run` process and are environment-dependent. They are provided for reproducibility, not as a portable performance guarantee. To collect new samples:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\benchmark.ps1 -Iterations 5
```

## Tests

The test suite covers core numerical operations, physical reference cases, dispersion behavior, multilayer solvers, anisotropic calculations, device presets, CLI output, and bounded optimization. It also includes boundary cases for empty/negative-size grids, extrapolation-safe spectrum access, absorbing-film energy balance, grazing-angle 4×4 execution, nonpositive wavelengths, and optimizer bounds.

The current local validation runs 115 tests successfully on the wasm, wasm-gc, js, and native targets. Reproduce the strict suite with:

```bash
moon test --deny-warn --target all
moon test --deny-warn --target native
```

## CI

GitHub Actions runs on Ubuntu, macOS, and Windows. Each job installs the current MoonBit toolchain, checks that `moonc` is at least v0.10.9, updates module metadata, and runs:

- `moon fmt --check`
- `moon check --deny-warn --target all`
- native and wasm-gc builds
- `moon test --deny-warn --target all`
- `moon test --deny-warn --target native`
- `moon info` followed by a clean generated-interface diff

The workflow is defined in [.github/workflows/ci.yml](.github/workflows/ci.yml).

## License

Apache License 2.0. See [LICENSE](LICENSE).
