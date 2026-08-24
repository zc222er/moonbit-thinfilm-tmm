# Acceptance Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a locally verified MoonBit hackathon acceptance revision with real benchmarks, stronger boundary tests, mature README structure, and multi-platform CI.

**Architecture:** Keep the existing package boundaries and public APIs. Add benchmark orchestration at the CLI boundary, add tests inside the packages that own the behavior, and use a small PowerShell runner only for wall-clock sampling. Documentation reports measured facts and explicit commands.

**Tech Stack:** MoonBit v0.10.9+, `moon` CLI, GitHub Actions, PowerShell, Apache-2.0.

---

### Task 1: Establish a clean baseline and benchmark design

**Files:**
- Inspect only: `moon.mod`, `moon.pkg`, `cmd/main/main.mbt`, `cli/commands.mbt`, `core/*`, `tmm2d/*`, `tmm4x4/*`

- [x] Record current `moon check`, `moon test`, `moon fmt --check`, source counts, and proposal hash.
- [x] Confirm public constructors and solver signatures with `moon ide outline`.
- [x] Choose fixed benchmark cases that exercise existing public APIs without fabricated reference data.

### Task 2: Add failing boundary tests

**Files:**
- Modify: `core/core_test.mbt`
- Modify: `tmm2d/tmm2d_test.mbt`
- Modify: `tmm4x4/tmm4x4_test.mbt`
- Modify: `dispersion/dispersion_test.mbt`
- Modify: `inversion/inversion_test.mbt`

- [x] Add tests for invalid/degenerate grids, interpolation clamping, absorbing-stack energy balance, isotropic 4×4 behavior, finite optimizer outputs, and dispersion edge inputs.
- [x] Run the focused tests and confirm each new assertion fails for the intended missing behavior or exposes a real boundary bug.

### Task 3: Implement minimal boundary behavior and warning cleanup

**Files:**
- Modify: the owning implementation files identified by the failing tests.
- Modify: `dispersion/models.mbt`, `dispersion/cody_lorentz.mbt` for explicit trait calls.

- [x] Implement only the behavior required by the failing tests, preserving existing valid-case APIs.
- [x] Replace deprecated implicit trait promotion with explicit trait calls or extensions.
- [x] Run focused tests, then `moon test --deny-warn`.

### Task 4: Add a reproducible benchmark command

**Files:**
- Modify: `cli/commands.mbt`
- Modify: `cmd/main/main.mbt`
- Create: `scripts/benchmark.ps1`
- Create: `benchmarks/README.md` if needed for benchmark protocol

- [x] Add a benchmark mode with fixed 2×2, 4×4, and device scenarios and machine-readable summary lines.
- [x] Add a PowerShell runner that performs warm-up plus repeated samples and reports min/median/max wall-clock time.
- [x] Run the benchmark locally and preserve only measured values for README use.

### Task 5: Upgrade CI and repository hygiene

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `.gitignore` if build/cache exclusions are incomplete.

- [x] Use Linux/macOS/Windows matrix setup based on MoonBit community templates.
- [x] Run format, all-target check/test, deny-warn test, interface generation diff, and native test where supported.
- [x] Add an explicit toolchain version guard for v0.10.9 or newer.

### Task 6: Rewrite README with verified facts

**Files:**
- Modify: `README.md`

- [x] Organize sections as positioning, capabilities, quick start, CLI, architecture, benchmarks, tests, CI, and license.
- [x] Remove internal contest/proposal/author/acceptance wording.
- [x] Replace unverified test/source/performance claims with command-backed measurements.
- [x] Keep `项目申报书.md` byte-for-byte unchanged.

### Task 7: Full local acceptance audit

**Files:**
- Inspect all changed files and `项目申报书.md`.

- [x] Run `moon fmt --check`, `moon check --deny-warn --target all`, `moon test --deny-warn --target all`, `moon info`, benchmark sampling, CLI smoke tests, and source counts.
- [x] Verify `git diff --check`, proposal hash stability, remote/default branch metadata, author history, license, and absence of tracked build artifacts.
- [x] Report remaining risks and exact local evidence; do not push remotely.
