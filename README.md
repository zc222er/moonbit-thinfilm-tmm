# MoonBit Thin-Film TMM (`moonbit-thinfilm-tmm`)

[![CI](https://github.com/zc222er/moonbit-thinfilm-tmm/actions/workflows/ci.yml/badge.svg)](https://github.com/zc222er/moonbit-thinfilm-tmm/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![MoonBit Version](https://img.shields.io/badge/MoonBit-Latest-purple.svg)](https://www.moonbitlang.com/)
[![Tests](https://img.shields.io/badge/Tests-107%20Passed-success.svg)](devices/)

A high-performance, pure MoonBit simulation library and spectroscopic parameter inversion engine for multilayer optical thin films. 

Featuring both classical **$2\times 2$ Isotropic Transfer Matrix Method (TMM)** and **$4\times 4$ Berreman Transfer Matrix Method** for anisotropic, birefringent, and gyrotropic media, electromagnetic depth-resolved Poynting vectors, non-linear global optimization suites (PSO, MCMC, CMA-ES, GA, Differential Evolution, simulated annealing), and extensive physical materials optical constant databases.

---

## Key Features

- **High-Precision Transfer Matrix Solvers**:
  - **$2\times 2$ Matrix Formulation**: Fast isotropic multilayer reflection ($R$), transmission ($T$), and absorption ($A$) calculations for arbitrary incident angles ($\theta_0$) and polarizations (TE/s, TM/p, unpolarized).
  - **$4\times 4$ Berreman Matrix Formulation**: General propagation in arbitrary anisotropic, uniaxial, and biaxial media with arbitrary optic axis Euler angles $(\theta, \phi, \psi)$.
  - **Spatial Field Distribution**: Spatial profile solver for internal electric and magnetic field amplitudes ($E_x, E_y, E_z, H_x, H_y, H_z$), Poynting vector flux ($S_z$), and optical dissipation density distribution ($Q(z)$).

- **Rich Physical Materials & Dispersion Database (100+ Materials)**:
  - **Dispersion Models**: Cauchy, Sellmeier (3-pole & 5-pole), Drude, Lorentz, Tauc-Lorentz, Cody-Lorentz, Forouhi-Bloomer, and Effective Medium Theory (Maxwell Garnett, Bruggeman, Volume Average).
  - **Tabulated Optical Constants ($n, k$)**: Semiconductors (Si, Ge, GaAs, InP, GaN, SiC, Perovskites $\text{MAPbI}_3 / \text{FAPbI}_3$), 2D Materials ($\text{MoS}_2, \text{WS}_2, \text{hBN}$, Black Phosphorus), Optical Glasses (BK7, F2, SF11, Fused Silica), Metals (Au, Ag, Al, Cu, Pt, Ti, Cr, Ni, W, Mo), TCOs (ITO, FTO, AZO), Phase-Change Materials ($\text{VO}_2, \text{GST-225}$), and Superconductors (NbN, YBCO, TiN).

- **Photonic Device Simulation Presets**:
  - **Solar Cells & Tandem Photovoltaics**: Monolithic Perovskite/Silicon tandem current matching, OPV exciton generation profiles, and AM1.5G short-circuit current density ($J_{sc}$) integration.
  - **Display Optics & OLEDs**: Dipole emission Purcell factor enhancement, microcavity outcoupling efficiency, and CIE $xyY$ / $L^*a^*b^*$ color coordinates.
  - **Optical Coatings & Filters**: Distributed Bragg Reflectors (DBR), Fabry-Pérot etalons, Anti-Reflection (AR) coatings, Dichroic mirrors, MacNeille Polarizing Beam Splitters (PBS), and EUV 13.5 nm Mo/Si multilayer mirrors.
  - **Nanophotonics & Plasmonics**: Surface Plasmon Resonance (SPR) biosensors, MIM waveguides, NPoM plasmonic nanocavities (SERS enhancement $> 10^8$), and Pancharatnam-Berry geometric phase metalenses.

- **Non-Linear Spectroscopic Inversion & Optimization Suite**:
  - **Local Optimization**: Levenberg-Marquardt (LM) and Nelder-Mead Downhill Simplex with analytical Jacobian matrices.
  - **Global Metaheuristics**: Particle Swarm Optimization (PSO), Fast Simulated Annealing (FSA with Cauchy cooling), Differential Evolution (DE), CMA-ES, Grey Wolf Optimizer (GWO), Cuckoo Search, Whale Optimization Algorithm (WOA), Continuous Ant Colony Optimization (ACOR), and Jaya algorithm.
  - **Bayesian Parameter Estimation**: Markov Chain Monte Carlo (MCMC) Metropolis-Hastings posterior sampling with credible intervals and uncertainty quantification.
  - **Automated Synthesis**: Tikhonravov needle optimization for automated layer insertion and thin-film filter synthesis.

- **Zero-Dependency Core & Cross-Platform**:
  - 100% written in MoonBit with zero external runtime dependencies.
  - Compiles seamlessly to native binaries, WebAssembly (WASM) for high-performance in-browser simulation, and JavaScript targets.

---

## Repository Architecture

```text
├── core/            # Complex number arithmetic, Matrix algebra, Stack and Layer data structures
├── math/            # Numerical linear algebra, SVD, LU, Interpolation, Quadrature, Random RNG
├── dispersion/      # Analytical optical dispersion models (Sellmeier, Drude, Tauc-Lorentz, Cody)
├── materials/       # Comprehensive tabulated physical optical constants database (100+ materials)
├── tmm2d/           # 2x2 Transfer Matrix Method solvers for isotropic multilayer stacks
├── tmm4x4/          # 4x4 Berreman Transfer Matrix Method solvers for anisotropic media
├── field/           # Spatial electromagnetic field & Poynting dissipation depth profiles
├── devices/         # Ready-to-use device presets (Solar, OLED, DBR, EUV, Filters, Metamaterials)
├── inversion/       # Non-linear optimization, MCMC Bayesian sampling, & global metaheuristics
├── analysis/        # Colorimetry (CIE 1931), Ellipsometric Mueller decomposition, Zernike polynomials
├── cli/             # Interactive terminal spectrum plotter, CLI commands, & CSV data export
├── cmd/main/        # Executable binary entry point
└── wasm/            # WebAssembly exports and JavaScript browser integration wrappers
```

---

## Quick Start

### Prerequisites

Install the MoonBit toolchain:

```bash
# macOS / Linux
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

# Windows (PowerShell)
irm https://cli.moonbitlang.com/install/powershell.ps1 | iex
```

### Build and Run Tests

```bash
# Clone the repository
git clone https://github.com/zc222er/moonbit-thinfilm-tmm.git
cd moonbit-thinfilm-tmm

# Run all 107 unit tests
moon test

# Type check with zero warnings allowed
moon check --deny-warn

# Code format check
moon fmt --check
```

### Basic Example: Anti-Reflection (AR) Coating Simulation

```moonbit
import @zc222er/thinfilm_tmm/core as @core
import @zc222er/thinfilm_tmm/materials as @mat
import @zc222er/thinfilm_tmm/tmm2d as @tmm
import @zc222er/thinfilm_tmm/devices as @devices

fn main {
  // Define substrate and ambient
  let air = @mat.air().to_layer(0.0, 550.0)
  let glass_sub = @mat.bk7().to_layer(0.0, 550.0)
  let mgf2 = @mat.magnesium_fluoride()

  // Build single-layer Quarter-Wave Anti-Reflection (QWAR) coating (d = lambda / 4n ~ 99.6 nm)
  let ar_design = @devices.QuarterWaveAR::new(550.0, mgf2, glass_sub)
  let stack = ar_design.build_stack()

  // Solve spectrum from 400 nm to 700 nm
  let grid = @core.SpectrumGrid::visible_spectrum(31)
  let sim = @tmm.solve_spectrum(stack, grid, @core.IncidentAngle::normal())

  println("Wavelength (nm) | Reflectance (%) | Transmittance (%)")
  println("-----------------------------------------------------")
  for i = 0; i < grid.count(); i = i + 1 {
    let wl = grid.get(i)
    let r_pct = sim.reflectance.get(i) * 100.0
    let t_pct = sim.transmittance.get(i) * 100.0
    println("\{wl} nm        | \{r_pct}%       | \{t_pct}%")
  }
}
```

### Parameter Inversion Example (Spectroscopic Ellipsometry)

```moonbit
import @zc222er/thinfilm_tmm/inversion as @inv

fn run_inversion_example() {
  // Target: extract unknown thin-film thickness d and refractive index n
  let target_fn = fn(p : Array[Double]) -> Double {
    let d_diff = p[0] - 120.0 // True thickness 120 nm
    let n_diff = p[1] - 2.15  // True refractive index 2.15
    d_diff * d_diff + n_diff * n_diff
  }

  let bounds = [
    @inv.ParameterBound::new("thickness_nm", 10.0, 300.0, 50.0),
    @inv.ParameterBound::new("refractive_index", 1.0, 3.5, 1.5),
  ]

  let best_params = @inv.particle_swarm_optimize(
    target_fn,
    bounds,
    @inv.PSOSettings::default()
  )

  println("Fitted Thickness: \{best_params[0]} nm")
  println("Fitted Index:     \{best_params[1]}")
}
```

---

## Command Line Interface (CLI)

Run simulation tasks and generate ANSI terminal spectral plots directly from the command line:

```bash
# Simulate visible spectrum of a Distributed Bragg Reflector (DBR)
moon run cmd/main -- --mode dbr --pairs 10 --center-wl 632.8

# Run spatial electric field profile calculation
moon run cmd/main -- --mode field --depth 500.0 --wavelength 550.0

# Run spectroscopic parameter inversion test
moon run cmd/main -- --mode fit --target-file experimental_spectrum.csv
```

---

## WebAssembly (WASM) & Browser Integration

The core simulation engine compiles to high-speed WebAssembly, allowing real-time interactive optical modeling directly in the browser:

```javascript
import { MultiLayerTMM } from './moonbit_tmm.wasm';

// Initialize multilayer stack in JS
const tmm = new MultiLayerTMM();
tmm.addLayer("Air", 0, 1.0);
tmm.addLayer("TiO2", 55.0, 2.35);
tmm.addLayer("SiO2", 90.0, 1.46);
tmm.setSubstrate("Glass", 1.52);

// Compute reflection and transmission spectrum in under 1 millisecond
const spectrum = tmm.solveSpectrum(400, 800, 101, 0.0); // 400-800nm, 101 points, 0 deg
console.log(spectrum.reflectance);
```

---

## Quality Assurance & Performance

- **Test Suite**: 107 comprehensive unit and integration tests across all packages.
- **Strict Verification**: Passed `moon check --deny-warn` with zero compiler warnings and zero errors.
- **Formally Typed**: All module signatures are documented and exported via public `.mbti` interfaces.

```bash
$ moon test
Total tests: 107, passed: 107, failed: 0.

$ moon check --deny-warn
Finished. moon: ran 16 tasks, now up to date (0 warnings, 0 errors)
```

---

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
