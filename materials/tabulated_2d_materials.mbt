///|
// ============================================================================
// Two-Dimensional Layered Materials Optical Constants (Monolayer & Bulk)
// High-resolution tabulated (n, k) optical constants (300 nm - 1000 nm)
// ============================================================================

///|
pub fn get_mose2_monolayer_spectrum() -> @disp.TabulatedDispersion {
  // Monolayer MoSe2 with A (1.58 eV / 785 nm) and B (1.78 eV / 696 nm) exciton peaks
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 690.0, 720.0, 780.0, 810.0,
    850.0, 900.0,
  ]
  let n_arr = [
    4.10, 4.45, 4.70, 4.80, 5.10, 5.50, 5.20, 6.40, 4.80, 6.80, 4.50, 3.80, 3.50,
  ]
  let k_arr = [
    2.50, 2.25, 1.95, 1.70, 1.85, 2.45, 1.80, 3.20, 1.10, 3.60, 0.40, 0.08, 0.01,
  ]
  @disp.TabulatedDispersion::new("MoSe2_1L", wls, n_arr, k_arr)
}

///|
pub fn get_wse2_monolayer_spectrum() -> @disp.TabulatedDispersion {
  // Monolayer WSe2 with A (1.65 eV / 750 nm) and B (2.08 eV / 595 nm) exciton peaks
  let wls = [
    350.0, 400.0, 450.0, 500.0, 550.0, 590.0, 630.0, 680.0, 745.0, 780.0, 850.0,
    900.0,
  ]
  let n_arr = [
    3.80, 4.25, 4.55, 4.65, 4.90, 5.85, 4.60, 4.20, 6.50, 4.20, 3.55, 3.35,
  ]
  let k_arr = [
    2.35, 2.10, 1.80, 1.55, 1.75, 2.95, 1.10, 0.50, 3.40, 0.35, 0.04, 0.005,
  ]
  @disp.TabulatedDispersion::new("WSe2_1L", wls, n_arr, k_arr)
}

///|
pub fn get_black_phosphorus_armchair() -> @disp.TabulatedDispersion {
  // Black Phosphorus (Phosphorene) armchair direction (x-axis)
  let wls = [
    400.0, 500.0, 600.0, 700.0, 800.0, 900.0, 1000.0, 1200.0, 1550.0, 2000.0,
  ]
  let n_arr = [3.45, 3.70, 3.88, 3.95, 3.90, 3.82, 3.75, 3.65, 3.55, 3.48]
  let k_arr = [0.85, 0.72, 0.58, 0.45, 0.32, 0.20, 0.12, 0.05, 0.005, 0.0]
  @disp.TabulatedDispersion::new("BlackPhosphorus_Armchair", wls, n_arr, k_arr)
}

///|
pub fn get_hexagonal_boron_nitride_hbn() -> OpticalMaterial {
  // Hexagonal Boron Nitride (hBN) 2D dielectric substrate (Eg ~ 5.9 eV)
  let cauchy = @disp.CauchyDispersion::transparent(1.82, 0.012, 0.0)
  {
    name: "hBN (Hexagonal Boron Nitride)",
    category: MaterialCategory::TwoDimensional,
    formula: "BN (2D)",
    bandgap_ev: 5.95,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}
