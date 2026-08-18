///|
// ============================================================================
// Organic Semiconductor & Laser Dye Database (OLED / OPV Materials)
// Full spectroscopic (n, k) optical constants (300 nm - 1000 nm)
// ============================================================================

///|
pub fn alq3_green_emitter() -> @disp.TabulatedDispersion {
  // Tris(8-hydroxyquinolinato)aluminium (Alq3) standard OLED electron transport and green emission layer
  let wls = [
    350.0, 380.0, 400.0, 420.0, 450.0, 500.0, 520.0, 550.0, 600.0, 700.0, 800.0,
  ]
  let n_arr = [1.82, 1.95, 1.88, 1.78, 1.74, 1.72, 1.71, 1.70, 1.68, 1.66, 1.65]
  let k_arr = [0.35, 0.42, 0.28, 0.12, 0.02, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  @disp.TabulatedDispersion::new("Alq3", wls, n_arr, k_arr)
}

///|
pub fn c60_fullerene() -> @disp.TabulatedDispersion {
  // Buckminsterfullerene C60 electron acceptor
  let wls = [
    300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 700.0, 800.0, 900.0, 1000.0,
  ]
  let n_arr = [2.15, 2.35, 2.20, 2.05, 1.98, 1.92, 1.88, 1.82, 1.80, 1.78, 1.76]
  let k_arr = [0.65, 0.85, 0.52, 0.38, 0.22, 0.12, 0.08, 0.02, 0.005, 0.0, 0.0]
  @disp.TabulatedDispersion::new("C60", wls, n_arr, k_arr)
}

///|
pub fn y6_non_fullerene_acceptor() -> @disp.TabulatedDispersion {
  // Y6 high-efficiency near-infrared non-fullerene acceptor (absorption 600 - 900 nm)
  let wls = [
    400.0, 500.0, 600.0, 700.0, 750.0, 800.0, 830.0, 880.0, 920.0, 1000.0,
  ]
  let n_arr = [1.75, 1.82, 1.95, 2.25, 2.48, 2.65, 2.35, 1.88, 1.72, 1.68]
  let k_arr = [0.15, 0.18, 0.28, 0.65, 0.95, 1.25, 1.10, 0.35, 0.02, 0.0]
  @disp.TabulatedDispersion::new("Y6_NFA", wls, n_arr, k_arr)
}

///|
pub fn pm6_donor_polymer() -> @disp.TabulatedDispersion {
  // PM6 wide bandgap polymer donor matching Y6 acceptor
  let wls = [
    400.0, 450.0, 500.0, 550.0, 580.0, 620.0, 650.0, 700.0, 800.0, 900.0,
  ]
  let n_arr = [1.72, 1.78, 1.92, 2.15, 2.32, 2.10, 1.85, 1.72, 1.68, 1.66]
  let k_arr = [0.12, 0.22, 0.45, 0.78, 0.92, 0.55, 0.18, 0.01, 0.0, 0.0]
  @disp.TabulatedDispersion::new("PM6_Polymer", wls, n_arr, k_arr)
}

///|
pub fn rhodamine_6g_laser_dye() -> OpticalMaterial {
  // Rhodamine 6G laser dye in solid PMMA matrix
  let cauchy = @disp.CauchyDispersion::new(1.492, 0.0055, 0.0, 0.15, 0.008)
  {
    name: "Rhodamine 6G Dye",
    category: MaterialCategory::Polymer,
    formula: "C28H31ClN2O3",
    bandgap_ev: 2.35,
    dispersion_fn: fn(wl) { cauchy.get_complex_index(wl) },
  }
}
